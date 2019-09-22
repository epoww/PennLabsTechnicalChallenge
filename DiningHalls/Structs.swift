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
}
