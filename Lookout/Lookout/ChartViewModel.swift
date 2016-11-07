//
//  ChartViewModel.swift
//  Lookout
//
//  Created by Chunkai Chan on 2016/11/7.
//  Copyright © 2016年 Chunkai Chan. All rights reserved.
//

import Foundation
import Charts

class ChartViewModel {
    
    func setChartData(lineChartView lineChartView: LineChartView, dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: nil)
        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        
        lineChartView.data = lineChartData
        
        lineChartDataSet.colors = [UIColor.blackColor()]
        lineChartDataSet.drawCirclesEnabled = false
        
    }
    
    func setChartFormat(lineChartView lineChartView: LineChartView) {
        
        // MARK: Chart style settings
        
        lineChartView.xAxis.labelPosition = .Bottom
        
        // remove xAxis line
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.drawLabelsEnabled = false
        
        // remove chart description
        lineChartView.descriptionText = ""
        lineChartView.rightAxis.removeAllLimitLines()
        lineChartView.rightAxis.drawZeroLineEnabled = false
        lineChartView.rightAxis.drawTopYLabelEntryEnabled = false
        lineChartView.rightAxis.drawAxisLineEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.drawLimitLinesBehindDataEnabled = false
        
        // set axis max/min value
        lineChartView.leftAxis.axisMaxValue = 8
        lineChartView.leftAxis.axisMinValue = 0
        
        lineChartView.legend.enabled = false
    }
}