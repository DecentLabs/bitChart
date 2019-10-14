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

struct ChartProps {
    let width: Int32
    let height: Int32
    let minPrice: Int32
    let maxPrice: Int32
    var startDate: Int32
    let endDate: Int32
    var timeResolution: Int32
}

var exchangeData = [String: [OrderBook]]()

