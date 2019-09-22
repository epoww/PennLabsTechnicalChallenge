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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var helper = Helper()
    var networkManager = NetworkManager()
    
    var DiningHalls = [DiningPlace]() {
        didSet {
            DispatchQueue.main.async {
                self.tbv.reloadData()
            }
        }
    }
    
    var RetailDining = [DiningPlace]() {
        didSet {
            DispatchQueue.main.async {
                self.tbv.reloadData()
            }
        }
    }
    
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let diningHall: DiningPlace!
        
        if section == 0 { diningHall = DiningHalls[indexPath.item] }
        else { diningHall = RetailDining[indexPath.item] }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dining cell") as! DiningTableViewCell
        
        cell.name_lb.text = diningHall.name
        cell.img_v.backgroundColor = UIColor.lightGray
        
        if let url = URL(string: diningHall.imageURL) {
            networkManager.getImage(url: url, completionHandler: {
                image in
                DispatchQueue.main.async(execute: {
                    cell.img_v.image = image
                })
            })
        }
        
        var hours = ""
        var open = false
        (hours, open) = diningHall.getHours(helper: helper)
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

    let tbv = UITableView()
    let webv = WKWebView()
    let date_lb = UILabel()
    var activityIndicator = UIActivityIndicatorView()
    var close_btn = UIButton()
    var selectedIndexPath = IndexPath()
    
    override func viewWillAppear(_ animated: Bool) {
        date_lb.text = helper.getDateWithDay()
        
        if let url = URL(string: "http://api.pennlabs.org/dining/venues") {
            networkManager.getData(url: url, completionHandler: {
                (diningHall, retailDining) in
                (self.DiningHalls, self.RetailDining) = (diningHall, retailDining)
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HEIGHT = self.view.frame.height
        WIDTH = self.view.frame.width
        
        tbv.frame = CGRect(x: 0, y: 75, width: WIDTH, height: HEIGHT - 75)
        tbv.separatorStyle = .none
        tbv.register(DiningTableViewCell.self, forCellReuseIdentifier: "dining cell")
        tbv.dataSource = self
        tbv.delegate = self
        self.view.addSubview(tbv)
        
        date_lb.frame = CGRect(x: 14, y: 63, width: 200, height: 15)
        date_lb.font = UIFont(name: "Arial-BoldMT", size: 12)
        date_lb.textColor = UIColor.greyishTwo
        self.view.addSubview(date_lb)
        
        webv.frame = CGRect(x: 0, y: 0, width: WIDTH, height: HEIGHT)
        
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
        activityIndicator.stopAnimating()
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
