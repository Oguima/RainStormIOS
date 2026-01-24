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
    private var longitude: Double {
        return location.coordinate.longitude
    }
    
    var url: URL {
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current_weather", value: "true"),
            URLQueryItem(name: "daily", value: "temperature_2m_max,temperature_2m_min,weathercode,windspeed_10m_max"),
            URLQueryItem(name: "timezone", value: "auto")
        ]
        return components.url!
    }
}
