//
//  WeatherData.swift
//  RainStorm
//  - Adding Flexibility With Protocols
//
//  Created by Rafael Guimaraes Dos Santos on 03/12/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import Foundation

protocol WeatherData {
    var latitude: Double { get }
    var longitude: Double { get }
    
    var current: CurrentWeatherConditions { get }
    var forecast: [OpenMeteoResponse.DailyForecast] { get }
}

protocol WeatherConditions {
    var time: Date { get }
    var icon: String { get }
    var windSpeed: Double { get }
}

protocol CurrentWeatherConditions: WeatherConditions {
    var summary: String { get }
    var temperature: Double { get }
}

protocol ForecastWeatherConditions: WeatherConditions {
    var summary: String { get }
    var temperatureMin: Double { get }
    var temperatureMax: Double { get }
}
