//
//  transformData.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 03..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import Foundation

struct Result {
    let dates: [Date]
    let data: [[Float]]
}

func getData() -> Result {
    
    // parse csv
    var data = readDataFromCSV(fileName: "orderbook", fileType: "csv")
    data = cleanRows(file: data!)
    let stringRows = data!.components(separatedBy: "\n")
    
    var dataRows: [[String]] = []
    
    for (i, row) in stringRows.enumerated() {
        let column = row.components(separatedBy: ",")
        if (i != 0) {
            dataRows.append(column)
        }
    }
    
    let count = dataRows[0].count
    let empty : [Float] = []
    var dates: [Date] = []
    var floats = Array(repeating: empty, count: count - 2)
    
    
    // sort by columns
    for r in dataRows {
        for (i, c) in r.enumerated() {
            // separate float data
            if (i > 1) {
                let data = (c as NSString).floatValue
                floats[i-2].append(data)
            }
            // separate dates
            if (i == 1) {
                let d = stringToDate(string: c)
                dates.append(d)
            }
        }
    }
    
    
    let result = Result(dates: dates, data: floats)
    return result
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
