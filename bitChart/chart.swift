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
        data: [OrderBook]
    ) -> SCIChartSurface {
    
    let xAxis = SCIDateTimeAxis()
    xAxis.axisTitle = "Date"
    xAxis.visibleRange = SCIDateRange(dateMin: data.first?.timestamp, max: data.last?.timestamp)
    xAxis.textFormatting = "dd MMM yyyy, HH:mm:ss"
    sciChartSurface.xAxes.add(xAxis)

    let yAxis = SCINumericAxis()
    yAxis.axisTitle = "Prices"
    let minYRange = data.map({$0.bids.last!.price}).min()!
    let maxYRange = data.map({$0.asks.last!.price}).max()!
    yAxis.visibleRangeLimit = SCIDoubleRange(min: SCIGeneric(minYRange), max: SCIGeneric(maxYRange))
    sciChartSurface.yAxes.add(yAxis)
    
    return sciChartSurface
}


func addModifiers (sciChartSurface: SCIChartSurface) -> SCIChartSurface {
    // add pan and zoom modifiers
    sciChartSurface.chartModifiers = SCIChartModifierCollection(childModifiers: [
        SCIPinchZoomModifier(),
        SCIZoomPanModifier(),
        SCIZoomExtentsModifier()
    ])
    
    return sciChartSurface
}
