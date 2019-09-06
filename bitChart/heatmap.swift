//
//  heatmap.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 04..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import Foundation
import SciChart

// bids
func createHeatmap ( sciChartSurface: SCIChartSurface,
                     dates: [Date],
                     data: [[Float]],
                     bidPrices: [Float],
                     bidSizes: [Float] ) -> SCIChartSurface {
    
    let dataTypeNum = 4
    let bidSizeIndex = 3
    let bidPriceIndex = 2
    let count = data.count
    
    
    let WIDTH = Int32(500) // todo
    
    // dates
    let startDate = Int32(dateToTimestamp(date: dates[0]))
    let endDate = Int32(dateToTimestamp(date: dates[dates.count - 1]))
    let duration = endDate - startDate
    let stepX = duration / WIDTH
    
    //prices
    let maxPrice: Float = data[bidPriceIndex].max()!
    let lastIndex: Int = (count - 1) - (dataTypeNum - (bidPriceIndex + 1)) // todo
    let minPrice: Float = data[lastIndex].min()!
    let range = Int32(maxPrice - minPrice)
    
    let HEIGHT = range // todo
    
    let heatmapDataSeries = SCIUniformHeatmapDataSeries(typeX: .dateTime,
                                                        y: .int32,
                                                        z: .double,
                                                        sizeX: WIDTH,
                                                        y: HEIGHT,
                                                        startX: SCIGeneric(startDate),
                                                        stepX: SCIGeneric(stepX),
                                                        startY: SCIGeneric(minPrice),
                                                        stepY: SCIGeneric(1.0))

    
    
    // Access the 2D array of Z-values that the heatmap holds
    let zValues = heatmapDataSeries.zValues()
    // Populate the heatmap Z-values
    
    // bids - testing!!!
    for _i in 0..<WIDTH {
        let i = Int(_i)
        let zVal = Double(data[bidSizeIndex][i])
        let xVal = Int32(dateToTimestamp(date: dates[i]))
        let yVal = Int32(data[bidPriceIndex][i])
        zValues.setValue(SCIGeneric(zVal), atX: xVal, y: yVal)
    }
    print(zValues)
    // Declare a Heatmap Render Series
    let heatmapRenderableSeries = SCIFastUniformHeatmapRenderableSeries()
    heatmapRenderableSeries.minimum = 0
    heatmapRenderableSeries.maximum = 100000
    heatmapRenderableSeries.dataSeries = heatmapDataSeries
    

    // Add the Render Series to an existing SciChartSurface
    sciChartSurface.renderableSeries.add(heatmapRenderableSeries)
    
    return sciChartSurface
    
}
