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
    let startDate = Int32(dateToTimestamp(date: (data.first!.timestamp)))
    let endDate = Int32(dateToTimestamp(date: (data.last!.timestamp)))
    let duration = endDate - startDate
    let timeResolution = Int32(60 * 60) // hourly
    let width = duration / timeResolution


        //prices
    let maxPrice = data.map({$0.asks.last!.price}).max()!
    let minPrice = data.map({$0.bids.last!.price}).min()!
    let height = Int32(maxPrice - minPrice)
    
    print(width, height)
    print(minPrice, maxPrice)

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
            if (y > 0 || q > 0) {
                var currValue = zValues.valueAt(x: x, y: y).doubleData
                currValue += q
                zValues.setValue(SCIGeneric(currValue), atX: x, y: y)
            }
        }
        for o in orderBook.asks {
            plot(o)
        }
        for o in orderBook.bids {
            plot(o)
        }
    }

    var maxZ = log(1.0)
    // normalize with logarithm
    for x in 0..<width {
        for y in 0..<height {
            let currValue = zValues.valueAt(x: x, y: y).doubleData
            if (currValue > 0) {
                let v = log(currValue + 1)
                maxZ = v > maxZ ? v : maxZ
                zValues.setValue(SCIGeneric(v), atX: x, y: y)
            }
        }
    }

    // Declare a Heatmap Render Series and set style
    let heatmapRenderableSeries = SCIFastUniformHeatmapRenderableSeries()
    heatmapRenderableSeries.minimum = 0
    heatmapRenderableSeries.maximum = maxZ
    heatmapRenderableSeries.dataSeries = heatmapDataSeries

    // add colors
    let stops = [NSNumber(value: 0.0), NSNumber(value: 0.2), NSNumber(value: 0.4), NSNumber(value: 0.6), NSNumber(value: 0.8), NSNumber(value: 1.0)]
    let colors = [UIColor.fromARGBColorCode(0xFF00008B)!, UIColor.fromARGBColorCode(0xFF6495ED)!, UIColor.fromARGBColorCode(0xFF006400)!, UIColor.fromARGBColorCode(0xFF7FFF00)!, UIColor.fromARGBColorCode(0xFFFFFF00)!, UIColor.fromARGBColorCode(0xFFFF0000)!]

    heatmapRenderableSeries.colorMap = SCIColorMap.init(colors: colors, andStops: stops)
    
    
    // create xy axis
    let xAxis = SCINumericAxis()
    xAxis.axisTitle = "Time"
    sciChartSurface.xAxes.add(xAxis)
    
    let yAxis = SCINumericAxis()
    yAxis.axisTitle = "Price"
    sciChartSurface.yAxes.add(yAxis)
    
    
    // Register a VisibleRangeChanged callback
    xAxis.registerVisibleRangeChangedCallback { (newRange, oldRange, isAnimated, sender) in
        let min = newRange!.min.doubleData
        let max = newRange!.max.doubleData
        print(min, max)
    }

    
    sciChartSurface.renderableSeries.add(heatmapRenderableSeries)
    return sciChartSurface
    
}
