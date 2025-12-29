//
//  Country.swift
//  Map
//
//  Created by elene malakmadze on 23.12.25.
//

import Foundation

struct Country: Decodable{
    let name: Name
    let capital: [String]
    let latlng: [Double]
    let capitalInfo: CapitalInfo
}




