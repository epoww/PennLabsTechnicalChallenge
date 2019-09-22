//
//  NetworkManager.swift
//  DiningHalls
//
//  Created by Elizabeth Powell on 9/22/19.
//  Copyright © 2019 Elizabeth Powell. All rights reserved.
//

import UIKit

class NetworkManager {

    func getImage(url: URL, completionHandler: @escaping (UIImage) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("error" + (error?.localizedDescription)!)
            }
            
            if data != nil {
                let diningHallPic = UIImage(data: data!)
                if diningHallPic != nil {
                    completionHandler(diningHallPic!)
                }
            }
            
            }.resume()
    }
    
    func getData(url: URL, completionHandler: @escaping ([DiningPlace], [DiningPlace]) -> ()) {
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            var diningHall = [DiningPlace]()
            var retailDining = [DiningPlace]()
            
            let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            if let object = json as? [String: [String: [[String: Any]]]] {
                let venues = object["document"]!["venue"]
                for venue in venues! {
                    let name = venue["name"] as! String
                    var imageURL = ""
                    if let url = venue["imageUrl"] as? String {
                        imageURL = url
                    }
                    let facilityURL = venue["facilityURL"] as! String
                    let dateHours = venue["dateHours"] as! [[String: Any]]
                    let d = DiningPlace(n: name, f: facilityURL, i: imageURL, h: dateHours)
                    if venue["venueType"] as! String == "residential" {
                        diningHall.append(d)
                    } else {
                        retailDining.append(d)
                    }
                }
                
                completionHandler(diningHall, retailDining)
            } else {
                print("invalid JSON")
            }
            }.resume()
    }
}
