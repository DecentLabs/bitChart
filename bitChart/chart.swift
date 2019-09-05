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
        data: Data
    ) -> SCIChartSurface {

    let dates = data.dates
    let bidPrices = data.bidPrices
    let askPrices = data.askPrices

    let xAxis = SCIDateTimeAxis()
    let yAxis = SCINumericAxis()
    
    let dateFormatter = DateFormatter()
    // csv format: 2018-03-16T00:53:18.2010346Z
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"

    // default visible x range
    let minXRange = dateFormatter.date(from: dates[dates.count / 3]) ?? nil
    let maxXRange = dateFormatter.date(from: dates[(dates.count / 3) * 2]) ?? nil
    xAxis.visibleRange = SCIDateRange(dateMin: minXRange, max: maxXRange)
    
    // xAxis.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
    xAxis.textFormatting = "dd MMM yyyy, HH:mm:ss"
    
    xAxis.axisTitle = "Date"
    yAxis.axisTitle = "Prices"
    
    let dataSeries_bids = SCIXyDataSeries(xType: .dateTime, yType: .float)
    let dataSeries_asks = SCIXyDataSeries(xType: .dateTime, yType: .float)
    
    
    for i in 0..<dates.count {
        let date = dates[i]
        let x: Date = dateFormatter.date(from: date) ?? Date() // todo
        let bid: Float = bidPrices[i]
        let ask: Float = askPrices[i]
        dataSeries_bids.appendX(SCIGeneric(x), y: SCIGeneric(bid))
        dataSeries_asks.appendX(SCIGeneric(x), y: SCIGeneric(ask))
    }
    
    
    let lineRenderSeries_bids = SCIFastLineRenderableSeries()
    lineRenderSeries_bids.strokeStyle = SCISolidPenStyle(colorCode: 0xffeb4034, withThickness: 0.5)
    lineRenderSeries_bids.dataSeries = dataSeries_bids
    
    let lineRenderSeries_asks = SCIFastLineRenderableSeries()
    lineRenderSeries_asks.strokeStyle = SCISolidPenStyle(colorCode: 0xff34bdeb, withThickness: 0.5)
    lineRenderSeries_asks.dataSeries = dataSeries_asks
    
    // Create an XAxis and YAxis. This step is mandatory before creating series
    sciChartSurface.xAxes.add(xAxis)
    sciChartSurface.yAxes.add(yAxis)
    sciChartSurface.renderableSeries.add(lineRenderSeries_bids)
    sciChartSurface.renderableSeries.add(lineRenderSeries_asks)
    
    // add pan and zoom modifiers
    sciChartSurface.chartModifiers = SCIChartModifierCollection(childModifiers: [
        SCIPinchZoomModifier(),
        SCIZoomPanModifier(),
        SCIZoomExtentsModifier()
    ])

    return sciChartSurface
}
