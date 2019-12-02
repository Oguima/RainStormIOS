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
    }
    
    struct ConditionsCurrently: Codable {
        let time: Date
        let icon: String
        let summary: String
        let windSpeed: Double
        let temperature: Double //Não tem no Daily :(
    }

    struct Daily: Codable {
        let data: [Conditions]

        struct Condictions: Codable {
            let time: Date
            let icon: String
            let windSpeed: Double
            let temperatureMin: Double
            let temperatureMax: Double
        }
    }

    let latitude: Double
    let longitude: Double

    let daily: Daily
    let currently: ConditionsCurrently
}
