//
//  chart.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 04..
//  Copyright © 2019. brigitta forrai. All rights reserved.


import Foundation
import SciChart


class Chart {
    var sciChartSurface: SCIChartSurface
    var data: [String : [OrderBook]] = [:]
    var xAxis: SCINumericAxis?
    var yAxis: SCINumericAxis?
    var loaded = false
    let width: Int32 = 60
    
    var base: Heatmap?
    var secondary: Heatmap?
    var chartProps: ChartProps?
    
    let queue = DispatchQueue(label: "updateSecondary")
    var workItem: DispatchWorkItem?
    
    init(sciChartSurface: SCIChartSurface) {
        self.sciChartSurface = sciChartSurface
        self.createAxises()
        self.addModifiers()
        self.addEventListeners()
    }
    
    
    func load (_ d: [String: [OrderBook]]) {
        DispatchQueue(label: "loadBase").async {
            self.data = d
            self.chartProps = self.getChartProps()
            
            self.xAxis?.visibleRangeLimit = SCIIntegerRange(min: SCIGeneric(self.chartProps!.startDate), max: SCIGeneric(self.chartProps!.endDate))
            self.yAxis?.visibleRangeLimit = SCIDoubleRange(min: SCIGeneric(self.chartProps!.minPrice), max: SCIGeneric(self.chartProps!.maxPrice))
            self.base = Heatmap(data: self.data, props: self.chartProps!)
            self.base!.create()
            

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if (self.sciChartSurface.renderableSeries.count() > 0) {
                        self.sciChartSurface.renderableSeries.remove(at: 0)
                    }
                self.sciChartSurface.renderableSeries.add(self.base?.heatmapRenderableSeries)
                
                if (!self.loaded) {
                    self.load(exchangeData)
                }
           }
        }
    }

    
    private func addEventListeners () {
        xAxis!.registerVisibleRangeChangedCallback { (newRange, oldRange, isAnimated, sender) in
            if self.loaded {
                
                self.secondary?.shouldUpdate = false
                self.workItem?.cancel()
                
                self.workItem = DispatchWorkItem {
                    let min = Int32(newRange!.min.doubleData)
                    let max = Int32(newRange!.max.doubleData)
                    let renderSecondary = (self.chartProps!.startDate != min) || (self.chartProps!.endDate != max)
                    
                    if renderSecondary {
                      self.createSecondary(min: min, max: max, props: self.chartProps!)
                    }

                    if (self.secondary?.isUpdated ?? false) {
                        DispatchQueue.main.async {
                            
                            if (self.sciChartSurface.renderableSeries.count() > 1) {
                                self.sciChartSurface.renderableSeries.remove(at: 1)
                            }
                        self.sciChartSurface.renderableSeries.add(self.secondary?.heatmapRenderableSeries)
                        }
                    }
                }
                
                self.queue.async(execute: self.workItem!)
            }
        }
    }
    
    
    private func createAxises () {
        // create xy axis
        xAxis = SCINumericAxis()
        xAxis!.axisTitle = "Time"
        sciChartSurface.xAxes.add(xAxis)
        
        yAxis = SCINumericAxis()
        yAxis!.axisTitle = "Price"
        sciChartSurface.yAxes.add(yAxis)
        
        xAxis?.autoRange = .always
        yAxis?.autoRange = .always
    }
    
    private func addModifiers () {
        // pan + zoom
        sciChartSurface.chartModifiers = SCIChartModifierCollection(childModifiers: [
            SCIPinchZoomModifier(),
            SCIZoomPanModifier(),
            SCIZoomExtentsModifier()
        ])
    }
    
    private func getChartProps () -> ChartProps {
        var startD: Int32 = 0
        var endD: Int32 = 0
        var minP: Int32 = 0
        var maxP: Int32 = 0
        
        for (key, _) in data {
            
            let dates = getMinMaxDates(orderbook: data[key]!)
            let prices = getMinMaxPrice(orderbook: data[key]!)
            
            startD = startD == 0 ? dates["startDate"]! : dates["startDate"]! < startD ? dates["startDate"]! : startD
            endD = dates["endDate"]! > endD ? dates["endDate"]! : endD
            minP = minP == 0 ? prices["minPrice"]! : prices["minPrice"]! < minP ? prices["minPrice"]! : minP
            maxP = prices["maxPrice"]! > maxP ? prices["maxPrice"]! : maxP
        }
        
        let duration = endD - startD
        let timeRes = duration / width
        
        
        return ChartProps(
            width:  width,
            height: Int32(maxP - minP),
            minPrice: minP,
            maxPrice: maxP,
            startDate: startD,
            endDate: endD,
            timeResolution: timeRes > 0 ? timeRes : 1
        )
    }
    
    private func getMinMaxDates(orderbook: [OrderBook]) -> [String: Int32] {
        let startDate = Int32(dateToTimestamp(date: orderbook.first!.timestamp))
        let endDate = Int32(dateToTimestamp(date: orderbook.last!.timestamp))
        return ["startDate": startDate, "endDate": endDate]
    }
    
    
    private func getMinMaxPrice(orderbook: [OrderBook]) -> [String: Int32] {
        let maxPrice = orderbook.map({$0.asks.last!.price}).max()!
        let minPrice = orderbook.map({$0.bids.last!.price}).min()!
        return ["minPrice": minPrice, "maxPrice": maxPrice]
    }
    
    private func createSecondary (min: Int32, max: Int32, props: ChartProps) {
        let duration = max - min
        let res = duration / props.width
        var p = props
        p.startDate = min
        p.timeResolution = res
        
        self.secondary = Heatmap(data: self.data, props: p)
        self.secondary!.create()
    }
    
    
    func update (data: [String: [OrderBook]]) {
        DispatchQueue(label: "addHeatmaps").async {
        self.data = data
            self.chartProps = self.getChartProps()
        
        let range = self.xAxis?.visibleRange
        let min = Int32(range!.min.doubleData)
        let max = Int32(range!.max.doubleData)
        let renderSecondary = (self.chartProps!.startDate != min) && (self.chartProps!.endDate != max)

            SCIUpdateSuspender.usingWithSuspendable(self.sciChartSurface) {
                
                self.base = Heatmap(data: self.data, props: self.chartProps!)
                self.base!.create()

                if (renderSecondary) {
                    self.createSecondary(min: min, max: max, props: self.chartProps!)
                }
            
                DispatchQueue.main.async {
                    self.sciChartSurface.renderableSeries.clear()
                    self.sciChartSurface.renderableSeries.add(self.base!.heatmapRenderableSeries)
                    if renderSecondary {
                        self.sciChartSurface.renderableSeries.add(self.secondary!.heatmapRenderableSeries)
                    }
                }
            }
        }
    }
}
