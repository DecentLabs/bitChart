//
//  global.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 19..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import Foundation
import SciChart


var exchangeList: [String] = []
var checked: [String] = []

var sciChartSurface: SCIChartSurface?
var chart: Chart?

var chartWidth: CGFloat?
var buttons = [UIButton]()


class IsLoading {
    var loading: Bool = false {
        willSet(newVal) {
//            print(newVal, "new")
        }
        didSet (oldVal) {
//            print(oldVal, "old")
        }
    }
}
var isLoading = IsLoading()

