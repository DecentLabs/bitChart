//
//  chart.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 04..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//
//
// REFACT WIP

import Foundation
import SciChart

class Chart {
    var sciChartSurface: SCIChartSurface
    var _data: [String : [OrderBook]]
    var exchangeList: [String]
    
    
    var data: [String : [OrderBook]]?
    var xAxis: SCINumericAxis?
    var yAxis: SCINumericAxis?
    var loaded = false
    
    var base: Heatmap
    var secondary: Heatmap
    
    let queue = DispatchQueue(label: "update")
    var workItem: DispatchWorkItem?
    
    
    init(sciChartSurface: SCIChartSurface, _data: [String : [OrderBook]], exchangeList: [String]) {
        NSLog("init chart")
        self.sciChartSurface = sciChartSurface
        self._data = _data
        self.exchangeList = exchangeList
        self.data = _data.filter({exchangeList.contains($0.key)})
        
        self.base = Heatmap(data: self.data!)
        self.secondary = Heatmap(data: self.data!)
    }
    
    func start () {
        SCIUpdateSuspender.usingWithSuspendable(sciChartSurface) {
            
            DispatchQueue(label: "addBaseChart").async {
                print("1. create base heatmap")
                self.base.create()
                
                // add to ui
                DispatchQueue.main.async {
                    print("2. setup chart")
                    // todo
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
    
    // TODO!!!!!!!!!!!
    func update (list: [String]) {
        exchangeList = list
        data = _data.filter({exchangeList.contains($0.key)})
        
        base.updateData(data: data!)
        secondary.updateData(data: data!)
        
        base.create()
        if sciChartSurface.renderableSeries.count() > 1 {
            secondary.create()
            sciChartSurface.renderableSeries.remove(at: 1)
            sciChartSurface.renderableSeries.add(secondary.heatmapRenderableSeries)
        }
        
        sciChartSurface.renderableSeries.remove(at: 0)
        sciChartSurface.renderableSeries.add(base.heatmapRenderableSeries)
        
    }
}
