//
//  Name.swift
//  Map
//
//  Created by elene malakmadze on 29.12.25.
//

struct Name: Decodable {
    let common, official: String
    let nativeName: [String: Translation]
}
