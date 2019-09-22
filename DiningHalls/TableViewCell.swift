//
//  TableViewCell.swift
//  DiningHalls
//
//  Created by Elizabeth Powell on 9/21/19.
//  Copyright © 2019 Elizabeth Powell. All rights reserved.
//

import UIKit

class DiningTableViewCell : UITableViewCell {
    
    var img_v: UIImageView!
    var status_lb: UILabel! {
        didSet {
            if status_lb.text == "CLOSED" {status_lb.textColor = UIColor.gray}
            else { status_lb.textColor = UIColor.blue}
        }
    }
    var name_lb: UILabel!
    var hours_lb: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        img_v = UIImageView()
        img_v.frame = CGRect(x: 14, y: 12, width: WIDTH * 0.32, height: WIDTH * 0.32 / 1.5)
        img_v.layer.cornerRadius = 7
        img_v.clipsToBounds = true
        img_v.contentMode = .scaleAspectFill
        addSubview(img_v)
        
        status_lb = UILabel()
        status_lb.frame = CGRect(x: img_v.frame.maxX + 14, y: 25, width: 200, height: 15)
        status_lb.font = UIFont(name: "Arial-BoldMT", size: 14)
        addSubview(status_lb)
        
        name_lb = UILabel()
        name_lb.frame = CGRect(x: status_lb.frame.minX, y: 41, width: 200, height: 25)
        name_lb.font = UIFont(name: "Arial", size: 20)
        addSubview(name_lb)
        
        hours_lb = UILabel()
        hours_lb.frame = CGRect(x: status_lb.frame.minX, y: 68, width: 200, height: 15)
        hours_lb.font = UIFont(name: "Avenir-Light", size: 14)
        addSubview(hours_lb)
        
        let arrow_lb = UILabel()
        arrow_lb.frame = CGRect(x: WIDTH - 20, y: WIDTH * 0.32 / 3, width: 20, height: 20)
        arrow_lb.font = UIFont(name: "Ariel-BoldMT", size: 60)
        arrow_lb.textColor = UIColor.darkGray
        arrow_lb.text = "〉"
        addSubview(arrow_lb)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
