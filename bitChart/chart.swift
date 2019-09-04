//
//  chart.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 03..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import Foundation
import SciChart

func setChart (
        sciChartSurface: SCIChartSurface,
        dates: [String],
        bidPrices: [String],
        askPrices: [String]
    ) -> SCIChartSurface {
    
    let xAxis = SCIDateTimeAxis()
    let yAxis = SCINumericAxis()
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"  // csv format: 2018-03-16T00:53:18.2010346Z
    
    // todo
    //let minXRange = dateFormatter.date(from: dates[0]) ?? nil
    //let maxXRange = dateFormatter.date(from: dates[dates.count - 1]) ?? nil
    //xAxis.visibleRange = SCIDateRange(dateMin: minXRange, max: maxXRange)
    
    // xAxis.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
    xAxis.textFormatting = "dd MMM yyyy, HH:mm:ss"
    
    xAxis.axisTitle = "Date"
    yAxis.axisTitle = "Bid Prices"
    
    let dataSeries = SCIXyDataSeries(xType: .dateTime, yType: .float)
    
    
    for i in 0..<dates.count {
        let date = dates[i]
        let x: Date = dateFormatter.date(from: date) ?? Date() // todo
        let y: Float = (bidPrices[i] as NSString).floatValue
        dataSeries.appendX(SCIGeneric(x), y: SCIGeneric(y))
    }
    
    
    let lineRenderSeries = SCIFastLineRenderableSeries()
    lineRenderSeries.strokeStyle = SCISolidPenStyle(colorCode: 0xff279b27, withThickness: 1.0)
    lineRenderSeries.dataSeries = dataSeries
    
    // Create an XAxis and YAxis. This step is mandatory before creating series
    sciChartSurface.xAxes.add(xAxis)
    sciChartSurface.yAxes.add(yAxis)
    sciChartSurface.renderableSeries.add(lineRenderSeries)

    return sciChartSurface
}
