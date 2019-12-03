//
//  DarkSkyResponse.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 02/12/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import Foundation

struct DarkSkyResponse: Codable {

    struct Conditions: Codable {
        let time: Date
        let icon: String
        let summary: String
        let windSpeed: Double
        let temperature: Double  //Não tem no Daily :(
    }

    struct Daily: Codable {
        let data: [CondictionsDayly]

        struct CondictionsDayly: Codable {
            let time: Date
            let summary: String
            let icon: String
            let windSpeed: Double
            let temperatureMin: Double
            let temperatureMax: Double
        }
    }

    let latitude: Double
    let longitude: Double

    let daily: Daily
    let currently: Conditions
}

extension DarkSkyResponse: WeatherData {
    
    var forecast: [Daily.CondictionsDayly] { //[DailyCondictions] { //[RainStorm.DarkSkyResponse.Daily.CondictionsDayly] {
        
        return daily.data  as! [Daily.CondictionsDayly] //[DailyCondictions] //as! [RainStorm.DarkSkyResponse.Daily.CondictionsDayly]  //.data as! [DailyCondictions]
    }
    
    var current: CurrentWeatherCondictions {
        return currently
    }
    
    /*var forecast: [ForecastWeatherCondictions] {
        return daily.data as! [ForecastWeatherCondictions] //as! [ForecastWeatherCondictions]
    }*/
    
}

extension DarkSkyResponse.Conditions: CurrentWeatherCondictions {
    
}
