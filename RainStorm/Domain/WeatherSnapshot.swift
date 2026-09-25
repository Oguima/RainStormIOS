//
//  WeatherSnapshot.swift
//  RainStorm
//

import Foundation

/// Modelo de UI: o que a tela precisa para exibir o clima, já validado.
nonisolated struct WeatherSnapshot: Equatable, Sendable {

    struct Current: Equatable, Sendable {
        let date: Date
        let temperature: Double
        let windSpeed: Double
        let weatherCode: Int
        let isDay: Bool

        var iconName: String { WeatherCodeMapper.iconName(for: weatherCode, isDay: isDay) }
        var summary: LocalizedStringResource { WeatherCodeMapper.description(for: weatherCode) }
    }

    struct Day: Identifiable, Equatable, Sendable {
        let date: Date
        let temperatureMin: Double
        let temperatureMax: Double
        let windSpeedMax: Double
        let weatherCode: Int

        var id: Date { date }
        var iconName: String { WeatherCodeMapper.iconName(for: weatherCode) }
        var summary: LocalizedStringResource { WeatherCodeMapper.description(for: weatherCode) }
    }

    /// Fuso horário do local consultado; as datas são exibidas nele.
    let timeZone: TimeZone
    let current: Current
    let forecast: [Day]
}
