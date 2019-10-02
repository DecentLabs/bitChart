//
//  series.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 10. 01..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import Foundation
import SciChart


class Heatmap {
    var data: [String : [OrderBook]]?
    private let zero = SCIGeneric(0.0)
    
    var width: Int32 = 0
    var height: Int32 = 0
    var startDate: Int32 = 0
    var minPrice: Int32 = 0
    var endDate: Int32 = 0
    var maxPrice: Int32 = 0
    var timeResolution = Int32(60 * 60) // hourly
    
    var heatmapDataSeries: SCIUniformHeatmapDataSeries?
    var heatmapRenderableSeries: SCIFastUniformHeatmapRenderableSeries?
    var zValues: SCIArrayController2D?
    var maxZ: Double = 0
    
    var shouldUpdate: Bool = true // todo setter/ getter ?
    var isUpdated: Bool = false
    
    init(data: [String : [OrderBook]]) {
        self.data = data
    }
    
    func updateData(data: [String : [OrderBook]]) {
        self.data = data
    }
    
    func setUpdate(update: Bool) {
        shouldUpdate = update
    }
    
    func create () {
        isUpdated = false
        
        // TODO guards just for testing
        guard shouldUpdate else {
            print("STOP")
            return
        }
        setupDataSeries()
        
        guard shouldUpdate else {
            print("STOP")
            return
        }
        clear()
        
        guard shouldUpdate else {
            print("STOP")
            return
        }
        accumulate()
        
        guard shouldUpdate else {
            print("STOP")
            return
        }
        getMax()
        
        guard shouldUpdate else {
            print("STOP")
            return
        }
        createRenderableSeries()
    }
    
    func setupDataSeries() {
        print("BEGIN")
        print("setupDataSeries")
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
    
    // Declare a Heatmap Render Series and set style
    func createRenderableSeries () {
        NSLog("renderableSeries started")
        heatmapRenderableSeries = SCIFastUniformHeatmapRenderableSeries()
        heatmapRenderableSeries!.minimum = Double(0)
        heatmapRenderableSeries!.maximum = maxZ / 2 // todo getYmax
        heatmapRenderableSeries!.dataSeries = heatmapDataSeries
        
        
                
         //add colors
        let stops = [NSNumber(value: 0.0), NSNumber(value: 1)]
        let colors = [UIColor.fromARGBColorCode(0xFF000000)!,UIColor.fromARGBColorCode(0xFFffffff)!]
        heatmapRenderableSeries!.colorMap = SCIColorMap.init(colors: colors, andStops: stops)
        
        isUpdated = true
        print("END")
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
    
    func getChartProps () {
        
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
    
    // clear
    private func clear () {
        NSLog("clear started")
        for x in 0..<width {
            for y in 0..<height {
                heatmapDataSeries?.updateZ(atXIndex: x, yIndex: y, withValue: zero)
            }
        }
    }
    
    
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
    
}




//    //normalize with logarithm
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
