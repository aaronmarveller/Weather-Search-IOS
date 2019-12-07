//
//  PhotoModel.swift
//  WeatherSearch
//
//  Created by 刘沛源 on 12/2/19.
//  Copyright © 2019 aaron. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct PhotoModel {
    
    var photoUrls: [Any]?
    
    
    init() {}
    
    init(jsonString: JSON) {
        self.photoUrls = jsonString["photoUrls"].arrayObject
    }
    
    static func loadPhotos(cityName: String, completionHandler: @escaping(_ section: PhotoModel) -> ()) {
        let basePath = "https://my-nodejs-aaron-csci571.appspot.com/api"
        let url = basePath + "/photohw9?"
        let params = ["city": cityName]
        
        Alamofire.request(url, parameters: params).responseJSON { (responseData) in
            switch responseData.result {
            case .success(let value):
                if let statusCode = responseData.response?.statusCode, statusCode == 200 {
                    let jsonString = JSON(value)
                    let photoModel = PhotoModel(jsonString: jsonString)
                    completionHandler(photoModel)
                }
                break
            case .failure(let error):
                print(error)
            }
        }
        
    }
}
