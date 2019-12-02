//
//  WeatherRequest.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 21/11/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import Foundation
import CoreLocation //Para pegar a posição do usuário

struct WeatherRequest {
    let baseUrl: URL
    
    //CoreLocation, para pegar a posição do user
    let location: CLLocation
    
    private var latitude: Double {
        return location.coordinate.latitude
    }
    private var longitude: Double{
        return location.coordinate.longitude
    }
    
    var url: URL {
        return baseUrl.appendingPathComponent("\(latitude),\(longitude)")
    }
}
