//
//  global.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 09. 19..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import Foundation
import SciChart



let data = getExchangeData()

var exchangeList: [String] = []
var checked: [String] = []

var sciChartSurface: SCIChartSurface?
var heatmap: Heatmap?

var chartWidth: CGFloat?
var buttons = [UIButton]()

