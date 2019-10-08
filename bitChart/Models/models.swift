//
//  dataControllerDelegate.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 26..
//  Copyright © 2019. brigitta forrai. All rights reserved.


import Foundation

struct LimitOrder {
    let price: Int32
    var quantity: Float
}

struct OrderBook {
    let timestamp: Date
    let bids: [LimitOrder]
    let asks: [LimitOrder]
}

var exchangeData = [String: [OrderBook]]()

