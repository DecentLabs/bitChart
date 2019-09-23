//
//  transformData.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 03..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

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

func getExchangeData() -> [String : [OrderBook]] {
    NSLog("transform data start")
    
    let dataRows = parseCSV(fileName: "orderbook2", cutFirst: false)
    NSLog("csv parsed")
    
    var exchangeData = [String: [OrderBook]]()
    
    let dataLength = 200
    let depth = dataLength / 2 - 1
    
    print(dataRows.count, "datarows count")
    
    NSLog("transform loop starts")
    for row in dataRows {
        let name = row[0]
        let usd = (name == "bitmex")
        
        let timestamp = Double(row[1])
        let date = Date(timeIntervalSince1970: timestamp!)
        
        let bidsData = Array(row.dropFirst(3).dropLast(201))
        let asksData = Array(row.dropFirst(204))
        
        
        var asks: [LimitOrder] = []
        asks.reserveCapacity(dataLength / 2)
        
        var bids: [LimitOrder] = []
        bids.reserveCapacity(dataLength / 2)
        
        
        for i in 0...(depth) {
            let pos = i * 2
            let a = parseLimitOrder(row: asksData, pos: pos, usd: usd)
            let b = parseLimitOrder(row: bidsData, pos: pos, usd: usd)

            
            // refact
            if (a.price > 0) {
                if let i = asks.firstIndex(where: { $0.price == a.price }) {
                    asks[i].quantity += a.quantity
                } else {
                    asks.append(a)
                }
            }
            
            if (b.price > 0) {
                if let i = bids.firstIndex(where: { $0.price == b.price }) {
                    bids[i].quantity += b.quantity
                } else {
                    bids.append(b)
                }
            }
        }
        
        exchangeData[name, default: []].append(OrderBook(timestamp: date, bids: bids, asks: asks))
    }
    
    NSLog("data transformed")
    return exchangeData
}


func parseLimitOrder(row: [String], pos: Int, usd: Bool) -> LimitOrder {
    var floatP: Float = (row[pos] as NSString).floatValue
    let q = (row[pos + 1] as NSString).floatValue
    let _q = usd ? (q / floatP) : q
    floatP.round()
    let p = Int32(floatP)
    
    return LimitOrder(price: p, quantity: _q)
}


func parseCSV(fileName: String, cutFirst: Bool) -> [[String]] {
    var data = readDataFromCSV(fileName: fileName, fileType: "csv")
    data = cleanRows(file: data!)
    let stringRows = data!.components(separatedBy: "\n")
    
    var dataRows: [[String]] = []
    
    for (i, row) in stringRows.enumerated() {
        let column = row.components(separatedBy: ",")
        if ((cutFirst == false) || (cutFirst == true && i != 0)) {
            dataRows.append(column)
        }
    }
    
    return dataRows
}


func readDataFromCSV(fileName:String, fileType: String) -> String! {
    guard let filePath = Bundle.main.path(forResource: fileName, ofType: fileType)
        else {
            return nil
    }
    do {
        var contents = try String(contentsOfFile: filePath, encoding: .utf8)
        contents = cleanRows(file: contents)
        return contents
    } catch {
        print("File read error for file \(filePath)")
        return nil
    }
}

func cleanRows(file:String) -> String {
    var cleanFile = file
    cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
    cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
    return cleanFile
}

// for older orderbook
func getData() -> [OrderBook] {
    
    let dataRows = parseCSV(fileName: "orderbook", cutFirst: true)
    
    let columns = dataRows[0].count;
    let depth = (columns - 2) / 4
    
    var orderbooks: [OrderBook] = []
    orderbooks.reserveCapacity(dataRows.count)
    
    for row in dataRows {
        
        if (row.count < columns) {
            continue;
        }
        
        let timestamp = stringToDate(string: row[1])
        
        var asks: [LimitOrder] = []
        asks.reserveCapacity(depth)
        
        var bids: [LimitOrder] = []
        bids.reserveCapacity(depth)
        
        for i in 0...depth {
            asks.append(parseLimitOrder(row: row, pos: i * 2 + 2, usd: false))
            bids.append(parseLimitOrder(row: row, pos: i * 2 + 4, usd: false))
        }
        
        orderbooks.append(OrderBook(timestamp: timestamp, bids: bids, asks: asks))
    }
    
    
    return orderbooks
}
