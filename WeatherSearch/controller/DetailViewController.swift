//
//  DetailViewController.swift
//  WeatherSearch
//
//  Created by 刘沛源 on 12/1/19.
//  Copyright © 2019 aaron. All rights reserved.
//

import UIKit

class DetailViewController: UITabBarController {
    
    var weatherObject = WeatherModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bar: UIBarButtonItem!
        bar = UIBarButtonItem(image: UIImage(named: "twitter"), style: .done, target: self, action:  #selector(self.shareTwitterAction(_:)))

        navigationItem.title = weatherObject.cityName
        navigationItem.rightBarButtonItem = bar
        navigationController?.isNavigationBarHidden = false
        
        
        let todayVC = viewControllers?[0] as! TodayViewController
        if weatherObject.sunrise != nil {
            todayVC.weatherObject = weatherObject
        }
        
        let weeklyVC = viewControllers?[1] as! WeeklyViewController
        if weatherObject.sunrise != nil {
            weeklyVC.weatherObject = self.weatherObject
        }
        
        let photosVC = viewControllers?[2] as! PhotosViewController
        if weatherObject.cityName != "" {
            photosVC.cityName = self.weatherObject.cityName
        }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Weather", style: .plain, target: nil, action: nil)
    }
    
    @objc func shareTwitterAction(_ sender: UIBarButtonItem) {
        let tweetText = "The current temperature at \(weatherObject.cityName)  is  \(weatherObject.temperature) °F. The weather conditions are \(weatherObject.summary) #CSCI571WeatherSearch"
        let shareString = "https://twitter.com/intent/tweet?text=\(tweetText)"
        let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        // open in safari
        guard let url = URL(string: escapedShareString) else { return }
        UIApplication.shared.open(url)
        
    }
    

}
