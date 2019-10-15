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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        chartWidth = self.view.frame.width - 60
        let chartHeight = self.view.frame.height
        let chartView = CGRect(x: 0, y: 0, width: chartWidth!, height: chartHeight)
        sciChartSurface = SCIChartSurface(frame: chartView)
        sciChartSurface?.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(sciChartSurface!)
        let buttonView = ButtonView(frame: CGRect(x: chartWidth!, y: 0, width: 60, height: chartHeight))
        self.view.addSubview(buttonView)
        
        
        chart = Chart(sciChartSurface: sciChartSurface!)
        
        
        let fileName = "orderbook3"
        let fileType = "csv"
        
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: fileType) else { return }
        let pathURL = URL(fileURLWithPath: filePath)
        let s = StreamReader(path: pathURL)
        
        DispatchQueue.global(qos: .background).async {
            chart!.load(exchangeData)
            repeat {
               if let row = s?.next() {
                    let items = parseTypes(row: row)
                    updateExchangeData(items)
                    if (Array(exchangeData.keys).count != buttonView.list.count) {
                        DispatchQueue.main.async {
                            buttonView.list = Array(exchangeData.keys)
                        }
                    }
               }
            } while !s!.isAtEOF

            DispatchQueue.main.async {
                chart!.loaded = true
                chart!.xAxis?.autoRange = .never
                chart!.yAxis?.autoRange = .never
            }
        }
        
        
        // force landscape orientation
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
   
    
    // force landscape orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


