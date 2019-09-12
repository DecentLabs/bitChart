//
//  heatmap.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 04..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import Foundation
import SciChart

func getMinMaxDates(orderbook: [OrderBook]) -> [String: Int32] {
    let startDate = Int32(dateToTimestamp(date: orderbook.first!.timestamp))
    let endDate = Int32(dateToTimestamp(date: orderbook.last!.timestamp))
    
    return ["startDate": startDate, "endDate": endDate]
}

func getMinMaxPrice(orderbook: [OrderBook]) -> [String: Float] {
    let maxPrice = orderbook.map({$0.asks.last!.price}).max()!
    let minPrice = orderbook.map({$0.bids.last!.price}).min()!
    
    return ["minPrice": minPrice, "maxPrice": maxPrice]
}

func getChartProps (data: [String : [OrderBook]], timeResolution: Int32) -> [String: Any] {
    var startDate: Int32 = 0
    var endDate: Int32 = 0
    var minPrice: Float = 0.0
    var maxPrice: Float = 0.0
    
    for (key, _) in data {
        let dates = getMinMaxDates(orderbook: data[key]!)
        let prices = getMinMaxPrice(orderbook: data[key]!)
        
        startDate = dates["startDate"]! > startDate ? dates["startDate"]! : startDate
        endDate = dates["endDate"]! > endDate ? dates["endDate"]! : endDate
        minPrice = prices["minPrice"]! > minPrice ? prices["minPrice"]! : minPrice
        maxPrice = prices["maxPrice"]! > maxPrice ? prices["maxPrice"]! : maxPrice
    }
    
    let duration = endDate - startDate
    
    let width = duration / timeResolution
    let height = Int32(maxPrice - minPrice)
    
    
    return [
        "width": width,
        "height": height,
        "minPrice": minPrice,
        "startDate": startDate
    ]
}


func createHeatmap(sciChartSurface: SCIChartSurface,
                   data: [String : [OrderBook]]) -> SCIChartSurface {
    
    let timeResolution = Int32(60 * 60) // hourly
    
    let chartProps = getChartProps(data: data, timeResolution: timeResolution)
    let width = chartProps["width"]! as! Int32
    let height = chartProps["height"]! as! Int32
    let startDate = chartProps["startDate"]! as! Int32
    let minPrice = chartProps["minPrice"]! as! Float
    

    let heatmapDataSeries = SCIUniformHeatmapDataSeries(typeX: .int32,
                                                        y: .int32,
                                                        z: .double,
                                                        sizeX: width,
                                                        y: height,
                                                        startX: SCIGeneric(startDate),
                                                        stepX: SCIGeneric(timeResolution),
                                                        startY: SCIGeneric(minPrice),
                                                        stepY: SCIGeneric(20))

    let zValues = heatmapDataSeries.zValues();
    let zero = SCIGeneric(0.0)
    // clear
    for x in 0..<width {
        for y in 0..<height {
            zValues.setValue(zero, atX: x, y: y)
        }
    }

    // accumulate
    for (name, exchange) in data {
        
        // loop in orderbook
        for orderBook in exchange {
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
        
    }

    // normalize with logarithm
    var maxZ = log(1.0)
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
//    let stops = [NSNumber(value: 0.0), NSNumber(value: 1)]
//    let colors = [UIColor.fromARGBColorCode(0xFF000000)!,UIColor.fromARGBColorCode(0xFFc5c5c5)!]
//    heatmapRenderableSeries.colorMap = SCIColorMap.init(colors: colors, andStops: stops)
    
    
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
    
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("zoom", min, max)
        }
    }
    
    // add chart modifiers (pan + zoom)
    sciChartSurface.chartModifiers = SCIChartModifierCollection(childModifiers: [
        SCIPinchZoomModifier(),
        SCIZoomPanModifier(),
        SCIZoomExtentsModifier()
    ])

    sciChartSurface.renderableSeries.add(heatmapRenderableSeries)
    
    return sciChartSurface
}
