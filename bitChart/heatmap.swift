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
    
    
    
    let WIDTH = Int32(500)
    let HEIGHT = Int32(20)
    let heatmapDataSeries = SCIUniformHeatmapDataSeries(typeX: .double,
                                                        y: .double,
                                                        z: .double,
                                                        sizeX: WIDTH,
                                                        y: HEIGHT,
                                                        startX: SCIGeneric(0.0),
                                                        stepX: SCIGeneric(1.0),
                                                        startY: SCIGeneric(0.0),
                                                        stepY: SCIGeneric(1.0))
    
    // Access the 2D array of Z-values that the heatmap holds
    let zValues = heatmapDataSeries.zValues()
    // Populate the heatmap Z-values
    
    // bids - testing!!!
    var x = 0
    for i in 0..<WIDTH {
        var y = 3
        for j in 0..<HEIGHT {
            zValues.setValue(SCIGeneric(Double(data[y][x])), atX: i, y: j)
            y += 4
        }
        x += 1
    }
    // Declare a Heatmap Render Series and set style
    let heatmapRenderableSeries = SCIFastUniformHeatmapRenderableSeries()
    heatmapRenderableSeries.minimum = 0
    heatmapRenderableSeries.maximum = 100
    heatmapRenderableSeries.dataSeries = heatmapDataSeries

    // Add the Render Series to an existing SciChartSurface
    sciChartSurface.renderableSeries.add(heatmapRenderableSeries)
    
    return sciChartSurface
    
}
