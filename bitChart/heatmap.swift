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
                   data: [OrderBook]) -> SCIChartSurface {

    // dates
    let startDate = Int32(dateToTimestamp(date: data.first!.timestamp))
    let endDate = Int32(dateToTimestamp(date: data.last!.timestamp))
    let duration = endDate - startDate
    let timeResolution = Int32(60 * 60) // hourly
    let width = duration / timeResolution

    //prices
    let maxPrice = data.map({$0.asks.last!.price}).max()!
    let minPrice = data.map({$0.bids.last!.price}).min()!
    let priceRange = Int32(maxPrice - minPrice)

    print("size", width, priceRange)

    let heatmapDataSeries = SCIUniformHeatmapDataSeries(typeX: .int32,
                                                        y: .int32,
                                                        z: .double,
                                                        sizeX: width,
                                                        y: priceRange,
                                                        startX: SCIGeneric(startDate),
                                                        stepX: SCIGeneric(1),
                                                        startY: SCIGeneric(minPrice),
                                                        stepY: SCIGeneric(1))

    let zValues = heatmapDataSeries.zValues();

    var maxQuantity = 0.0
    for orderBook in data {
        let x = (Int32(dateToTimestamp(date: orderBook.timestamp)) - startDate) / timeResolution
        func plot(_ o: LimitOrder) {
            let y = Int32(o.price - minPrice)
            let q = Double(o.quantity)
            var currValue = zValues.valueAt(x: x, y: y).doubleData
            currValue += q
            maxQuantity = Double.maximum(maxQuantity, currValue)
            zValues.setValue(SCIGeneric(currValue), atX: x, y: y)
        }
        for o in orderBook.asks {
            plot(o)
        }
        for o in orderBook.bids {
            plot(o)
        }
    }

    print("max", maxQuantity)

    // Declare a Heatmap Render Series and set style
    let heatmapRenderableSeries = SCIFastUniformHeatmapRenderableSeries()
    heatmapRenderableSeries.minimum = 0
    heatmapRenderableSeries.maximum = 100 // FIXME: derive from maxQuantity
    heatmapRenderableSeries.dataSeries = heatmapDataSeries

    let xAxis = SCINumericAxis()
    xAxis.axisTitle = "Time"
    sciChartSurface.xAxes.add(xAxis)

    let yAxis = SCINumericAxis()
    yAxis.axisTitle = "Price"
    sciChartSurface.yAxes.add(yAxis)

    let stops = [0.0, 0.1, 1.0].map({NSNumber.init(value: $0)})
    let colors:[UIColor] = [.fromABGRColorCode(0x00000000), .blue, .white]

    heatmapRenderableSeries.colorMap = SCIColorMap.init(colors: colors, andStops: stops)

    sciChartSurface.renderableSeries.add(heatmapRenderableSeries)

    return sciChartSurface
    
}
