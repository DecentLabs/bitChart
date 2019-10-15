//
//  global.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 19..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import Foundation
import SciChart


var sciChartSurface: SCIChartSurface?
var chart: Chart?

var chartWidth: CGFloat?
let btnSize = 60


class ButtonView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
      backgroundColor = .darkGray
    }

    var list: [String] = [] {
        willSet(newVal) {
            createCheckmark(newVal)
        }
    }
    
    var checked: [String] = []
    
    func createCheckmark (_ newVal: [String]) {
        checked = []
        for (b, name) in newVal.enumerated() {
            let checkmark = UIButton(type: UIButton.ButtonType.custom) as UIButton
            checkmark.frame = CGRect(x: 0, y: b * btnSize + 40, width: btnSize, height: btnSize)
            checkmark.setImage(UIImage(named:"Checkmarkempty"), for: .normal)
            checkmark.setImage(UIImage(named:"Checkmark"), for: .selected)
            checkmark.isSelected = true
            checkmark.accessibilityLabel = name
            checkmark.addTarget(self, action: Selector(("checkmarkTapped:")), for:.touchUpInside)
            checked.append(name)
            addSubview(checkmark)
        }
    }
    
     // ccheckmark tapped
    @IBAction func checkmarkTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (success) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                sender.isSelected = !sender.isSelected
                sender.transform = .identity
            }, completion: { _ in
                let name = sender.accessibilityLabel
                if let index = self.checked.firstIndex(of: name!) {
                    self.checked.remove(at: index)
                } else {
                    self.checked.append(name!)
                }
                
                let data = exchangeData.filter({self.checked.contains($0.key)})
                chart?.update(data: data)
            }
        )}
    }
    
}

