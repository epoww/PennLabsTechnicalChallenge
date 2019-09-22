//
//  Structs.swift
//  DiningHalls
//
//  Created by Elizabeth Powell on 9/21/19.
//  Copyright © 2019 Elizabeth Powell. All rights reserved.
//

struct DiningPlace {
    let name: String!
    let facilityURL: String!
    let imageURL: String!
    let hoursData: [[String: Any]]!
    
    init(n: String, f: String, i: String, h: [[String: Any]]) {
        name = n
        facilityURL = f
        imageURL = i
        hoursData = h
    }
    
    func getHours(helper: Helper) -> (String, Bool) {
        let formattedDate = helper.getDate()
        
        for day in hoursData {
            if day["date"] as! String == formattedDate {
                var s = ""
                var b = false
                let intervals = day["meal"]! as! [[String: String]]
                
                for i in 0..<intervals.count {
                    let interval = intervals[i]
                    let open = interval["open"]!.split(separator: ":")
                    let close = interval["close"]!.split(separator: ":")
                    if intervals.count == 1 {
                        s += helper.formatTime(open: open, close: close, lb: true)
                    } else {
                        s += helper.formatTime(open: open, close: close, lb: false)
                    }
                    if i < intervals.count - 1 { s += "  |  "}
                    b = b || helper.openNow(open: open, close: close)
                }
                
                return (s, b)
            }
        }
        
        return ("Closed Today", false)
    }
}
