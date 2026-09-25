//
//  WeatherSnapshot.swift
//  RainStorm
//

import Foundation

/// Modelo de UI: o que a tela precisa para exibir o clima, já validado.
/// `Codable` para o widget ler o último snapshot do App Group.
nonisolated struct WeatherSnapshot: Equatable, Sendable, Codable {

    struct Current: Equatable, Sendable, Codable {
        let date: Date
        let temperature: Double
        let windSpeed: Double
        let weatherCode: Int
        let isDay: Bool

        var iconName: String { WeatherCodeMapper.iconName(for: weatherCode, isDay: isDay) }
        var summary: LocalizedStringResource { WeatherCodeMapper.description(for: weatherCode) }
    }

    struct Day: Identifiable, Equatable, Sendable, Codable {
        let date: Date
        let temperatureMin: Double
        let temperatureMax: Double
        let windSpeedMax: Double
        let weatherCode: Int

        var id: Date { date }
        var iconName: String { WeatherCodeMapper.iconName(for: weatherCode) }
        var summary: LocalizedStringResource { WeatherCodeMapper.description(for: weatherCode) }
    }

    /// Uma hora da previsão horária: alimenta as entradas futuras da timeline do widget.
    struct Hour: Equatable, Sendable, Codable {
        let date: Date
        let temperature: Double
        let windSpeed: Double
        let weatherCode: Int
        let isDay: Bool
    }

    /// Fuso horário do local consultado; as datas são exibidas nele.
    let timeZone: TimeZone
    let current: Current
    let forecast: [Day]
    /// Próximas horas a partir da hora atual (vazio em respostas sem `hourly`).
    var hourly: [Hour] = []
}
