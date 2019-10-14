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
    var props: ChartProps?
    
    let zero = SCIGeneric(0.0)
    var maxZ: Double = 0
    
    var shouldUpdate: Bool = true
    var isUpdated: Bool = false
    
    var heatmapDataSeries: SCIUniformHeatmapDataSeries?
    var heatmapRenderableSeries: SCIFastUniformHeatmapRenderableSeries?
    var zValues: SCIArrayController2D?
    
    
    init(data: [String : [OrderBook]], props: ChartProps) {
        self.data = data
        self.props = props
    }
    
    func create () {
//        print("BEGIN")
        self.isUpdated = false

        if shouldUpdate { setupDataSeries() } else {
//            print("STOP")
            return
        }
        
        if shouldUpdate { clear() } else {
//            print("STOP")
            return
        }

        if shouldUpdate { accumulate() } else {
//            print("STOP")
            return
        }
        
        if shouldUpdate { getMax() } else {
//            print("STOP")
            return
        }
        
        if shouldUpdate {
            createRenderableSeries()
            isUpdated = true
//            print("END")
        } else {
//            print("STOP")
            return
        }
    }
    
    func setupDataSeries() {
        heatmapDataSeries = SCIUniformHeatmapDataSeries(typeX: .int32,
                                                        y: .int32,
                                                        z: .double,
                                                        sizeX: props!.width,
                                                        y: props!.height,
                                                        startX: SCIGeneric(props!.startDate),
                                                        stepX: SCIGeneric(props!.timeResolution),
                                                        startY: SCIGeneric(props!.minPrice),
                                                        stepY: SCIGeneric(1))
        zValues = heatmapDataSeries!.zValues()
    }
    

    func createRenderableSeries () {
        // Declare a Heatmap Render Series and set style
        heatmapRenderableSeries = SCIFastUniformHeatmapRenderableSeries()
        heatmapRenderableSeries!.minimum = Double(0)
        heatmapRenderableSeries!.maximum = maxZ / 2 // todo getYmax
        heatmapRenderableSeries!.dataSeries = heatmapDataSeries
                
         //add colors
        let stops = [NSNumber(value: 0.0), NSNumber(value: 1)]
        let colors = [UIColor.fromARGBColorCode(0xFF000000)!,UIColor.fromARGBColorCode(0xFFffffff)!]
        heatmapRenderableSeries!.colorMap = SCIColorMap.init(colors: colors, andStops: stops)
    }
    
    
    func accumulate () {
        if props!.width > 0 {
            for (name, exchange) in data! {

                // loop in orderbook
                for orderBook in exchange {
                 let x = (Int32(dateToTimestamp(date: orderBook.timestamp)) - props!.startDate) / props!.timeResolution
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
   }
    
    
    func getMax () {
        maxZ = Double(0)
        for x in 0..<props!.width {
            for y in 0..<props!.height {
                let currValue = zValues!.valueAt(x: x, y: y).doubleData
                maxZ = currValue > maxZ ? currValue : maxZ
            }
        }
        heatmapRenderableSeries?.maximum = maxZ / 2
    }
    
    
    func clear () {
        for x in 0..<props!.width {
            for y in 0..<props!.height {
                heatmapDataSeries?.updateZ(atXIndex: x, yIndex: y, withValue: zero)
            }
        }
    }
}

