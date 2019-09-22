
//
//  Helper.swift
//  DiningHalls
//
//  Created by Elizabeth Powell on 9/22/19.
//  Copyright © 2019 Elizabeth Powell. All rights reserved.
//

import Foundation

class Helper {
    
    //date formatted like in the json
    func getDate() -> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let formattedDate = format.string(from: date)
        return formattedDate
    }
    
    //date formatted to include the weekday
    func getDateWithDay() -> String {
        let formatter  = DateFormatter()
        formatter.dateFormat = "MMMM"
        let todayDate = formatter.string(from: Date())
        let weekDay = formatter.weekdaySymbols[Calendar.current.component(.weekday, from: Date())]
        let day = Calendar.current.component(.day, from: Date())
        let formattedDate = weekDay + ", " + todayDate + " " + String(day)
        return formattedDate.uppercased()
    }
    
    //format open - close intervals
    func formatTime(open: [Substring], close: [Substring], lb: Bool) -> String {
        var olb = "a"
        var clb = "a"
        
        var ohour = String(open[0])
        ohour = String(Int(ohour)!) //get rid of leading zeros
        
        if Int(ohour)! > 12 {
            ohour = String(Int(ohour)! - 12)
            olb = "p"
        }
        
        var chour = close[0].replacingOccurrences(of: "0", with: "")
        if Int(chour)! > 12 {
            chour = String(Int(chour)! - 12)
            clb = "p"
        }
        
        let formattedOpen = (ohour + ":" + open[1]).replacingOccurrences(of: ":00", with: "")
        let formattedClose = (chour + ":" + close[1]).replacingOccurrences(of: ":00", with: "")
        
        if lb {
            return formattedOpen + olb + " - " + formattedClose + clb
        }
        return formattedOpen + " - " + formattedClose
    }
    
    //determine if diningHall is currently open
    func openNow(open: [Substring], close: [Substring]) -> Bool {
        let date = Date()
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        let open_hour = Int(open[0])!
        let open_minute = Int(open[1])!
        let close_hour = Int(close[0])!
        let close_minute = Int(close[1])!
        
        if (components.hour! < open_hour) {
            return false
        } else if (components.hour! == open_hour) {
            if (open_minute >= components.minute!) {
                return true
            } else {
                return false
            }
        } else if (components.hour! < close_hour) {
            return true
        } else if (components.hour! == close_hour && components.minute! <= close_minute) {
            return true
        }
        
        return false
    }
}
