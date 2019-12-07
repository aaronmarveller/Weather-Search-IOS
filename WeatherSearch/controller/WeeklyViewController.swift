//
//  WeeklyViewController.swift
//  WeatherSearch
//
//  Created by 刘沛源 on 12/2/19.
//  Copyright © 2019 aaron. All rights reserved.
//

import UIKit
import Charts

class WeeklyViewController: UIViewController {
    var weatherObject = WeatherModel()
    
    var iconDict: [String: String] = ["clear-day":"weather-sunny",
                                      "clear-night":"weather-night",
                                      "rain":"weather-rainy",
                                      "snow":"weather-snowy",
                                      "sleet":"weather-snowy-rainy",
                                      "wind":"weather-windy",
                                      "fog":"weather-fog",
                                      "cloudy":"weather-cloudy",
                                      "partly-cloudy-day":"weather-partly-cloudy",
                                      "partly-cloudy-night":"weather-night-partly-cloudy"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let weeklyView = Bundle.main.loadNibNamed("WeeklyData", owner: self, options: nil)?.first as? WeeklyView {
            updateView(view: weeklyView.weeklySum)
            
            let iconString = iconDict[weatherObject.weeklySumIcon]
            weeklyView.weeklySumIcon.image = UIImage(named: iconString ?? "weather-sunny")
            weeklyView.weeklySumData.text = weatherObject.weeklySummary
            updateView(view: weeklyView.lineChartView)
            
            draw(lineChartView: weeklyView.lineChartView)
            
            self.view.addSubview(weeklyView)
            
            
        }
    }
    
    func updateView(view: UIView) {
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor(white: 0.8, alpha: 0.3)
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
    }
    
    func draw(lineChartView: LineChartView) {
        let data = LineChartData()
        if let weeklyLow = weatherObject.weeklyLow {
            var weeklyLowChartEntry = [ChartDataEntry]()
            for i in 0..<weeklyLow.count {
                let yData: Double = weeklyLow[i] as? Double ?? 0.0
                weeklyLowChartEntry.append(ChartDataEntry(x: Double(i), y: Double(round(yData))))
            }
            let weeklyLowLine = LineChartDataSet(entries: weeklyLowChartEntry, label: "Minimum Temperature (°F)")
            weeklyLowLine.colors = [NSUIColor.white]
            weeklyLowLine.setCircleColor(NSUIColor.white)
            weeklyLowLine.circleRadius = 3
            weeklyLowLine.circleHoleColor = NSUIColor.white
            data.addDataSet(weeklyLowLine)
        }
        
        if let weeklyHigh = weatherObject.weeklyHigh {
            var weeklyHighChartEntry = [ChartDataEntry]()
            for i in 0..<weeklyHigh.count {
                let yData: Double = weeklyHigh[i] as? Double ?? 0.0
                weeklyHighChartEntry.append(ChartDataEntry(x: Double(i), y: Double(round(yData))))
            }
            let weeklyHighLine = LineChartDataSet(entries: weeklyHighChartEntry, label: "Maximum Temperature (°F)")
            weeklyHighLine.colors = [NSUIColor.orange]
            weeklyHighLine.setCircleColor(NSUIColor.orange)
            weeklyHighLine.circleRadius = 3
            weeklyHighLine.circleHoleColor = NSUIColor.orange
            data.addDataSet(weeklyHighLine)
            
        }
        
        lineChartView.data = data
 
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
