//
//  heatmap.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 04..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import Foundation
import SciChart

func createHeatmap(sciChartSurface: SCIChartSurface,
                   data: [OrderBook],
                   colors: [UIColor]) -> SCIChartSurface {

    // dates
    let startDate = Int32(dateToTimestamp(date: data.first!.timestamp))
    let endDate = Int32(dateToTimestamp(date: data.last!.timestamp))
    let duration = endDate - startDate
    let timeResolution = Int32(60 * 60) // hourly
    let width = duration / timeResolution
    
    print(duration)

    //prices
    let maxPrice = data.map({$0.asks.last!.price}).max()!
    let minPrice = data.map({$0.bids.last!.price}).min()!
    let height = Int32(maxPrice - minPrice)

    let heatmapDataSeries = SCIUniformHeatmapDataSeries(typeX: .int32,
                                                        y: .int32,
                                                        z: .double,
                                                        sizeX: width,
                                                        y: height,
                                                        startX: SCIGeneric(startDate),
                                                        stepX: SCIGeneric(timeResolution),
                                                        startY: SCIGeneric(minPrice),
                                                        stepY: SCIGeneric(1))

    let zValues = heatmapDataSeries.zValues();

    // clear
    let zero = SCIGeneric(0.0)
    for x in 0..<width {
        for y in 0..<height {
            zValues.setValue(zero, atX: x, y: y)
        }
    }

    // accumulate
    for orderBook in data {
        let x = (Int32(dateToTimestamp(date: orderBook.timestamp)) - startDate) / timeResolution
        func plot(_ o: LimitOrder) {
            let y = Int32(o.price - minPrice)
            let q = Double(o.quantity)
            var currValue = zValues.valueAt(x: x, y: y).doubleData
            currValue += q
            zValues.setValue(SCIGeneric(currValue), atX: x, y: y)
        }
        for o in orderBook.asks {
            plot(o)
        }
        for o in orderBook.bids {
            plot(o)
        }
    }

    // normalize with logarithm
    for x in 0..<width {
        for y in 0..<height {
            let currValue = zValues.valueAt(x: x, y: y).doubleData
            if (currValue > 0) {
                zValues.setValue(SCIGeneric(log(currValue + 1)), atX: x, y: y)
            }
        }
    }

    // Declare a Heatmap Render Series and set style
    let heatmapRenderableSeries = SCIFastUniformHeatmapRenderableSeries()
    heatmapRenderableSeries.minimum = 0
    heatmapRenderableSeries.maximum = 4 // FIXME: derive from max quantity
    heatmapRenderableSeries.dataSeries = heatmapDataSeries

    let stops = [0.0, 1.0].map({NSNumber.init(value: $0)})

    heatmapRenderableSeries.colorMap = SCIColorMap.init(colors: colors, andStops: stops)

    sciChartSurface.renderableSeries.add(heatmapRenderableSeries)

    return sciChartSurface
    
}
