//
//  transformData.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 03..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import Foundation

struct LimitOrder {
    let price: Float
    let quantity: Float
}

struct OrderBook {
    let timestamp: Date
    let bids: [LimitOrder]
    let asks: [LimitOrder]
}

class ExchangeData {
    let name: String
    var orderBooks: [OrderBook] = []
    
    init(name: String) {
        self.name = name
    }
}

func getMultiStockData(stockNames: [String]) -> [ExchangeData] {
    
    let dataRows = parseCSV(fileName: "orderbook2")
    
    var stocks: [ExchangeData] = []
    
    for stock in stockNames {
        stocks.append(ExchangeData(name: stock))
    }
    
    
    let dataLength = 200
    let depth = dataLength / 2 - 1
    
    for row in dataRows {
        let name = row[0]
        let selectedStock = stocks.first(where: {$0.name == name})
        
        let timestamp = Double(row[1])
        let date = Date(timeIntervalSince1970: timestamp!)
        
        let bidsData = Array(row.dropFirst(3).dropLast(201))
        let asksData = Array(row.dropFirst(204))
        
        
        var asks: [LimitOrder] = []
        asks.reserveCapacity(dataLength / 2)
        
        var bids: [LimitOrder] = []
        bids.reserveCapacity(dataLength / 2)
        
        for i in 0...(depth) {
            asks.append(parseLimitOrder(row: asksData, pos: i * 2))
            bids.append(parseLimitOrder(row: bidsData, pos: i * 2))
        }
        
        selectedStock!.orderBooks.append(OrderBook(timestamp: date, bids: bids, asks: asks))
    }
    
    return stocks
}


func getData() -> [OrderBook] {

    var dataRows = parseCSV(fileName: "orderbook")

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
            asks.append(parseLimitOrder(row: row, pos: i * 2 + 2))
            bids.append(parseLimitOrder(row: row, pos: i * 2 + 4))
        }

        orderbooks.append(OrderBook(timestamp: timestamp, bids: bids, asks: asks))
    }

    return orderbooks
}


func parseLimitOrder(row: [String], pos: Int) -> LimitOrder {
    return LimitOrder(price: (row[pos] as NSString).floatValue,
                      quantity: (row[pos + 1] as NSString).floatValue)
}


func parseCSV(fileName: String) -> [[String]] {
    var data = readDataFromCSV(fileName: fileName, fileType: "csv")
    data = cleanRows(file: data!)
    let stringRows = data!.components(separatedBy: "\n")
    
    var dataRows: [[String]] = []
    
    for (i, row) in stringRows.enumerated() {
        let column = row.components(separatedBy: ",")
        if (i != 0) {
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
