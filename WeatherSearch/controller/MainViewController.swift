//
//  MainViewController.swift
//  WeatherSearch
//
//  Created by 刘沛源 on 11/28/19.
//  Copyright © 2019 aaron. All rights reserved.
//

import UIKit
import CoreLocation
import QuartzCore
import SwiftSpinner
import Alamofire

class MainViewController: UIViewController, UISearchBarDelegate, UISearchDisplayDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var button: UIButton!
    
    let manager = CLLocationManager()
    
    let defaults = UserDefaults.standard
    
    var resultWeatherObject =  WeatherModel()
    
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
    
    var weatherObject = [WeatherModel]()
    
    var firstSubView = [FirstSubView]()
    
    var secondSubView = [SecondSubView]()
    
    var thirdSubView = [UITableView]()
    
    var viewNumber: Int = 1
    
    var searchTable = UITableView()
    
    var searchHint = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        delay(seconds: 0.5) {
            SwiftSpinner.show("Loading...")
        }
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
        searchBar.delegate = self
        scrollView.delegate = self
        searchTable.delegate = self
        searchTable.dataSource = self
        
        createSearchTableView()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        manager.requestLocation()
        
        clearScrollView()
        setUpView()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            searchTable.isHidden = false
            let basePath = "https://my-nodejs-aaron-csci571.appspot.com/api"
            let url = basePath + "/citieshw9?"
            let params = ["input": searchText]
            Alamofire.request(url, parameters: params as Parameters).responseJSON { (responseData) in
                switch responseData.result {
                case .success(let value):
                    if let statusCode = responseData.response?.statusCode, statusCode == 200 {
                        if let result = value as? [String] {
                            self.searchHint = result
                            DispatchQueue.main.async { self.searchTable.reloadData() }
                        }
                    }
                    break
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            searchTable.isHidden = true
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let locationString = searchBar.text, !locationString.isEmpty {
            SwiftSpinner.show("Fetching Weather Details for \(locationString)...")
            updateWeatherForLocation(location: locationString)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateWeatherForCurrentLocation(withLocation: (manager.location?.coordinate))
        getPlace(for: manager.location) { (placemark) in
            if let placemark = placemark {
                self.firstSubView[0].cityName.text = placemark.locality
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func delay(seconds: Double, completion: @escaping () -> ()) {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            completion()
        }
    }
    
    func clearScrollView() {
        scrollView.subviews.forEach({ $0.removeFromSuperview() })
        weatherObject = [WeatherModel]()
        firstSubView = [FirstSubView]()
        secondSubView = [SecondSubView]()
        thirdSubView = [UITableView]()
    }
    
    func setUpView() {
        // count the view number
        var favList:[Any]? = defaults.array(forKey: "fav")
        viewNumber = favList?.count ?? 0
        viewNumber += 1 // including the currentLocation
        pageControl.numberOfPages = viewNumber
        
        for _ in 0..<viewNumber {
            weatherObject.append(WeatherModel())
        }
        
        createFirstSubViews()
        
        createSecondSubViews()
        
        createThirdSubViews()
        
        setUpScrollView()
        
        scrollView.isPagingEnabled = true
        
        if self.viewNumber >= 2 {
            for i in 1..<self.viewNumber {
                if let fav = favList?[i-1] {
                    updateWeatherForFavLocation(location: fav as? String ?? "Los Angeles", index: i)
                }
            }
        }
        // set the navBar
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Weather", style: .plain, target: nil, action: nil)
        view.bringSubviewToFront(button)
        view.bringSubviewToFront(searchTable)
    }
    
    
    func createFirstSubViews() {
        for _ in 0..<viewNumber {
            if let firstSubView = Bundle.main.loadNibNamed("FirstSub", owner: self, options: nil)?.first as? FirstSubView {
                firstSubView.layer.cornerRadius = 10
                firstSubView.layer.masksToBounds = true
                firstSubView.backgroundColor = UIColor(white: 0.8, alpha: 0.3)
                firstSubView.layer.borderColor = UIColor.white.cgColor
                firstSubView.layer.borderWidth = 1
                self.firstSubView.append(firstSubView)
            }
        }
    }
    
    func createSecondSubViews() {
        for _ in 0..<viewNumber {
            if let secondSubView = Bundle.main.loadNibNamed("SecondSub", owner: self, options: nil)?.first as? SecondSubView {
                self.secondSubView.append(secondSubView)
            }
        }
    }
    
    func createThirdSubViews() {
        for _ in 0..<viewNumber {
            let thirdSubView = UITableView()
            thirdSubView.backgroundColor = UIColor(white: 0.8, alpha: 0.3)
            thirdSubView.layer.cornerRadius = 10
            thirdSubView.layer.masksToBounds = true
            thirdSubView.layer.borderColor = UIColor.white.cgColor
            thirdSubView.layer.borderWidth = 0.5
            thirdSubView.delegate = self
            thirdSubView.dataSource = self
            self.thirdSubView.append(thirdSubView)
        }
    }
    
    func createSearchTableView() {
        searchTable.frame = CGRect(x: 30, y: 100, width: 315, height: 200)
        searchTable.contentSize = CGSize(width: 315, height: 200)
        searchTable.backgroundColor = UIColor(white: 0.8, alpha: 0.3)
        searchTable.layer.cornerRadius = 5
        searchTable.layer.masksToBounds = true
        searchTable.isHidden = true
        self.view.addSubview(searchTable)
    }
    
    func setUpScrollView() {
        for i in 0 ..< viewNumber {
            let pageView = UIView()
            let xPosition = scrollView.frame.width * CGFloat(i)
            pageView.frame = CGRect(x: xPosition,
                                   y: 0,
                                   width: view.frame.width,
                                   height: view.frame.height)
            firstSubView[i].frame = CGRect(x: 30, y: 50, width: 315, height: 150)
            secondSubView[i].frame = CGRect(x: 0, y: 230, width: 310, height: 100)
            thirdSubView[i].frame = CGRect(x: 30, y: 380, width: 300, height: 261)
            pageView.addSubview(firstSubView[i])
            pageView.addSubview(secondSubView[i])
            pageView.addSubview(thirdSubView[i])
            
            if(i > 0) {
                let addFavBtn = UIButton()
                addFavBtn.setImage(UIImage(named: "plus-circle"), for: .normal)
                addFavBtn.isHidden = true
                addFavBtn.frame = CGRect(x: 325, y: 15, width: 30, height: 30)
                addFavBtn.tag = -i
                addFavBtn.addTarget(self, action: #selector(addFavAction), for: .touchUpInside)
                pageView.addSubview(addFavBtn)
                
                let remvFavBtn = UIButton()
                remvFavBtn.setImage(UIImage(named: "trash-can"), for: .normal)
                remvFavBtn.isHidden = false
                remvFavBtn.frame = CGRect(x: 325, y: 15, width: 30, height: 30)
                remvFavBtn.tag = i
                remvFavBtn.addTarget(self, action: #selector(remvFavAction), for: .touchUpInside)
                pageView.addSubview(remvFavBtn)
            }
            
            scrollView.contentSize.width = view.frame.width * CGFloat(i + 1)
            scrollView.addSubview(pageView)
        }
    }
    
    @objc func addFavAction(sender: UIButton!) {
        for pageView in scrollView.subviews {
            for view in pageView.subviews as [UIView] {
                if let btn = view as? UIButton {
                    if btn.tag == -sender.tag {
                        btn.isHidden = false
                        sender.isHidden = true
                    }
                }
            }
        }
        
        view.makeToast("\(weatherObject[abs(sender.tag)].cityName) was added to the Favorite List",
            duration: 2.0,
            position: .bottom)
        
        
        if var favList = defaults.array(forKey: "fav") {
            favList.append(weatherObject[abs(sender.tag)].cityName)
            defaults.set(favList, forKey: "fav")
        } else {
            var newfavList = [String]()
            newfavList.append(weatherObject[abs(sender.tag)].cityName)
            defaults.set(newfavList, forKey: "fav")
        }
    }
    
    @objc func remvFavAction(sender: UIButton!) {
        for pageView in scrollView.subviews {
            for view in pageView.subviews as [UIView] {
                if let btn = view as? UIButton {
                    if btn.tag == -sender.tag {
                        btn.isHidden = false
                        sender.isHidden = true
                    }
                }
            }
        }
        
        self.view.makeToast("\(weatherObject[abs(sender.tag)].cityName) was removed to the Favorite List",
            duration: 2.0,
            position: .bottom)
        
        
        if var favList = defaults.array(forKey: "fav") {
            favList = favList.filter {($0 as! String ) != weatherObject[abs(sender.tag)].cityName}
            defaults.set(favList, forKey: "fav")
        }
    }
    
    func updateWeatherForCurrentLocation (withLocation location: CLLocationCoordinate2D?) {
        if let location = location {
            WeatherModel.loadWeather(withLocation: location, completionHandler: { (weatherObject) in
                self.loadData(weatherObject: weatherObject, index: 0)
                SwiftSpinner.hide()
            })
        } else {
            SwiftSpinner.hide()
        }
    }
    
    func updateWeatherForLocation (location: String) {
        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let locationMark = placemarks?.first?.location {
                    WeatherModel.loadWeather(withLocation: locationMark.coordinate, completionHandler: { (weatherObject) in
                        self.resultWeatherObject = weatherObject
                        self.resultWeatherObject.cityName = location
                        if self.resultWeatherObject.weeklyLow != nil {
                            self.performSegue(withIdentifier: "toResultSegue", sender: self)
                        }
                        SwiftSpinner.hide()
                    })
                } else {
                    SwiftSpinner.hide()
                }
            }
        }
    }
    
    func updateWeatherForFavLocation (location: String, index: Int) {
        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let locationMark = placemarks?.first?.location {
                    WeatherModel.loadWeather(withLocation: locationMark.coordinate, completionHandler: { (weatherObject) in
                        self.firstSubView[index].cityName.text = location
                        self.loadData(weatherObject: weatherObject, index: index)
                    })
                }
            }
        }
    }
    
    func loadData(weatherObject: WeatherModel, index: Int) {
        firstSubView[index].weatherSum.text = weatherObject.summary
        firstSubView[index].weatherTemp.text = String(format:"%.0f", (weatherObject.temperature-32) * 5/9) + "°C"
        let iconString = iconDict[weatherObject.icon]
        firstSubView[index].weatherIcon.image = UIImage(named: iconString ?? "weather-sunny")
        secondSubView[index].humidity.text = String(format:"%.1f", weatherObject.humidity * 100) + " %"
        secondSubView[index].windSpeed.text = String(format:"%.2f", weatherObject.windSpeed) + " mph"
        secondSubView[index].visibility.text = String(format:"%.2f", weatherObject.visibility) + " km"
        secondSubView[index].pressure.text = String(format:"%.1f", weatherObject.pressure) + " mb"
        DispatchQueue.main.async { self.thirdSubView[index].reloadData() }
        self.weatherObject[index] = weatherObject
        self.weatherObject[index].cityName = self.firstSubView[index].cityName.text ?? ""
    }

    @IBAction func sendData(_ sender: Any) {
        if self.weatherObject[Int(round(scrollView.contentOffset.x / view.frame.width))].weeklyLow != nil {
            performSegue(withIdentifier: "toDetailSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toDetailSegue") {
            let detailVC = segue.destination as! DetailViewController
            detailVC.weatherObject = self.weatherObject[Int(round(scrollView.contentOffset.x / view.frame.width))]
        }
        if(segue.identifier == "toResultSegue"){
            let resultVC = segue.destination as! SearchResultViewController
            resultVC.weatherObject = self.resultWeatherObject
        }
    }
    
    
    func getPlace(for location: CLLocation?,
                  completion: @escaping (CLPlacemark?) -> Void) {
        if let location = location {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                
                guard error == nil else {
                    print("*** Error in \(#function): \(error!.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let placemark = placemarks?[0] else {
                    print("*** Error in \(#function): placemark is nil")
                    completion(nil)
                    return
                }
                
                completion(placemark)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        for i in 0..<viewNumber {
            if tableView == self.thirdSubView[i] {
                let cell = Bundle.main.loadNibNamed("ThirdSub", owner: self, options: nil)?.first as! ThirdSubView
                
                if let weeklyTime = self.weatherObject[i].weeklyTime {
                    let date = Date(timeIntervalSince1970: weeklyTime[indexPath.section+1] as! Double)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    cell.date.text = dateFormatter.string(from: date)
                }
                
                if let weeklyIcon = self.weatherObject[i].weeklyIcon {
                    let iconString = self.iconDict[weeklyIcon[indexPath.section+1] as! String]
                    cell.weatherIcon.image = UIImage(named: iconString ?? "weather-sunny")
                }
                
                if let sunriseTime = self.weatherObject[i].sunrise {
                    let date = Date(timeIntervalSince1970: sunriseTime[indexPath.section+1] as! Double)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    cell.sunriseTime.text = dateFormatter.string(from: date)
                }
              
                if let sunsetTime = self.weatherObject[i].sunset {
                    let date = Date(timeIntervalSince1970: sunsetTime[indexPath.section+1] as! Double)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    cell.sunsetTime.text = dateFormatter.string(from: date)
                }
                
                
                return cell
            }
        }
        
        if tableView == self.searchTable {
            let cell = Bundle.main.loadNibNamed("SearchHint", owner: self, options: nil)?.first as! SearchHintView
            cell.searchHint.text = self.searchHint[indexPath.section]
            return cell
        }
        
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        for i in 0..<self.viewNumber {
            if tableView == self.thirdSubView[i] && self.weatherObject.count > i {
                if let number = self.weatherObject[i].weeklyTime?.count {
                    return number-1
                } else {
                    return 0
                }
            }
        }
        
        if tableView == self.searchTable {
            return searchHint.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.searchTable {
            let result = tableView.cellForRow(at: indexPath) as! SearchHintView
            
            if let locationString = result.searchHint.text, !locationString.isEmpty {
                SwiftSpinner.show("Fetching Weather Details for \(locationString)...")
                updateWeatherForLocation(location: locationString)
            }
            
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(round(scrollView.contentOffset.x / view.frame.width))
    }

}
