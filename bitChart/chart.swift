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
        dates: [Date],
        bidPrices: [Float],
        askPrices: [Float]
    ) -> SCIChartSurface {
    
    let xAxis = SCIDateTimeAxis()
    let yAxis = SCINumericAxis()

    // default visible x range
    xAxis.visibleRange = SCIDateRange(dateMin: dates.first, max: dates.last)
    
    // default visible y range
    let minYRange = bidPrices.min()!
    let maxYRange = bidPrices.max()!
    yAxis.visibleRangeLimit = SCIDoubleRange(min: SCIGeneric(minYRange), max: SCIGeneric(maxYRange))
    

    xAxis.textFormatting = "dd MMM yyyy, HH:mm:ss"
    xAxis.axisTitle = "Date"
    yAxis.axisTitle = "Prices"
    
    // Create an XAxis and YAxis. This step is mandatory before creating series
    sciChartSurface.xAxes.add(xAxis)
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
