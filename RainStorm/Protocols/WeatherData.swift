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
    
    var current: CurrentWeatherCondictions { get }
    //var forecast: [ForecastWeatherCondictions] { get }
    
    //var forecast: [RainStorm.DarkSkyResponse.Daily.CondictionsDayly] { get }
    //var forecast: [DailyCondictions] { get }
    var forecast: [DarkSkyResponse.Daily.CondictionsDayly] { get }
    //var daily: [DailyCondictions] { get }
}

protocol WeatherCondictions {
    var time: Date { get }
    var icon: String { get }
    var windSpeed: Double { get }
}

protocol CurrentWeatherCondictions: WeatherCondictions {
    var summary: String { get }
    //var temperature: Double { get }
}

protocol ForecastWeatherCondictions: WeatherCondictions {
    var summary: String { get }
    var temperatureMin: Double { get }
    var temperatureMax: Double { get }
    //var temperature: Double? { get }
}

protocol DailyCondictions { //: WeatherCondictions {
    //var summary: String { get }
    //var icon: String { get }
    //var data: [ForecastWeatherCondictions] { get }
    
    //var time: Date { get }
    //var icon: String { get }
    
    //var windSpeed: Double { get }
    //var temperature: Double? { get }
    
    //var summary: String { get }
    //var temperatureMin: Double { get }
    //var temperatureMax: Double { get }
    
    var time: Date { get }
    var summary: String { get }
    var icon: String { get }
    var windSpeed: Double { get }
    var temperatureMin: Double { get }
    var temperatureMax: Double { get }
}
