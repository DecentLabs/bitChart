//
//  heatmap.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 04..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//
//
// REFACT WIP

import Foundation
import SciChart

class Heatmap {
    var sciChartSurface: SCIChartSurface
    var _data: [String : [OrderBook]]
    var exchangeList: [String]
    
    var data: [String : [OrderBook]]?
    var heatmapDataSeries: SCIUniformHeatmapDataSeries?
    var heatmapRenderableSeries: SCIFastUniformHeatmapRenderableSeries?
    var zValues: SCIArrayController2D?
    var xAxis: SCINumericAxis?
    var yAxis: SCINumericAxis?
    
    let timeResolution = Int32(60 * 60) // hourly
    let zero = SCIGeneric(0.0)
    var maxZ = log(1.0)
    var width: Int32 = 0
    var height: Int32 = 0
    var startDate: Int32 = 0
    var minPrice: Float = 0.0
    
    init(sciChartSurface: SCIChartSurface, _data: [String : [OrderBook]], exchangeList: [String]) {
        self.sciChartSurface = sciChartSurface
        self._data = _data
        self.exchangeList = exchangeList
        self.data = _data.filter({exchangeList.contains($0.key)})
        
        self.setupDataSeries()
        self.createAxises()
        self.addModifiers()
        self.addEventListeners()
        
        self.render()
        
        self.createRenderableSeries()
        self.sciChartSurface.renderableSeries.add(heatmapRenderableSeries)
    }
    
    func render() {
        clear()
        accumulate()
        normalize()
    }
    
    func accumulate () {
        for (name, exchange) in data! {
            
            // loop in orderbook
            for orderBook in exchange {
                let x = (Int32(dateToTimestamp(date: orderBook.timestamp)) - startDate) / timeResolution
                
                func plot(_ o: LimitOrder) {
                    let y = Int32(o.price - minPrice)
                    let q = Double(o.quantity)
                    if (y > 0 || q > 0) {
                        var currValue = zValues!.valueAt(x: x, y: y).doubleData
                        currValue += q
                        zValues!.setValue(SCIGeneric(currValue), atX: x, y: y)
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
    }
    
    
    // normalize with logarithm
    func normalize () {
        for x in 0..<width {
            for y in 0..<height {
                let currValue = zValues!.valueAt(x: x, y: y).doubleData
                if (currValue > 0) {
                    let v = log(currValue + 1)
                    maxZ = v > maxZ ? v : maxZ
                    zValues!.setValue(SCIGeneric(v), atX: x, y: y)
                }
            }
        }
    }
    
    
    // Declare a Heatmap Render Series and set style
    func createRenderableSeries () {
        self.heatmapRenderableSeries = SCIFastUniformHeatmapRenderableSeries()
        heatmapRenderableSeries!.minimum = 0
        heatmapRenderableSeries!.maximum = maxZ
        heatmapRenderableSeries!.dataSeries = heatmapDataSeries
        
        // add colors
        //    let stops = [NSNumber(value: 0.0), NSNumber(value: 1)]
        //    let colors = [UIColor.fromARGBColorCode(0xFF000000)!,UIColor.fromARGBColorCode(0xFFc5c5c5)!]
        //    heatmapRenderableSeries.colorMap = SCIColorMap.init(colors: colors, andStops: stops)
    }
    
    
    func setupDataSeries () {
        self.getChartProps()
        self.heatmapDataSeries = SCIUniformHeatmapDataSeries(typeX: .int32,
                                                             y: .int32,
                                                             z: .double,
                                                             sizeX: width,
                                                             y: height,
                                                             startX: SCIGeneric(startDate),
                                                             stepX: SCIGeneric(timeResolution),
                                                             startY: SCIGeneric(minPrice),
                                                             stepY: SCIGeneric(20))
        self.zValues = heatmapDataSeries!.zValues()
    }
    
    // calculate heatmap props
    func getChartProps () {
        var startD: Int32 = 0
        var endD: Int32 = 0
        var minP: Float = 0.0
        var maxP: Float = 0.0
        
        for (key, _) in data! {
            let dates = getMinMaxDates(orderbook: data![key]!)
            let prices = getMinMaxPrice(orderbook: data![key]!)
            
            startD = dates["startDate"]! > startD ? dates["startDate"]! : startD
            endD = dates["endDate"]! > endD ? dates["endDate"]! : endD
            minP = prices["minPrice"]! > minP ? prices["minPrice"]! : minP
            maxP = prices["maxPrice"]! > maxP ? prices["maxPrice"]! : maxP
        }
        
        let duration = endD - startD
        
        width = duration / timeResolution
        height = Int32(maxP - minP)
        startDate = startD
        minPrice = minP
    }
    
    // create xy axis
    func createAxises () {
        self.xAxis = SCINumericAxis()
        self.xAxis!.axisTitle = "Time"
        self.sciChartSurface.xAxes.add(self.xAxis)
        
        self.yAxis = SCINumericAxis()
        self.yAxis!.axisTitle = "Price"
        self.sciChartSurface.yAxes.add(self.yAxis)
    }
    
    
    func addEventListeners () {
        // Register a VisibleRangeChanged callback
        self.xAxis!.registerVisibleRangeChangedCallback { (newRange, oldRange, isAnimated, sender) in
            let min = newRange!.min.doubleData
            let max = newRange!.max.doubleData
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("zoom", min, max)
            }
        }
    }
    
    
    // add chart modifiers (pan + zoom)
    func addModifiers () {
        self.sciChartSurface.chartModifiers = SCIChartModifierCollection(childModifiers: [
            SCIPinchZoomModifier(),
            SCIZoomPanModifier(),
            SCIZoomExtentsModifier()
        ])
    }
    
    
    // get date range
    func getMinMaxDates(orderbook: [OrderBook]) -> [String: Int32] {
        let startDate = Int32(dateToTimestamp(date: orderbook.first!.timestamp))
        let endDate = Int32(dateToTimestamp(date: orderbook.last!.timestamp))
        
        return ["startDate": startDate, "endDate": endDate]
    }
    
    
    // get price range
    func getMinMaxPrice(orderbook: [OrderBook]) -> [String: Float] {
        let maxPrice = orderbook.map({$0.asks.last!.price}).max()!
        let minPrice = orderbook.map({$0.bids.last!.price}).min()!
        
        return ["minPrice": minPrice, "maxPrice": maxPrice]
    }
    
    // clear
    func clear () {
        for x in 0..<self.width {
            for y in 0..<self.height {
                self.zValues!.setValue(zero, atX: x, y: y)
            }
        }
    }
}

