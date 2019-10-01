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
    
    func createSpinnerView() {
        let child = SpinnerViewController()
        
        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        // wait two seconds to simulate some work happening
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // force landscape orientation
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        
        // Create a SCIChartSurface. This is a UIView so can be added directly to the UI
        chartWidth = self.view.frame.width - 100
        let chartHeight = self.view.frame.height
        let chartView = CGRect(x: 0, y: 0, width: chartWidth!, height: chartHeight)
        sciChartSurface = SCIChartSurface(frame: chartView)
        sciChartSurface?.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(sciChartSurface!)
        
        
        // get exchange names
        for (name, _) in data {
            exchangeList.append(name)
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
        
        buttons[0].isSelected = true
        checked.append(exchangeList[0])
        
        // draw chart
        heatmap = Heatmap(sciChartSurface: sciChartSurface!, _data: data, exchangeList: checked)
        heatmap!.start()
    }
    
    // ccheckmark tapped
    @IBAction func checkMarkTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.createSpinnerView()
        }) { (success) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                for button in buttons {
                    button.isSelected = false
                }
                sender.isSelected = true
                sender.transform = .identity
            }, completion: { _ in
                let index = buttons.firstIndex(of: sender)
                let name = exchangeList[index!]
                
                // update exchange list
                checked = []
                checked.append(name)
                
                // redraw chart
                heatmap!.filterData(list: checked)
                // heatmap!.render() todo
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


