//
//  DayViewModel.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 03/12/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//
// Transformar os dados que o usuário entenda...

import UIKit

struct DayViewModel {
    
    let weatherData: CurrentWeatherConditions
    
    //Ajuste do formato de datas...
    private let dateFormatter = DateFormatter()
    
    var date: String {
        dateFormatter.dateFormat = "EEE, MMMM d YYYY"
        
        return dateFormatter.string(from: weatherData.time)
    }
    
    var time: String {
        dateFormatter.dateFormat = "hh:mm a"
        
        return dateFormatter.string(from: weatherData.time)
    }
    
    var summary: String {
        return weatherData.summary
    }

    var temperature: String {
        // Open-Meteo já retorna em Celsius
        return String(format: "%.1f ºC", weatherData.temperature)
    }
    
    var windSpeed: String {
        // Open-Meteo já retorna em km/h
        return String(format: "%.f km/h", weatherData.windSpeed)
    }
    
    //Imagens: http://adamwhitcroft.com/climacons/
    var image: UIImage? {
        return UIImage.imageForIcon(with: weatherData.icon)
    }
    
}
