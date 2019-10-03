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
    let zero = SCIGeneric(0.0)
    
    var heatmapDataSeries: SCIUniformHeatmapDataSeries?
    var heatmapRenderableSeries: SCIFastUniformHeatmapRenderableSeries?
    var zValues: SCIArrayController2D?
    var maxZ: Double = 0
    
    var props: ChartProps?
    var timeResolution: Int32
    
    var shouldUpdate: Bool = true
    var isUpdated: Bool = false
    
    
    init(data: [String : [OrderBook]], props: ChartProps, res: Int32) {
        self.data = data
        self.props = props
        self.timeResolution = res
    }
    
    func updateData(data: [String : [OrderBook]]) {
        self.data = data
    }
    
    func create () {
        print("BEGIN")
        self.isUpdated = false

        if shouldUpdate { setupDataSeries() } else {
            print("STOP")
            return
        }
        
        if shouldUpdate { clear() } else {
            print("STOP")
            return
        }

        if shouldUpdate { accumulate() } else {
            print("STOP")
            return
        }
        
        if shouldUpdate { getMax() } else {
            print("STOP")
            return
        }
        
        if shouldUpdate {
            createRenderableSeries()
            isUpdated = true
        } else {
            print("STOP")
            return
        }
    }
    
    func setupDataSeries() {
        print("setupDataSeries")
        heatmapDataSeries = SCIUniformHeatmapDataSeries(typeX: .int32,
                                                        y: .int32,
                                                        z: .double,
                                                        sizeX: props!.width,
                                                        y: props!.height,
                                                        startX: SCIGeneric(props!.startDate),
                                                        stepX: SCIGeneric(timeResolution),
                                                        startY: SCIGeneric(props!.minPrice),
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
        print("END")
    }
    
    func accumulate () {
       NSLog("accumulate started")
       for (name, exchange) in data! {

           // loop in orderbook
           for orderBook in exchange {
            let x = (Int32(dateToTimestamp(date: orderBook.timestamp)) - props!.startDate) / timeResolution
               
               func plot(_ o: LimitOrder) {
                let y = Int32(o.price - props!.minPrice)
                   let q = Double(o.quantity)
                   if (y >= 0 || q > 0) {
                       var currValue = zValues!.valueAt(x: x, y: y).doubleData
                       currValue += q
                       heatmapDataSeries?.updateZ(atXIndex: x, yIndex: y, withValue: SCIGeneric(currValue))
                   }
               }
               
            if (x >= 0 && x <= props!.width) {
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
    
    
    func getMax () {
        NSLog("getmax")
        maxZ = Double(0)
        for x in 0..<props!.width {
            for y in 0..<props!.height {
                let currValue = zValues!.valueAt(x: x, y: y).doubleData
                maxZ = currValue > maxZ ? currValue : maxZ
            }
        }
        heatmapRenderableSeries?.maximum = maxZ / 2
    }
    
    // clear
    func clear () {
        NSLog("clear started")
        for x in 0..<props!.width {
            for y in 0..<props!.height {
                heatmapDataSeries?.updateZ(atXIndex: x, yIndex: y, withValue: zero)
            }
        }
    }
    
}

