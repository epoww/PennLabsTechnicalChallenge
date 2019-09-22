//
//  ViewController.swift
//  DiningHalls
//
//  Created by Elizabeth Powell on 9/19/19.
//  Copyright © 2019 Elizabeth Powell. All rights reserved.
//
import WebKit
import UIKit

var HEIGHT : CGFloat!
var WIDTH : CGFloat!

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WKNavigationDelegate {

    var DiningHalls = [DiningPlace]()
    var RetailDining = [DiningPlace]()
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return DiningHalls.count }
        return RetailDining.count
    }
    
    func formatTime(open: [Substring], close: [Substring], lb: Bool) -> String {
        var olb = "a"
        var clb = "a"
        
        var ohour = String(open[0])
        if (ohour.firstIndex(of: "0") != nil && ohour.firstIndex(of: "0")! == String.Index(encodedOffset: 0)) {
            ohour.remove(at: ohour.startIndex)
        }
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
    
    func openNow(open: [Substring], close: [Substring]) -> Bool {
        let date = Date()
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        let ohour = Int(open[0])!
        let chour = Int(close[0])!
        let cminute = Int(close[1])!
        
        if (components.hour! < ohour) {
            return false
        } else if (ohour == components.hour) {
            return true
        } else if (components.hour! < chour) {
            return true
        } else if (components.hour! == chour && components.minute! <= cminute) {
            return true
        }
        
        return false
    }
    
    func getHours(d: DiningPlace, data: [[String: Any]]) -> (String, Bool) {
        let formattedDate = getDate()
        
        print(d.name!)
        
        for day in data {
            if day["date"] as! String == formattedDate {
                var s = ""
                var b = false
                let intervals = day["meal"]! as! [[String: String]]
                
                for i in 0..<intervals.count {
                    let interval = intervals[i]
                    let open = interval["open"]!.split(separator: ":")
                    let close = interval["close"]!.split(separator: ":")
                    if intervals.count == 1 {
                        print("ONE TIME INTERVAL")
                        s += formatTime(open: open, close: close, lb: true)
                    } else {
                        s += formatTime(open: open, close: close, lb: false)
                    }
                    if i < intervals.count - 1 { s += "  |  "}
                    b = b || openNow(open: open, close: close)
                }
                
                return (s, b)
            }
        }
        
        return ("Closed Today", false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let diningHall: DiningPlace!
        if section == 0 { diningHall = DiningHalls[indexPath.item] }
        else { diningHall = RetailDining[indexPath.item] }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dining cell") as! DiningTableViewCell
        cell.name_lb.text = diningHall.name
        
        cell.img_v.backgroundColor = UIColor.lightGray
        if let url = URL(string: diningHall.imageURL) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print("error" + (error?.localizedDescription)!)
                }
                
                if data != nil {
                    let diningHallPic = UIImage(data: data!)
                    if diningHallPic != nil {
                        DispatchQueue.main.async(execute: {
                            cell.img_v.image = diningHallPic
                        })
                    }
                }
                
            }.resume()
        }
        
        var hours = ""
        var open = false
        (hours, open) = getHours(d: diningHall, data: diningHall.hoursData)
        cell.hours_lb.text = hours
        
        if open {
            cell.status_lb.text = "OPEN"
            cell.status_lb.textColor = UIColor.azure }
        else {
            cell.status_lb.text = "CLOSED"
            cell.status_lb.textColor = UIColor.greyish
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WIDTH * 0.32 / 1.5 + 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header_v = UIView()
        header_v.frame = CGRect(x: 0, y: 0, width: WIDTH, height: 54)
        header_v.backgroundColor = UIColor.white
        
        let title_lb = UILabel()
        title_lb.frame = CGRect(x: 14, y: 7, width: 200, height: 40)
        title_lb.font = UIFont(name: "Arial-BoldMT", size: 30)
        
        header_v.addSubview(title_lb)
        
        if section == 0 { title_lb.text = "Dining Halls" }
        else { title_lb.text = "Retail Dining" }
        
        return header_v
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    
    func getDate() -> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let formattedDate = format.string(from: date)
        return formattedDate
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let url: URL!
        if section == 0 {
            url = URL(string: DiningHalls[indexPath.item].facilityURL)
        } else {
            url = URL(string: RetailDining[indexPath.item].facilityURL)
        }
        
        selectedIndexPath = indexPath
        webv.load(URLRequest(url: url!))
        self.view.addSubview(webv)
        self.view.addSubview(activityIndicator)
        self.view.addSubview(close_btn)
        activityIndicator.startAnimating()
        
        webv.alpha = 0
        close_btn.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.webv.alpha = 1
            self.close_btn.alpha = 0.6
        }

    }
    
    func getData() {
        let urlString = "http://api.pennlabs.org/dining/venues"
        let url = URL(string: urlString)!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
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
                            self.DiningHalls.append(d)
                        } else {
                            self.RetailDining.append(d)
                        }
                    }

                    DispatchQueue.main.async {
                        self.tbv.reloadData()
                    }
                } else {
                    print("JSON is invalid")
                }
            }.resume()
    }

    let tbv = UITableView()
    let webv = WKWebView()
    var activityIndicator: UIActivityIndicatorView!
    var close_btn = UIButton()
    var selectedIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HEIGHT = self.view.frame.height
        WIDTH = self.view.frame.width
        
        tbv.frame = CGRect(x: 0, y: 75, width: WIDTH, height: HEIGHT - 75)
        tbv.register(DiningTableViewCell.self, forCellReuseIdentifier: "dining cell")
        
        tbv.dataSource = self
        tbv.delegate = self
        tbv.separatorStyle = .none
        
        self.view.addSubview(tbv)
        
        let date_lb = UILabel()
        date_lb.frame = CGRect(x: 14, y: 63, width: 200, height: 15)
        date_lb.font = UIFont(name: "Arial-BoldMT", size: 12)
        date_lb.textColor = UIColor.greyishTwo
        
        let formatter  = DateFormatter()
        formatter.dateFormat = "MMMM"
        let todayDate = formatter.string(from: Date())
        let weekDay = formatter.weekdaySymbols[Calendar.current.component(.weekday, from: Date())]
        let day = Calendar.current.component(.day, from: Date())
        let formattedDate = weekDay + ", " + todayDate + " " + String(day)
        date_lb.text = formattedDate.uppercased()
        self.view.addSubview(date_lb)
        
        getData()
        
        webv.navigationDelegate = self
        webv.frame = CGRect(x: 0, y: 0, width: WIDTH, height: HEIGHT)
        webv.allowsBackForwardNavigationGestures = true
        
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.center = self.view.center
        
        close_btn = UIButton()
        close_btn.frame = CGRect(x: 15, y: 35, width: 35, height: 35)
        close_btn.setTitle("x", for: .normal)
        close_btn.setTitleColor(UIColor.white, for: .normal)
        close_btn.titleLabel?.font = UIFont(name: "Arial-BoldMT", size: 20)
        close_btn.backgroundColor = UIColor.lightGray
        close_btn.alpha = 0.6
        close_btn.addTarget(self, action: #selector(closeWebView), for: .touchUpInside)
    }
    
    @objc func closeWebView() {
        close_btn.removeFromSuperview()
        webv.removeFromSuperview()
        webv.load(URLRequest(url: URL(string:"about:blank")!))
        tbv.deselectRow(at: selectedIndexPath, animated: true)
        UIView.animate(withDuration: 0.3) {
            self.webv.alpha = 0
            self.close_btn.alpha = 0
        }
    }
}

extension UIColor {
    @nonobjc class var black: UIColor {
        return UIColor(white: 31.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var azure: UIColor {
        return UIColor(red: 32.0 / 255.0, green: 156.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var greyish: UIColor {
        return UIColor(white: 169.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var greyishTwo: UIColor {
        return UIColor(white: 164.0 / 255.0, alpha: 1.0)
    }
    @nonobjc class var warmGrey: UIColor {
        return UIColor(white: 151.0 / 255.0, alpha: 1.0)
    }
}
