//
//  ThirdSubView.swift
//  WeatherSearch
//
//  Created by 刘沛源 on 12/1/19.
//  Copyright © 2019 aaron. All rights reserved.
//

import UIKit

class ThirdSubView: UITableViewCell {
    
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var weatherIcon: UIImageView!
    
    @IBOutlet weak var sunriseTime: UILabel!
    
    @IBOutlet weak var sunsetTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
