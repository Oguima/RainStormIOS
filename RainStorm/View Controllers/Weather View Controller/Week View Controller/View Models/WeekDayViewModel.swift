//
//  WeekDayViewModel.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 03/01/20.
//  Copyright © 2020 Guima Games. All rights reserved.
//

import UIKit

struct weekDayViewModel {
    
    let weatherData: DarkSkyResponse.Daily.CondictionsDayly //ForecastWeatherCondictions
    
    private let dateFormatter = DateFormatter()
    
    var day: String {
        dateFormatter.dateFormat = "EEEE"
        
        return dateFormatter.string(from: weatherData.time)
    }
    
    var date: String {
        dateFormatter.dateFormat = "MMMM d"
        
        return dateFormatter.string(from: weatherData.time)
    }
    
    var temperature: String {
        let min = String(format: "%.1f ºF", weatherData.temperatureMin)
        let max = String(format: "%.1f ºF", weatherData.temperatureMax)
        
        return "\(min) - \(max)"
    }
    
    var windSpeed: String {
        return String(format: "%.f MPH" , weatherData.windSpeed)
    }
    
    var image: UIImage? {
        return UIImage.imageForIcon(with: weatherData.icon)
    }
    
}

/*
 //Falhou
extension WeekViewModel: WeekDayRepresentable {
    
}
 */
