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

let data = getData()

class ViewController: UIViewController {
    
    var sciChartSurface: SCIChartSurface?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a SCIChartSurface. This is a UIView so can be added directly to the UI
        sciChartSurface = SCIChartSurface(frame: self.view.bounds)
        sciChartSurface?.translatesAutoresizingMaskIntoConstraints = true
        
        // Add the SCIChartSurface as a subview
        self.view.addSubview(sciChartSurface!)
        
        
//        // set chart
//        sciChartSurface = setChart(
//            sciChartSurface: sciChartSurface!,
//            data: data
//        )
//
//        // add line charts
//        sciChartSurface = createLinechart(
//            sciChartSurface: sciChartSurface!,
//            data: data
//        )

        // heatmap test
        sciChartSurface = createHeatmap(
            sciChartSurface: sciChartSurface!,
            data: data
        )

        // add chart modifiers (pan + zoom)
        sciChartSurface = addModifiers(sciChartSurface: sciChartSurface!)
    }
}


