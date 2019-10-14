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
        
        // Create a SCIChartSurface. This is a UIView so can be added directly to the UI
        chartWidth = self.view.frame.width - 100
        let chartHeight = self.view.frame.height
        let chartView = CGRect(x: 0, y: 0, width: chartWidth!, height: chartHeight)
        sciChartSurface = SCIChartSurface(frame: chartView)
        sciChartSurface?.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(sciChartSurface!)
        
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
               }
            } while !s!.isAtEOF

            DispatchQueue.main.async {
                chart!.loaded = true
                chart!.xAxis?.autoRange = .never
                chart!.yAxis?.autoRange = .never
            }
        }
        
        
        
        // create checkboxes
        let btnSize = 60
        for (b, _) in exchangeList.enumerated() {
            let checkmark = UIButton(type: UIButton.ButtonType.custom) as UIButton
            checkmark.frame = CGRect(x: Int(20 + chartWidth!), y: b * btnSize + 40, width: btnSize, height: btnSize)
            checkmark.setImage(UIImage(named:"Checkmarkempty"), for: .normal)
            checkmark.setImage(UIImage(named:"Checkmark"), for: .selected)
            checkmark.isSelected = false
            checkmark.addTarget(self, action: Selector(("checkMarkTapped:")), for:.touchUpInside)
            self.view.addSubview(checkmark)
            buttons.append(checkmark)
        }
        
//        buttons[0].isSelected = true
        
        
        // force landscape orientation
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    // ccheckmark tapped
    @IBAction func checkMarkTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 1, delay: 0, options: .curveLinear, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)

        }) { (success) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                for button in buttons {
                    button.isSelected = false
                }
                sender.isSelected = true
                sender.transform = .identity
                isLoading.loading = true
            }, completion: { _ in
                let index = buttons.firstIndex(of: sender)
                let name = exchangeList[index!]
                
                // update exchange list
                checked = []
                checked.append(name)
                
                chart!.update(data: exchangeData)
            })
        }
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


