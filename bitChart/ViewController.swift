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
var exchangeList: [[String: Any]] = []

class ViewController: UIViewController {
    
    var sciChartSurface: SCIChartSurface?
    var checked: [String] = []
    var heatmap: Heatmap?

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
        
        
        // get exchange names
        var i = 0
        for (name, _) in data {
            exchangeList.append(["tag": i, "name": name])
            i += 1
        }
        
        // create checkboxes
        let btnSize = 60
        for (b, _) in exchangeList.enumerated() {
            let checkmark = UIButton(type: UIButton.ButtonType.custom) as UIButton
            checkmark.frame = CGRect(x: Int(20 + chartWidth), y: b * btnSize + 40, width: btnSize, height: btnSize)
            checkmark.setImage(UIImage(named:"Checkmarkempty"), for: .normal)
            checkmark.setImage(UIImage(named:"Checkmark"), for: .selected)
            checkmark.isSelected = true
            checkmark.tag = b
            checkmark.addTarget(self, action: Selector(("checkMarkTapped:")), for:.touchUpInside)
            self.view.addSubview(checkmark)
            let name = exchangeList.filter({$0["tag"] as! Int == b})[0]["name"]
            checked.append(name as! String)
        }
        
        // draw chart
        heatmap = Heatmap(sciChartSurface: sciChartSurface!, _data: data, exchangeList: checked)
        heatmap!.start()
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
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (success) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                sender.isSelected = !sender.isSelected
                sender.transform = .identity
            }, completion: { _ in
                let i = sender.tag
                let name = exchangeList.filter({$0["tag"] as! Int == i})[0]["name"] as! String
                
                // update exchange list
                if (!sender.isSelected) {
                    self.checked = self.checked.filter({$0 != name})
                } else {
                    self.checked.append(name)
                }
                
                // redraw chart
                self.heatmap!.update(exchangeList: self.checked)
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


