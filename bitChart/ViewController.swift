//
//  ViewController.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 02..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import UIKit
import SciChart
import Foundation

//let data = getData()
let data = getExchangeData()

class ViewController: UIViewController {
    
    var sciChartSurface: SCIChartSurface?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a SCIChartSurface. This is a UIView so can be added directly to the UI
        sciChartSurface = SCIChartSurface(frame: self.view.bounds)
        sciChartSurface?.translatesAutoresizingMaskIntoConstraints = true
        
        // Add the SCIChartSurface as a subview
        self.view.addSubview(sciChartSurface!)
        
        
        // set chart
        sciChartSurface = setChart( sciChartSurface: sciChartSurface! )
        
        print(data["bitstamp"]!.count, "bitstamp")
        print(data["kraken"]!.count, "kraken")
        print(data["bitfinex"]!.count, "bitfinex")

        
        // heatmaps
        // bitfinex, bitstamp, kraken, bitmex, coinbasepro
        sciChartSurface = createHeatmap(
            sciChartSurface: sciChartSurface!,
            data: data["bitstamp"]!,
            colors: [.fromABGRColorCode(0x00000000), .fromABGRColorCode(0x6600ff00)]
        )
        sciChartSurface = createHeatmap(
            sciChartSurface: sciChartSurface!,
            data: data["kraken"]!,
            colors: [.fromABGRColorCode(0x00000000), .fromABGRColorCode(0x66ff0000)]
        )
        sciChartSurface = createHeatmap(
            sciChartSurface: sciChartSurface!,
            data: data["bitfinex"]!,
            colors: [.fromABGRColorCode(0x00000000), .fromABGRColorCode(0x660000ff)]
        )
        
        
        
        // add line charts
        //        sciChartSurface = createLinechart(
        //            sciChartSurface: sciChartSurface!,
        //            data: data
        //        )

        // add chart modifiers (pan + zoom)
        sciChartSurface = addModifiers(sciChartSurface: sciChartSurface!)
    }
}


