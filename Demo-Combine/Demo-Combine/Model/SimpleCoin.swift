//
//  SimpleCoin.swift
//  Demo-Combine
//
//  Created by namtrinh on 09/11/2021.
//

import Foundation

struct SimpleCoin: Codable {
    let uuid: String
    let iconUrl: String
    let name: String
    let symbol: String
}

struct SimpleDataCoin: Codable {
    let coins: [SimpleCoin]
}

struct Response<T: Codable>: Codable {
    let status: String
    let data: T
}
