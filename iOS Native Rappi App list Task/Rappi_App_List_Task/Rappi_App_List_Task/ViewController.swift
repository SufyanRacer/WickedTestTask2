//
//  ViewController.swift
//  Rappi_App_List_Task
//
//  Created by Sufyan on 08/03/17.
//  Copyright © 2017 Sufyan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, APIProtocol, UICollectionViewDelegate, UICollectionViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "App Lists"
        API(urlString: "https://itunes.apple.com/us/rss/topfreeapplications/limit=20/json", WithDelegate: self).fetchJSONData()
    }
    
    
    // MARK:    CollectionView Delegate Methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppCell", for: indexPath) as UICollectionViewCell
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    
    
    func recievedData(data: Any){
        let JSONData: Dictionary = data as! [String: Any]
        
        let dataArray: Array = (JSONData["feed"] as! [String: Any])["entry"] as! [[String: Any]]
        
        print((JSONData["feed"] as! [String: Any])["entry"] )
        
    }

}

