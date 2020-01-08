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
    
    let weatherData: CurrentWeatherCondictions
    let cv = Conversions()
    
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

    /*
    var temperature: String {
        return String(format: "%.1f ºF", weatherData.temperature)
    }
 */
    var temperature: String {
        //return String(format: "%.1f ºF", weatherData.temperature)
        //return String(format: "%.1f ºC", cv.fahrenheitToCelsius(tempInF:weatherData.temperature)) //Convertido
        return "" //Não tem nos dados... TODO
    }
    
    var windSpeed: String {
        //return String(format: "%.f MPH", weatherData.windSpeed)
        //Convertendo: MPH para Kmh : milesToKilometers
        let speed = cv.milesToKilometers(speedInMPH: weatherData.windSpeed)
        return String(format: "%.f Km", speed)
    }
    
    //Imagens: http://adamwhitcroft.com/climacons/
    var image: UIImage? {
        return UIImage.imageForIcon(with: weatherData.icon)
    }
    
}
