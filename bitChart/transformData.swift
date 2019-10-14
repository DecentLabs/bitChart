//
//  transformData.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 03..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import Foundation


func updateExchangeData(_ row: [Any]) {
    
    func parseLimitOrder(row: ArraySlice<Any>, pos: Int, usd: Bool) -> LimitOrder {
        var floatP: Float = Float(row[pos] as! Double)
        let q = Float(row[pos + 1] as! Double)
        let _q = usd ? (q / floatP) : q
        floatP.round()
        let p = Int32(floatP)

        return LimitOrder(price: p, quantity: _q)
    }
    
    
    let count = row.count
    
    let name = row[0] as! String
    let usd = (name == "bitmex")
    let date = Date(timeIntervalSince1970: row[1] as! Double)

    let bidsData = row[3...202]
    let asksData = row[204..<count]


    var asks: [LimitOrder] = []
    asks.reserveCapacity(100)

    var bids: [LimitOrder] = []
    bids.reserveCapacity(100)
    
    for i in 0..<100 {
        let pos = i * 2
        let a = parseLimitOrder(row: asksData, pos: pos + 204, usd: usd)
        let b = parseLimitOrder(row: bidsData, pos: pos + 3, usd: usd)

        if (a.price > 0) {
            asks.append(a)
        }

        if (b.price > 0) {
            bids.append(b)
        }
    }

    let orderB = OrderBook(timestamp: date, bids: bids, asks: asks)
    exchangeData[name, default: []].append(orderB)
}

func parseTypes(row: [String]) -> [Any] {
    var result = [Any]()
    
    for item in row {
        if let n = Double(item) {
            result.append(n)
        } else {
            item.count > 0 ? result.append(item) : result.append(Double(0))
        }
    }
    return result
}
