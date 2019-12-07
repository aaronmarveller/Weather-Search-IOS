//
//  TodayViewController.swift
//  WeatherSearch
//
//  Created by 刘沛源 on 12/2/19.
//  Copyright © 2019 aaron. All rights reserved.
//

import UIKit

class TodayViewController: UIViewController {
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
        if let todayView = Bundle.main.loadNibNamed("TodayData", owner: self, options: nil)?.first as? TodayView {
            updateView(view: todayView.windSpeed)
            updateView(view: todayView.pressure)
            updateView(view: todayView.precipitation)
            updateView(view: todayView.temperature)
            updateView(view: todayView.summary)
            updateView(view: todayView.humidity)
            updateView(view: todayView.visibility)
            updateView(view: todayView.cloudCover)
            updateView(view: todayView.ozone)
            
            todayView.windSpeedData.text = String(format:"%.2f", weatherObject.windSpeed) + " mph"
            todayView.pressData.text = String(format:"%.1f", weatherObject.pressure) + " mb"
            todayView.precipData.text = String(format:"%.1f", weatherObject.precipitation) + " mmph"
            todayView.tempData.text = String(format:"%.0f", weatherObject.temperature) + " °F"
            let iconString = iconDict[weatherObject.icon]
            todayView.weatherIcon.image = UIImage(named: iconString ?? "weather-sunny")
            todayView.weatherSum.text = weatherObject.summary
            todayView.humidData.text = String(format:"%.1f", weatherObject.humidity * 100) + " %"
            todayView.visibData.text = String(format:"%.2f", weatherObject.visibility) + " km"
            todayView.cloudData.text = String(format:"%.2f", weatherObject.cloudCover * 100) + " %"
            todayView.ozoneData.text = String(format:"%.1f", weatherObject.ozone) + " DU"
            view.addSubview(todayView)
        }
        
    }
    
    func updateView(view: UIView) {
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor(white: 0.8, alpha: 0.3)
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
    }
    

}
