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
    var xAxis: SCINumericAxis?
    var yAxis: SCINumericAxis?
    var loaded = false
    
    var base: Series
    var secondary: Series
    
    let queue = DispatchQueue(label: "update")
    var workItem: DispatchWorkItem?
    
    
    init(sciChartSurface: SCIChartSurface, _data: [String : [OrderBook]], exchangeList: [String]) {
        NSLog("init heatmap")
        self.sciChartSurface = sciChartSurface
        self._data = _data
        self.exchangeList = exchangeList
        self.data = _data.filter({exchangeList.contains($0.key)})
        
        self.base = Series(data: self.data!)
        self.secondary = Series(data: self.data!)
    }
    
    func start () {
        SCIUpdateSuspender.usingWithSuspendable(sciChartSurface) {
//          self.setupDataSeries()
            
            DispatchQueue(label: "addBaseChart").async {
                print("1. create base")
                self.base.create()
                
                // add to ui
                DispatchQueue.main.async {
                    print("2. setup chart")
                    self.createAxises()
                    self.addModifiers()
                    self.addEventListeners()
                    print("3. update ui")
                    self.sciChartSurface.renderableSeries.add(self.base.heatmapRenderableSeries)
                }
            }
        }
    }
    
    
      private func addEventListeners () {
            // Register a VisibleRangeChanged callback
            xAxis!.registerVisibleRangeChangedCallback { (newRange, oldRange, isAnimated, sender) in
                if self.loaded {
                    
                    self.secondary.setUpdate(update: false)
                    self.workItem?.cancel()
                    //print("shouldupdate parent 1: ", self.secondary.shouldUpdate)
                    
                    
                    self.workItem = DispatchWorkItem {
                        self.secondary.setUpdate(update: true)
                        //print("shouldupdate parent 2: ", self.secondary.shouldUpdate)
                        
                        let min = Int32(newRange!.min.doubleData)
                        let max = Int32(newRange!.max.doubleData)
                        let duration = Int32(max - min)
                        
                        // todo width
                        self.secondary.timeResolution = duration / self.base.width
                        self.secondary.startDate = min
                        self.secondary.endDate = max
                        
                        self.secondary.create()
                        
                        if self.secondary.isUpdated {
                            DispatchQueue.main.async {
                                print("update ui")
                                
                                if (self.sciChartSurface.renderableSeries.count() > 1) {
                                    print("remove old")
                                    self.sciChartSurface.renderableSeries.remove(at: 1)
                                }
                                
                                self.sciChartSurface.renderableSeries.add(self.secondary.heatmapRenderableSeries)
                                
                                print(self.sciChartSurface.renderableSeries.count())
                            }
                        }
                    }
                    
                    self.queue.async(execute: self.workItem!)
                }
                self.loaded = true
            }
        }
    
    
     // create xy axis
    private func createAxises () {
        xAxis = SCINumericAxis()
        xAxis!.axisTitle = "Time"
        xAxis?.visibleRangeLimit = SCIIntegerRange(min: SCIGeneric(base.startDate), max: SCIGeneric(base.endDate)) // todo
        sciChartSurface.xAxes.add(xAxis)
        
        yAxis = SCINumericAxis()
        yAxis!.axisTitle = "Price"
        yAxis?.visibleRangeLimit = SCIDoubleRange(min: SCIGeneric(base.minPrice), max: SCIGeneric(base.maxPrice))
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
    
    func filterData(list: [String]) {
        exchangeList = list
        data = _data.filter({exchangeList.contains($0.key)})
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
