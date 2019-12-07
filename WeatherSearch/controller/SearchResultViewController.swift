//
//  SearchResultViewController.swift
//  WeatherSearch
//
//  Created by 刘沛源 on 12/2/19.
//  Copyright © 2019 aaron. All rights reserved.
//

import UIKit
import Toast_Swift

class SearchResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var weatherObject = WeatherModel()
    
    @IBOutlet weak var button: UIButton!
    
    let defaults = UserDefaults.standard
    
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
    
    var firstSubView = FirstSubView()
    
    var secondSubView = SecondSubView()
    
    @IBOutlet weak var thirdSubView: UITableView!
    
    
    @IBOutlet weak var addFavBtn: UIButton!
    
    @IBAction func addFav(_ sender: Any) {
        addFavBtn.isHidden = true
        remvFavBtn.isHidden = false
        // toast with a specific duration and position
        view.makeToast("\(weatherObject.cityName) was added to the Favorite List", duration: 3.0, position: .bottom)
        
        // add fav list
        if var favList = defaults.array(forKey: "fav") {
            favList.append(weatherObject.cityName)
            defaults.set(favList, forKey: "fav")
        } else {
            var newfavList = [String]()
            newfavList.append(weatherObject.cityName)
            defaults.set(newfavList, forKey: "fav")
        }
    }
    
    @IBOutlet weak var remvFavBtn: UIButton!
    
    @IBAction func remvFav(_ sender: Any) {
        addFavBtn.isHidden = false
        remvFavBtn.isHidden = true
        
        view.makeToast("\(weatherObject.cityName) was removed to the Favorite List", duration: 3.0, position: .bottom)
        
        // add fav list
        if var favList = defaults.array(forKey: "fav") {
            favList = favList.filter {($0 as! String ) != weatherObject.cityName}
            defaults.set(favList, forKey: "fav")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bar: UIBarButtonItem!
        bar = UIBarButtonItem(image: UIImage(named: "twitter"), style: .done, target: self, action:  #selector(self.shareTwitterAction(_:)))
        navigationItem.title = weatherObject.cityName
        navigationItem.rightBarButtonItem = bar
        navigationController?.isNavigationBarHidden = false
        
        if let firstSubView = Bundle.main.loadNibNamed("FirstSub", owner: self, options: nil)?.first as? FirstSubView {
            self.firstSubView = firstSubView
            self.firstSubView.layer.cornerRadius = 10
            self.firstSubView.layer.masksToBounds = true
            self.firstSubView.center = CGPoint(x: 185, y: 220)
            self.firstSubView.backgroundColor = UIColor(white: 0.8, alpha: 0.3)
            self.firstSubView.layer.borderColor = UIColor.white.cgColor
            self.firstSubView.layer.borderWidth = 1
            self.view.addSubview(self.firstSubView)
        }
        
        if let secondSubView = Bundle.main.loadNibNamed("SecondSub", owner: self, options: nil)?.first as? SecondSubView {
            self.secondSubView = secondSubView
            self.secondSubView.center = CGPoint(x: 185, y: 400)
            self.view.addSubview(self.secondSubView)
        }
        
        view.bringSubviewToFront(button)
        view.bringSubviewToFront(addFavBtn)
        view.bringSubviewToFront(remvFavBtn)
        loadData(weatherObject: weatherObject)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "\(weatherObject.cityName)", style: .plain, target: nil, action: nil)
    }
    
    @objc func shareTwitterAction(_ sender: UIBarButtonItem) {
        let tweetText = "The current temperature at \(weatherObject.cityName)  is  \(weatherObject.temperature) °F. The weather conditions are \(weatherObject.summary) #CSCI571WeatherSearch"
        let shareString = "https://twitter.com/intent/tweet?text=\(tweetText)"
        let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        // open in safari
        guard let url = URL(string: escapedShareString) else { return }
        UIApplication.shared.open(url)
        
    }
    
    @IBAction func sendData(_ sender: Any) {
        if weatherObject.weeklyLow != nil {
            performSegue(withIdentifier: "resultToDetailSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as! DetailViewController
        detailVC.weatherObject = weatherObject
    }
    
    func loadData(weatherObject: WeatherModel) {
        self.weatherObject = weatherObject
        firstSubView.cityName.text = self.weatherObject.cityName
        firstSubView.weatherSum.text = weatherObject.summary
        firstSubView.weatherTemp.text = String(format:"%.1f", (weatherObject.temperature-32) * 5/9) + " °C"
        let iconString = iconDict[weatherObject.icon]
        firstSubView.weatherIcon.image = UIImage(named: iconString ?? "weather-sunny")
        secondSubView.humidity.text = String(format:"%.1f", weatherObject.humidity * 100) + " %"
        secondSubView.windSpeed.text = String(format:"%.2f", weatherObject.windSpeed) + " mph"
        secondSubView.visibility.text = String(format:"%.2f", weatherObject.visibility) + " km"
        secondSubView.pressure.text = String(format:"%.1f", weatherObject.pressure) + " mb"
        DispatchQueue.main.async { self.thirdSubView.reloadData() }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ThirdSub", owner: self, options: nil)?.first as! ThirdSubView
        
        if let weeklyTime = weatherObject.weeklyTime {
            let date = Date(timeIntervalSince1970: weeklyTime[indexPath.section+1] as! Double)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            cell.date.text = dateFormatter.string(from: date)
        }
        
        if let weeklyIcon = weatherObject.weeklyIcon {
            let iconString = iconDict[weeklyIcon[indexPath.section+1] as! String]
            cell.weatherIcon.image = UIImage(named: iconString ?? "weather-sunny")
        }
        
        if let sunriseTime = weatherObject.sunrise {
            let date = Date(timeIntervalSince1970: sunriseTime[indexPath.section+1] as! Double)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            cell.sunriseTime.text = dateFormatter.string(from: date)
        }
        
        if let sunsetTime = weatherObject.sunset {
            let date = Date(timeIntervalSince1970: sunsetTime[indexPath.section+1] as! Double)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            cell.sunsetTime.text = dateFormatter.string(from: date)
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let number = self.weatherObject.weeklyTime?.count {
            return number-1
        } else {
            return 0
        }
    }

}
