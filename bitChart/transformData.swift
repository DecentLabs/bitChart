//
//  transformData.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 03..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import Foundation


func getData() -> [String: [String]] {
    
    var data = readDataFromCSV(fileName: "orderbook", fileType: "csv")
    data = cleanRows(file: data!)
    
    var askPrices: [String] = []
    var bidPrices: [String] = []
    var dates: [String] = []
    
    let rows = data!.components(separatedBy: "\n")
    var counter = 0
    
    for row in rows {
        let columns = row.components(separatedBy: ",")
        
        if (counter != 0 && columns.count > 4) {
            askPrices.append(columns[2])
            bidPrices.append(columns[4])
            dates.append(columns[1])
        }
        counter += 1
    }
    return [
        "askPrices": askPrices,
        "bidPrices": bidPrices,
        "dates": dates
    ]
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
