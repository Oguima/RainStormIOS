//
//  WeatherRequest.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 21/11/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import CoreLocation
import Foundation

nonisolated struct WeatherRequest: Sendable {
    let baseUrl: URL
    let coordinate: CLLocationCoordinate2D

    var url: URL {
        var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
            URLQueryItem(name: "current_weather", value: "true"),
            URLQueryItem(name: "daily", value: "temperature_2m_max,temperature_2m_min,weathercode,windspeed_10m_max"),
            URLQueryItem(name: "timezone", value: "auto")
        ]
        return components.url!
    }
}
