//
//  WeatherModel.swift
//  WeatherSearch
//
//  Created by 刘沛源 on 11/27/19.
//  Copyright © 2019 aaron. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation
import Alamofire

struct WeatherModel {
    var cityName: String = ""
    var timezone: String = ""
    var temperature: Double = 0
    var summary: String = ""
    var humidity: Double = 0
    var windSpeed: Double = 0
    var visibility: Double = 0
    var pressure: Double = 0
    var cloudCover: Double = 0
    var ozone: Double = 0
    var icon: String = ""
    var precipitation: Double = 0
    
    var weeklySummary: String = ""
    var weeklySumIcon: String = ""
    var weeklyTime: [Any]?
    var weeklyHigh: [Any]?
    var weeklyLow: [Any]?
    var weeklyIcon: [Any]?
    var sunrise: [Any]?
    var sunset: [Any]?
    
    init() {}
    
    init(jsonString: JSON) {
        self.timezone       = jsonString["timezone"].stringValue
        self.temperature    = jsonString["temperature"].doubleValue
        self.summary        = jsonString["summary"].stringValue
        self.humidity       = jsonString["humidity"].doubleValue
        self.windSpeed      = jsonString["windSpeed"].doubleValue
        self.pressure       = jsonString["pressure"].doubleValue
        self.visibility     = jsonString["visibility"].doubleValue
        self.cloudCover     = jsonString["cloudCover"].doubleValue
        self.ozone          = jsonString["ozone"].doubleValue
        self.icon           = jsonString["icon"].stringValue
        self.precipitation  = jsonString["precipitation"].doubleValue
        
        self.weeklySummary  = jsonString["weeklySummary"].stringValue
        self.weeklySumIcon  = jsonString["weeklySumIcon"].stringValue
        self.weeklyTime     = jsonString["weeklyTime"].arrayObject
        self.weeklyHigh     = jsonString["weeklyHigh"].arrayObject
        self.weeklyLow      = jsonString["weeklyLow"].arrayObject
        self.weeklyIcon     = jsonString["weeklyIcon"].arrayObject
        self.sunrise        = jsonString["sunriseTime"].arrayObject
        self.sunset         = jsonString["sunsetTime"].arrayObject
    }
    
    static func loadWeather(withLocation location: CLLocationCoordinate2D, completionHandler: @escaping(_ section: WeatherModel) -> ()) {
        let basePath = "https://my-nodejs-aaron-csci571.appspot.com/api"
        let url = basePath + "/weatherhw9?"
        let params = ["lat": location.latitude,
                      "lng": location.longitude]
        
        
        Alamofire.request(url, parameters: params).responseJSON { (responseData) in
            switch responseData.result {
            case .success(let value):
                if let statusCode = responseData.response?.statusCode, statusCode == 200 {
                    let jsonString = JSON(value)
                    let weatherObject = WeatherModel(jsonString: jsonString)
                    completionHandler(weatherObject)
                }
                break
            case .failure(let error):
                print(error)
            }
        }
        
    }
}
