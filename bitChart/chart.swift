//
//  chart.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 04..
//  Copyright © 2019. brigitta forrai. All rights reserved.



import Foundation
import SciChart

struct ChartProps {
    let width: Int32
    let height: Int32
    let minPrice: Int32
    let maxPrice: Int32
    var startDate: Int32
    let endDate: Int32
}

class Chart {
    var sciChartSurface: SCIChartSurface
    var _data: [String : [OrderBook]]
    var exchangeList: [String]
    
    
    var data: [String : [OrderBook]]?
    var xAxis: SCINumericAxis?
    var yAxis: SCINumericAxis?
    var loaded = false
    var timeResolution = Int32(60 * 60) // hourly
    
    var base: Heatmap?
    var secondary: Heatmap?
    var chartProps: ChartProps?
    
    let queue = DispatchQueue(label: "addSecondaryHeatmap")
    var workItem: DispatchWorkItem?
    
    init(sciChartSurface: SCIChartSurface, _data: [String : [OrderBook]], exchangeList: [String]) {
        self.sciChartSurface = sciChartSurface
        // todo data refact
        self._data = _data
        self.exchangeList = exchangeList
        self.data = _data.filter({exchangeList.contains($0.key)})
        
        self.chartProps = getChartProps() // todo
        self.base = Heatmap(data: self.data!, props: self.chartProps!, res: self.timeResolution)
    }
    
    func start () {
        SCIUpdateSuspender.usingWithSuspendable(sciChartSurface) {
            
            DispatchQueue(label: "addBaseHeatmap").async {
                self.base!.create()

                DispatchQueue.main.async {
                    self.sciChartSurface.renderableSeries.add(self.base!.heatmapRenderableSeries)
                }
            }
            
            self.createAxises()
            self.addModifiers()
            self.addEventListeners()
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
                    let renderSecondary = (self.chartProps!.startDate != min) && (self.chartProps!.endDate != max)
                    
                    if renderSecondary {
                      self.createSecondary(min: min, max: max, props: self.chartProps!)
                    }

                    if self.secondary!.isUpdated {
                        DispatchQueue.main.async {
                            print("update ui")
                            
                            if (self.sciChartSurface.renderableSeries.count() > 1) {
                                self.sciChartSurface.renderableSeries.remove(at: 1)
                            }
                            self.sciChartSurface.renderableSeries.add(self.secondary?.heatmapRenderableSeries)
                        }
                    }
                }
                
                self.queue.async(execute: self.workItem!)
            }
            self.loaded = true
        }
    }
    
    
    private func createAxises () {
        // create xy axis
        xAxis = SCINumericAxis()
        xAxis!.axisTitle = "Time"
        xAxis?.visibleRangeLimit = SCIIntegerRange(min: SCIGeneric(chartProps!.startDate), max: SCIGeneric(chartProps!.endDate)) // todo update
        sciChartSurface.xAxes.add(xAxis)
        
        yAxis = SCINumericAxis()
        yAxis!.axisTitle = "Price"
        yAxis?.visibleRangeLimit = SCIDoubleRange(min: SCIGeneric(chartProps!.minPrice), max: SCIGeneric(chartProps!.maxPrice))
        sciChartSurface.yAxes.add(yAxis)
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
        
        for (key, _) in data! {
            
            let dates = getMinMaxDates(orderbook: data![key]!)
            let prices = getMinMaxPrice(orderbook: data![key]!)
            
            startD = startD == 0 ? dates["startDate"]! : dates["startDate"]! < startD ? dates["startDate"]! : startD
            endD = dates["endDate"]! > endD ? dates["endDate"]! : endD
            minP = minP == 0 ? prices["minPrice"]! : prices["minPrice"]! < minP ? prices["minPrice"]! : minP
            maxP = prices["maxPrice"]! > maxP ? prices["maxPrice"]! : maxP
        }
        
        let duration = endD - startD
        
        return ChartProps(
            width: duration / timeResolution,
            height: Int32(maxP - minP),
            minPrice: minP,
            maxPrice: maxP,
            startDate: startD,
            endDate: endD
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
        
        self.secondary = Heatmap(data: self.data!, props: p, res: res)
        self.secondary!.create()
    }
    
    
    func update (list: [String]) {
        exchangeList = list
        data = _data.filter({exchangeList.contains($0.key)})
        self.chartProps = getChartProps()
        
        let range = self.xAxis?.visibleRange
        let min = Int32(range!.min.doubleData)
        let max = Int32(range!.max.doubleData)
        let renderSecondary = (self.chartProps!.startDate != min) && (self.chartProps!.endDate != max)

        SCIUpdateSuspender.usingWithSuspendable(sciChartSurface) {
            DispatchQueue(label: "addBaseChart").async {
                
                self.base = Heatmap(data: self.data!, props: self.chartProps!, res: self.timeResolution)
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
