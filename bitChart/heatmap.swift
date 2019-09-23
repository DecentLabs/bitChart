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
    
    private let zero = SCIGeneric(0.0)
    
    var data: [String : [OrderBook]]?
    var heatmapDataSeries: SCIUniformHeatmapDataSeries?
    var heatmapRenderableSeries: SCIFastUniformHeatmapRenderableSeries?
    var zValues: SCIArrayController2D?
    var xAxis: SCINumericAxis?
    var yAxis: SCINumericAxis?
    var _timer: Timer?
    var loaded = false
    
    var timeResolution = Int32(60 * 60) // hourly
    var maxZ: Double = 0
    var width: Int32 = 0
    var height: Int32 = 0
    var startDate: Int32 = 0
    var minPrice: Int32 = 0
    var endDate: Int32 = 0
    var maxPrice: Int32 = 0
    
    init(sciChartSurface: SCIChartSurface, _data: [String : [OrderBook]], exchangeList: [String]) {
        NSLog("init heatmap")
        self.sciChartSurface = sciChartSurface
        self._data = _data
        self.exchangeList = exchangeList
        self.data = _data.filter({exchangeList.contains($0.key)})
    }
    
    func start () {
        SCIUpdateSuspender.usingWithSuspendable(sciChartSurface) {
            NSLog("1")
            self.setupDataSeries()
            NSLog("2")
            self.createAxises()
            NSLog("3")
            self.addModifiers()
            NSLog("4")
            
            self.render()
            NSLog("5")
            self.addEventListeners()
            NSLog("6")
            
            self.createRenderableSeries()
            NSLog("7")
            self.sciChartSurface.renderableSeries.add(self.heatmapRenderableSeries)
            NSLog("8")
        }
    }
    
    func filterData(list: [String]) {
        exchangeList = list
        data = _data.filter({exchangeList.contains($0.key)})
    }
    
    private func setupDataSeries () {
        getChartProps()
        heatmapDataSeries = SCIUniformHeatmapDataSeries(typeX: .int32,
                                                        y: .int32,
                                                        z: .double,
                                                        sizeX: width,
                                                        y: height,
                                                        startX: SCIGeneric(startDate),
                                                        stepX: SCIGeneric(timeResolution),
                                                        startY: SCIGeneric(minPrice),
                                                        stepY: SCIGeneric(1))
        zValues = heatmapDataSeries!.zValues()
    }
    
    // create xy axis
    private func createAxises () {
        xAxis = SCINumericAxis()
        xAxis!.axisTitle = "Time"
        xAxis?.visibleRangeLimit = SCIIntegerRange(min: SCIGeneric(startDate), max: SCIGeneric(endDate)) // todo
        sciChartSurface.xAxes.add(xAxis)
        
        yAxis = SCINumericAxis()
        yAxis!.axisTitle = "Price"
//        yAxis?.autoRange = .always
         yAxis?.visibleRangeLimit = SCIDoubleRange(min: SCIGeneric(minPrice), max: SCIGeneric(maxPrice))
        sciChartSurface.yAxes.add(yAxis)
    }
    
    // add chart modifiers (pan + zoom)
    private func addModifiers () {
        sciChartSurface.chartModifiers = SCIChartModifierCollection(childModifiers: [
            SCIPinchZoomModifier(),
            SCIZoomPanModifier(),
            SCIZoomExtentsModifier()
            ])
    }

    private func accumulate () {
        NSLog("accumulate started")
        for (name, exchange) in data! {
            
            // loop in orderbook
            for orderBook in exchange {
                let x = (Int32(dateToTimestamp(date: orderBook.timestamp)) - startDate) / timeResolution
                
                func plot(_ o: LimitOrder) {
                    let y = Int32(o.price - minPrice)
                    let q = Double(o.quantity)
                    if (y >= 0 || q > 0) {
                        var currValue = zValues!.valueAt(x: x, y: y).doubleData
                        currValue += q
                        heatmapDataSeries?.updateZ(atXIndex: x, yIndex: y, withValue: SCIGeneric(currValue))
                        
                    }
                }
                
                
                if (x >= 0 && x <= width) {
                    for o in orderBook.asks {
                        plot(o)
                    }
                    for o in orderBook.bids {
                        plot(o)
                    }
                }
            }
            
        }
    }
    
    
    // getmax wip todo
    private func getMax () {
        NSLog("getmax")
        maxZ = Double(0)
        for x in 0..<width {
            for y in 0..<height {
                let currValue = zValues!.valueAt(x: x, y: y).doubleData
                maxZ = currValue > maxZ ? currValue : maxZ
            }
        }
        heatmapRenderableSeries?.maximum = maxZ / 2
    }
    
    
    // Declare a Heatmap Render Series and set style
    private func createRenderableSeries () {
        heatmapRenderableSeries = SCIFastUniformHeatmapRenderableSeries()
        heatmapRenderableSeries!.minimum = Double(0)
        heatmapRenderableSeries!.maximum = maxZ / 2
        heatmapRenderableSeries!.dataSeries = heatmapDataSeries
        
         //add colors
        let stops = [NSNumber(value: 0.0), NSNumber(value: 1)]
        let colors = [UIColor.fromARGBColorCode(0xFF000000)!,UIColor.fromARGBColorCode(0xFFffffff)!]
        heatmapRenderableSeries!.colorMap = SCIColorMap.init(colors: colors, andStops: stops)
    }
    

    
    private func addEventListeners () {
        // Register a VisibleRangeChanged callback
        
        xAxis!.registerVisibleRangeChangedCallback { (newRange, oldRange, isAnimated, sender) in
            
            if self.loaded {
                let min = Int32(newRange!.min.doubleData)
                let max = Int32(newRange!.max.doubleData)
                let duration = Int32(max - min)
                
                self.timeResolution = duration / self.width
                self.startDate = min
                self.endDate = max

                self._timer?.invalidate()
                self._timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
                    self.render()
                }
            }
            
            self.loaded = true
        }
    }
    
    func render () {
//        DispatchQueue(label: "recalc").async {
            SCIUpdateSuspender.usingWithSuspendable(self.sciChartSurface, with: {
                self.clear()
                self.heatmapDataSeries?.startX = SCIGeneric(self.startDate)
                self.heatmapDataSeries?.stepX = SCIGeneric(self.timeResolution)
                self.accumulate()
                // self.normalize()
                 self.getMax()
            })
//        }
    }
    
    
    // calculate heatmap props
    private func getChartProps () {
        var startD: Int32 = 0
        var endD: Int32 = 0
        var minP: Int32 = 0
        var maxP: Int32 = 0
        
        for (key, _) in data! {
            let dates = getMinMaxDates(orderbook: data![key]!)
            let prices = getMinMaxPrice(orderbook: data![key]!)
            
            startD = startD == 0 ? dates["startDate"]! : dates["startDate"]! < startD ? dates["startDate"]! : startD
            endD = dates["endDate"]! > endD ? dates["endDate"]! : endD
            minP = minP == 0 ? prices["minPrice"]! : prices["minPrice"]! < minP ? prices["minPrice"]! : minP
            maxP = prices["maxPrice"]! > maxP ? prices["maxPrice"]! : maxP
        }
        
        let duration = endD - startD
        
        width = duration / timeResolution
        height = Int32(maxP - minP)
        startDate = startD
        minPrice = minP
        endDate = endD
        maxPrice = maxP
    }
    
    
    // get date range
    private func getMinMaxDates(orderbook: [OrderBook]) -> [String: Int32] {
        let startDate = Int32(dateToTimestamp(date: orderbook.first!.timestamp))
        let endDate = Int32(dateToTimestamp(date: orderbook.last!.timestamp))
        
        return ["startDate": startDate, "endDate": endDate]
    }
    
    
    // get price range
    private func getMinMaxPrice(orderbook: [OrderBook]) -> [String: Int32] {
        let maxPrice = orderbook.map({$0.asks.last!.price}).max()!
        let minPrice = orderbook.map({$0.bids.last!.price}).min()!
        
        return ["minPrice": minPrice, "maxPrice": maxPrice]
    }
    

    
    // clear
    private func clear () {
        NSLog("clear started")
        for x in 0..<width {
            for y in 0..<height {
                heatmapDataSeries?.updateZ(atXIndex: x, yIndex: y, withValue: zero)
            }
        }
    }
}

    // normalize with logarithm
//    private func normalize () {
//        for x in 0..<width {
//            for y in 0..<height {
//                let currValue = zValues!.valueAt(x: x, y: y).doubleData
//                if (currValue > 0) {
//                    let v = log(currValue + 1)
//                    maxZ = v > maxZ ? v : maxZ
//                    heatmapDataSeries?.updateZ(atXIndex: x, yIndex: y, withValue: SCIGeneric(v))
//                }
//            }
//        }
//    }
