//
//  global.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 19..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import Foundation
import SciChart


var checked: [String] = []

var sciChartSurface: SCIChartSurface?
var chart: Chart?

var chartWidth: CGFloat?
var buttons = [UIButton]()

let btnSize = 60


class ButtonView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        fatalError("init(coder:) has not been implemented")
    }
    
    var buttons = [UIButton]()
    
    var names: [String] = [] {
        willSet(newVal) {
            self.createCheckmark(newVal)
        }
    }
    var checked: [String] = [] {
        willSet(newVal) {
            print(newVal, "new")
        }
    }
    
    func createCheckmark (_ newVal: [String]) {
        for (b, _) in newVal.enumerated() {
            let checkmark = UIButton(type: UIButton.ButtonType.custom) as UIButton
            checkmark.frame = CGRect(x: 0, y: b * btnSize + 40, width: btnSize, height: btnSize)
            checkmark.setImage(UIImage(named:"Checkmarkempty"), for: .normal)
            checkmark.setImage(UIImage(named:"Checkmark"), for: .selected)
            checkmark.isSelected = true
//            checkmark.addTarget(self, action: Selector(("checkMarkTapped:")), for:.touchUpInside)
            buttons.append(checkmark)
            
            print(buttons)
        }
    }
}


class IsLoading {
    var loading: Bool = false {
        willSet(newVal) {

        }
        didSet (oldVal) {

        }
    }
}
var isLoading = IsLoading()

