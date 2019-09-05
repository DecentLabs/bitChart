//
//  transformData.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 03..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import Foundation

struct Data {
    var dates: [Date]
    var askPrices: [Float]
    var bidPrices: [Float]
}

func getData() -> Data {
    
    var data = readDataFromCSV(fileName: "orderbook", fileType: "csv")
    data = cleanRows(file: data!)
    
    let dateFormatter = DateFormatter()
    // csv format: 2018-03-16T00:53:18.2010346Z
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"

    var askPrices: [Float] = []
    var bidPrices: [Float] = []
    var dates: [Date] = []
    
    let rows = data!.components(separatedBy: "\n")
    var counter = 0
    
    for row in rows {
        let columns = row.components(separatedBy: ",")
        
        if (counter != 0 && columns.count > 4) {
            askPrices.append((columns[2] as NSString).floatValue)
            bidPrices.append((columns[4] as NSString).floatValue)
            dates.append(dateFormatter.date(from: columns[1])!)
        }
        counter += 1
    }
    return Data(dates: dates, askPrices: askPrices, bidPrices: bidPrices)
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
