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

let data = getExchangeData()

class ViewController: UIViewController {
    
    var sciChartSurface: SCIChartSurface?
    @IBOutlet weak var btnCheckBox:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // force landscape orientation
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        // Create a SCIChartSurface. This is a UIView so can be added directly to the UI
        let chartWidth = self.view.frame.width - 100
        let chartHeight = self.view.frame.height
        let chartView = CGRect(x: 0, y: 0, width: chartWidth, height: chartHeight)
        sciChartSurface = SCIChartSurface(frame: chartView)
        sciChartSurface?.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(sciChartSurface!)
        
        
        // heatmaps: bitfinex, bitstamp, kraken, bitmex, coinbasepro
        sciChartSurface = createHeatmap(
            sciChartSurface: sciChartSurface!,
            data: data
        )
        
        // create checkboxes
        let btnSize = 60
        for b in 0..<5 {
            let checkmark = UIButton(type: UIButton.ButtonType.custom) as UIButton
            checkmark.frame = CGRect(x: Int(20 + chartWidth), y: b * btnSize + 40, width: btnSize, height: btnSize)
            checkmark.setImage(UIImage(named:"Checkmarkempty"), for: .normal)
            checkmark.setImage(UIImage(named:"Checkmark"), for: .selected)
            checkmark.isSelected = true
            checkmark.addTarget(self, action: Selector(("checkMarkTapped:")), for:.touchUpInside)
            self.view.addSubview(checkmark)
        }
    }
    
    // force landscape orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }
    override var shouldAutorotate: Bool {
        return true
    }
    
    // ccheckmark tapped
    @IBAction func checkMarkTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
        }) { (success) in
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
                sender.isSelected = !sender.isSelected
                sender.transform = .identity
                
                print("selected", sender.isSelected)
            }, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


