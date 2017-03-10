//
//  ViewController.swift
//  Rappi_App_List_Task
//
//  Created by Sufyan on 08/03/17.
//  Copyright © 2017 Sufyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, APIProtocol, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var appCollectionView: UICollectionView!
    
    var appListArray: Array = [[String: Any]]()
    var imageCache: Dictionary = [String: UIImage]()
    var isFetchingCache: Bool = false
    internal var isInternetConnected: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Apps List"
        self.isInternetConnected = Reachability.connectedToNetwork()
        self.callAPIForData()
    }
    
    func callAPIForData()  {
        API(withDelegate: self).fetchJSONData()
    }
    
    func callAPIForLocalFile() {
        self.isFetchingCache = true
        API(withDelegate: self).getJSONFromDocumentDirectory()
    }
    
    
    // MARK:    CollectionView Delegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.appListArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : AppCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppCell", for: indexPath) as! AppCell
        let appInfo : Dictionary = self.appListArray[indexPath.row]
        let appName: String = (appInfo["im:name"] as! [String: Any])["label"] as! String
        let copyright: String = (appInfo["im:artist"] as! [String: Any])["label"] as! String
        let imageURLString: String = ((appInfo["im:image"] as! [[String: Any]])[2])["label"] as! String
        
        cell.appName.text = appName
        cell.copyright.text = copyright
        let url = URL(string: imageURLString)
        if self.imageCache[appName] != nil {
            cell.appImage.image = self.imageCache[appName]
        }
        else if self.isInternetConnected {
            DispatchQueue.global().async {
                do{
                    let data = try Data(contentsOf: url!)
                    DispatchQueue.main.sync {
                        self.imageCache[appName] = UIImage(data: data)!
                        cell.appImage.image = UIImage(data: data)
                    }
                    API(withDelegate: self).saveImages(imageDic: self.imageCache)
                }
                catch {
                    print("No image found at URL")
                }
            }
        } else{
            
            let image: UIImage = API(withDelegate: self).getImageFromDocumentDirectory(name: appName)
            DispatchQueue.main.async {
                self.imageCache[appName] = image
                cell.appImage.image = image
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let appInfo : Dictionary = self.appListArray[indexPath.row]
        let appName: String = (appInfo["im:name"] as! [String: Any])["label"] as! String
        let copyright: String = (appInfo["rights"] as! [String: Any])["label"] as! String
        let description: String = (appInfo["summary"] as! [String: Any])["label"] as! String
        let appImage: UIImage = self.imageCache[appName]!
        
        var selectedApp: AppInformation = AppInformation.init()
        selectedApp.appImage = appImage
        selectedApp.appName = appName
        selectedApp.copyright = copyright
        selectedApp.description = description
        self.pushDetailViewWithInfo(appInformation: selectedApp)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 20, 10, 20)
    }
    
    func pushDetailViewWithInfo(appInformation: AppInformation) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let appDetailViewController: AppDetailViewController = storyBoard.instantiateViewController(withIdentifier: "AppDetailViewController") as! AppDetailViewController
        appDetailViewController.appInformation = appInformation
        self.navigationController?.pushViewController(appDetailViewController, animated: true)
        
    }
    
    
    // MARK:    APIProtocol Delegate Method
    
     func recievedData(data: Any, fromLocal isLocal:Bool) {
        if (data as? [String: Any]) != nil {
            let JSONData: Dictionary = data as! [String: Any]
            let dataArray: Array = (JSONData["feed"] as! [String: Any])["entry"] as! [[String: Any]]
            self.isFetchingCache = isLocal
            updateViewWithRecievedData(dataArray: dataArray)
        } else {
            if !self.isFetchingCache {
                self.callAPIForLocalFile()
            } else {
                let showAlert = UIAlertController.init(title: "Error", message: "No Preview Available make sure you are connected to internet.", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Ok", style: .default) { (action) in
                    
                }
                showAlert.addAction(cancel)
                present(showAlert, animated: true, completion: nil)
            }
        }
    }

    // MARK:    Update View Method
    func updateViewWithRecievedData(dataArray: [[String: Any]])  {
        self.appListArray = dataArray
        DispatchQueue.main.async {
            self.appCollectionView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
}

