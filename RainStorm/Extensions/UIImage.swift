//
//  UIImage.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 09/12/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// Returns an image for the given icon name (string)
    class func imageForIcon(with name: String) -> UIImage? {
        switch name {
            case "clear-day",
                 "clear-night",
                 "fog",
                 "rain",
                 "snow",
                 "sleet",
                 "wind":
                return UIImage(named: name)
            case "cloudy",
                 "partly-cloudy-day",
                 "partly-cloudy-night":
                return UIImage(named: "cloudy")
            default:
                return UIImage(named: "clear-day")
        }
    }
    
    /// Returns an image for the given Open-Meteo weathercode (int)
    class func imageForWeatherCode(_ code: Int) -> UIImage? {
        let iconName = WeatherCodeMapper.iconName(for: code)
        return UIImage(named: iconName)
    }
}
