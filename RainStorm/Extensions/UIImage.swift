//
//  UIImage.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 09/12/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import UIKit

extension UIImage {
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
}
