//
//  API.swift
//  Rappi_App_List_Task
//
//  Created by Sufyan on 08/03/17.
//  Copyright © 2017 Sufyan. All rights reserved.
//

import UIKit


protocol APIProtocol {
    
    func recievedData(data: Any)
    
}

class API: NSObject  {
    var delegate : APIProtocol
    var urlString : String
    
    init(urlString: String, WithDelegate delegate: APIProtocol) {
        self.urlString = urlString
        self.delegate = delegate
    }
    
    func fetchJSONData() {
        
        let url = URL(string: self.urlString)
        let request = URLRequest( url: url!)
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in

            if error != nil {
                
            }
            else {
                do {
                    if let json: Dictionary = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
                    {
                        self.sendDataToDelegate(data: json)
                    }
                } catch {
                    print("error in JSONSerialization")
                }
                
            }
        }
        task.resume()
    }
    
    func sendDataToDelegate(data: Any)  {
        self.delegate.recievedData(data: data)
    }
    
}
