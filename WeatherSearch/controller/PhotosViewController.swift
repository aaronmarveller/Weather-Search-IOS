//
//  PhotosViewController.swift
//  WeatherSearch
//
//  Created by 刘沛源 on 12/2/19.
//  Copyright © 2019 aaron. All rights reserved.
//

import UIKit
import SwiftSpinner

class PhotosViewController: UIViewController {

    var cityName: String = ""
    
    var photoModel = PhotoModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SwiftSpinner.show("Fetching Google Images...")
        updatePhotos(cityName: cityName)
    }
    
    func updatePhotos(cityName: String) {
        if cityName != "" {
            PhotoModel.loadPhotos(cityName: cityName) { (photoModel) in
                let photoModel: PhotoModel = photoModel
                if let photoUrls = photoModel.photoUrls {
                    self.updateSubView(photoUrls: photoUrls)
                }
                SwiftSpinner.hide()
            }
        } else {
            SwiftSpinner.hide()
        }
        
    }
    
    func updateSubView(photoUrls: [Any]) {
        if let photosView = Bundle.main.loadNibNamed("Photos", owner: self, options: nil)?.first as? PhotosView {
            for i in 0..<photoUrls.count {
                if let url = URL(string: photoUrls[i] as? String ?? ""){
                    do {
                        let data = try Data(contentsOf: url)
                        let image = UIImage(data: data)
                        let imageView = UIImageView()
                        let yPosition = photosView.scrollView.frame.height * 0.6 * CGFloat(i)
                        imageView.frame.size.width = photosView.scrollView.frame.width - 10
                        imageView.frame.size.height = photosView.scrollView.frame.height * 0.6
                        imageView.frame.origin.x = 10
                        imageView.frame.origin.y = yPosition
                        imageView.image = image
                        photosView.scrollView.contentSize.height = photosView.scrollView.frame.height * 0.6 * CGFloat(i + 1)
                        photosView.scrollView.addSubview(imageView)
                    } catch let err {
                        print("error \(err.localizedDescription)")
                    }
                }
            }
            view.addSubview(photosView)
        }
    }
}
