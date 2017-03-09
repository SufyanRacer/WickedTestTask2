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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Apps List"
        API(urlString: "https://itunes.apple.com/us/rss/topfreeapplications/limit=50/json", WithDelegate: self).fetchJSONData()
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
        else{
            DispatchQueue.global().async {
                do{
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async {
                        self.imageCache[appName] = UIImage(data: data!)!
                        cell.appImage.image = UIImage(data: data!)
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 20, 10, 20)
    }
    
    // MARK:    APIProtocol Delegate Method
    
    func recievedData(data: Any){
        let JSONData: Dictionary = data as! [String: Any]
        
        let dataArray: Array = (JSONData["feed"] as! [String: Any])["entry"] as! [[String: Any]]
        
        self.appListArray = dataArray
        DispatchQueue.main.async {
            self.appCollectionView.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func saveImageToDocumentDirectory(image:UIImage, withName name: String){
        let fileManager = FileManager.default
        let paths = (self.getDirectoryPath() as NSString).appendingPathComponent("images/"+name+".png")
        print(paths)
        let imageData = UIImagePNGRepresentation(image)
        if fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil){
            print("image saved")
        }
        else {
            print("image not saved")
        }
    }
    
    func getImageFromDocumentDirectory(name: String) -> UIImage {
        let fileManager = FileManager.default
        let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent("images/"+name+".png")
        if fileManager.fileExists(atPath: imagePath){
            return UIImage(contentsOfFile: imagePath)!
        }else{
            return UIImage(named: "defaultImage")!
        }
    }
}

