//
//  dateFormatter.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 04..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import Foundation

let dateFormatter = DateFormatter()

func stringToDate(string: String) -> Date {
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"  // csv format: 2018-03-16T00:53:18.2010346Z
    let date = dateFormatter.date(from: string)
    return (date ?? nil)!
}

func dateToTimestamp(date: Date) -> TimeInterval {
    return date.timeIntervalSince1970
}
