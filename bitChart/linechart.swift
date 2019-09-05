//
//  linechart.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 04..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import Foundation
import SciChart

func createLinechart (sciChartSurface: SCIChartSurface,
                      dates: [Date],
                      bidPrices: [Float],
                      askPrices: [Float]) -> SCIChartSurface {
    
    let dataSeries_bids = SCIXyDataSeries(xType: .dateTime, yType: .float)
    let dataSeries_asks = SCIXyDataSeries(xType: .dateTime, yType: .float)
    
    
    for i in 0..<dates.count {
        let date = dates[i]
        let x: Date = date // todo
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
    
    sciChartSurface.renderableSeries.add(lineRenderSeries_bids)
    sciChartSurface.renderableSeries.add(lineRenderSeries_asks)
    
    return sciChartSurface
}
