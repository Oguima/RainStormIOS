//
//  OpenMeteoResponse.swift
//  RainStorm
//
//  Migrated from DarkSkyResponse to Open-Meteo API
//  Copyright © 2019 Guima Games. All rights reserved.
//

import Foundation

struct OpenMeteoResponse: Codable {
    
    let latitude: Double
    let longitude: Double
    
    let currentWeather: CurrentWeather
    let daily: Daily
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case currentWeather = "current_weather"
        case daily
    }
    
    struct CurrentWeather: Codable {
        let timeString: String
        let temperature: Double
        let windspeed: Double
        let weathercode: Int
        
        enum CodingKeys: String, CodingKey {
            case timeString = "time"
            case temperature
            case windspeed
            case weathercode
        }
        
        // Computed property para obter o nome do ícone baseado no weathercode
        var icon: String {
            return WeatherCodeMapper.iconName(for: weathercode)
        }
        
        // Summary baseado no weathercode
        var summary: String {
            return WeatherCodeMapper.description(for: weathercode)
        }
    }
    
    struct Daily: Codable {
        let time: [String]
        let temperatureMin: [Double]
        let temperatureMax: [Double]
        let weathercode: [Int]
        let windspeedMax: [Double]
        
        enum CodingKeys: String, CodingKey {
            case time
            case temperatureMin = "temperature_2m_min"
            case temperatureMax = "temperature_2m_max"
            case weathercode
            case windspeedMax = "windspeed_10m_max"
        }
    }
}

// MARK: - Helper para criar array de previsão diária
extension OpenMeteoResponse {
    
    struct DailyForecast {
        let date: Date
        let temperatureMin: Double
        let temperatureMax: Double
        let weathercode: Int
        let windspeed: Double
        
        var icon: String {
            return WeatherCodeMapper.iconName(for: weathercode)
        }
        
        var summary: String {
            return WeatherCodeMapper.description(for: weathercode)
        }
    }
    
    var dailyForecasts: [DailyForecast] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return daily.time.indices.map { index in
            let date = formatter.date(from: daily.time[index]) ?? Date()
            return DailyForecast(
                date: date,
                temperatureMin: daily.temperatureMin[index],
                temperatureMax: daily.temperatureMax[index],
                weathercode: daily.weathercode[index],
                windspeed: daily.windspeedMax[index]
            )
        }
    }
}

// MARK: - WeatherData Protocol Conformance
extension OpenMeteoResponse: WeatherData {
    
    var current: CurrentWeatherConditions {
        return currentWeather
    }
    
    var forecast: [DailyForecast] {
        return dailyForecasts
    }
}

extension OpenMeteoResponse.CurrentWeather: CurrentWeatherConditions {
    var time: Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return formatter.date(from: timeString) ?? Date()
    }
    
    var windSpeed: Double {
        return windspeed
    }
}
