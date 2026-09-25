//
//  WeatherSnapshot+Sample.swift
//  RainStorm
//
//  Dados de exemplo sem #if DEBUG: o widget precisa deles em Release para o
//  placeholder e a galeria de widgets. Também servem de base para o `fixture` dos testes.
//

import Foundation

extension WeatherSnapshot {

    nonisolated static let sample: WeatherSnapshot = {
        let timeZone = TimeZone(identifier: "America/Sao_Paulo")!
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let start = calendar.date(from: DateComponents(year: 2026, month: 9, day: 24))!

        let days: [(min: Double, max: Double, wind: Double, code: Int)] = [
            (12.8, 21.1, 14.0, 3),
            (15.1, 26.2, 11.2, 2),
            (16.8, 30.2, 9.7, 0),
            (18.1, 30.6, 12.5, 1),
            (17.5, 33.6, 16.1, 80),
            (19.2, 34.3, 21.4, 95),
            (19.2, 32.7, 18.0, 61)
        ]

        // 12 horas a partir das 19:00, como a API devolve (a primeira hora é a atual).
        let temperatures = [15.9, 15.5, 15.4, 15.4, 15.3, 15.0, 14.9, 14.9, 14.9, 14.9, 15.1, 16.5]

        return WeatherSnapshot(
            timeZone: timeZone,
            current: Current(date: calendar.date(byAdding: .minute, value: 19 * 60 + 45, to: start)!,
                             temperature: 15.9,
                             windSpeed: 6.5,
                             weatherCode: 3,
                             isDay: false),
            forecast: days.enumerated().map { offset, day in
                Day(date: calendar.date(byAdding: .day, value: offset, to: start)!,
                    temperatureMin: day.min,
                    temperatureMax: day.max,
                    windSpeedMax: day.wind,
                    weatherCode: day.code)
            },
            hourly: temperatures.enumerated().map { offset, temperature in
                let hour = 19 + offset
                return Hour(date: calendar.date(byAdding: .hour, value: hour, to: start)!,
                            temperature: temperature,
                            windSpeed: 6.5,
                            weatherCode: 3,
                            isDay: (6..<18).contains(hour % 24))
            }
        )
    }()
}
