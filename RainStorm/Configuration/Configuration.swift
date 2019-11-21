//
//  Configuration.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 21/11/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import Foundation
import CoreLocation

enum Defaults {
    //Padrão...
    static let location = CLLocation(latitude: 37.335114, longitude: -122.008928)
    //static let latitude: Double = 37.335114
    //static let longitude: Double = -122.008928
}

enum WeatherService {
    private static let apiKey = "d338cfc01c45f8ae583757dba7c77dbc"
    private static let baseUrl = URL(string: "https://api.darksky.net/forecast/")!
    
    static var authenticatedBaseUrl: URL {
        return baseUrl.appendingPathComponent(apiKey)
    }
}
