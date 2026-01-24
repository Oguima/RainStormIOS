//
//  WeekViewModel.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 03/12/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import Foundation

struct WeekViewModel {
    
    let weatherData: [OpenMeteoResponse.DailyForecast]
    
    var numberOfDays: Int {
        return weatherData.count
    }
    
    func viewModel(for index: Int) -> WeekDayViewModel {
        return WeekDayViewModel(weatherData: weatherData[index])
    }
    
}
