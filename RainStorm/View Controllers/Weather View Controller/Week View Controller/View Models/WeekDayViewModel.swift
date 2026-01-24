//
//  WeekDayViewModel.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 03/01/20.
//  Copyright © 2020 Guima Games. All rights reserved.
//

import UIKit

struct WeekDayViewModel {
    
    let weatherData: OpenMeteoResponse.DailyForecast
    
    private let dateFormatter = DateFormatter()
    
    var day: String {
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: weatherData.date)
    }
    
    var date: String {
        dateFormatter.dateFormat = "MMMM d"
        return dateFormatter.string(from: weatherData.date)
    }
    
    var temperature: String {
        // Open-Meteo já retorna em Celsius - sem necessidade de conversão
        let min = String(format: "%.1f ºC", weatherData.temperatureMin)
        let max = String(format: "%.1f ºC", weatherData.temperatureMax)
        return "\(min) - \(max)"
    }
    
    var windSpeed: String {
        // Open-Meteo já retorna em km/h - sem necessidade de conversão
        return String(format: "%.f km/h", weatherData.windspeed)
    }
    
    var image: UIImage? {
        return UIImage.imageForIcon(with: weatherData.icon)
    }
    
}
