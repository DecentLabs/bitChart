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


class ViewController: UIViewController {
    
    var sciChartSurface: SCIChartSurface?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get data from csv
        let data = getData()

        // Create a SCIChartSurface. This is a UIView so can be added directly to the UI
        let surface = SCIChartSurface(frame: self.view.bounds)

        if SCIChartSurface.isMetalSupported {
            surface.renderSurface = SCIMetalRenderSurface(frame: surface.bounds)
        }

        surface.translatesAutoresizingMaskIntoConstraints = true

        // Add the SCIChartSurface as a subview
        self.view.addSubview(surface)
        
        // set chart
        sciChartSurface = setChart(sciChartSurface: surface, data: data)
    }
}


