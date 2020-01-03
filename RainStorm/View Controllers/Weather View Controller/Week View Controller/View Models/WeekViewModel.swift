//
//  WeekViewModel.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 03/12/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import Foundation

struct WeekViewModel {
    
    //let weatherData: [RainStorm.DarkSkyResponse.Daily.CondictionsDayly] //[ForecastWeatherCondictions]
    let weatherData: [DarkSkyResponse.Daily.CondictionsDayly] //[ForecastWeatherCondictions]
    
    var numberOfDays: Int {
        return weatherData.count
    }
    
    func viewModel(for index: Int) -> weekDayViewModel {
        return weekDayViewModel(weatherData: weatherData[index])
    }
    
}
