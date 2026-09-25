//
//  WeatherCodeMapper.swift
//  RainStorm
//
//  Maps Open-Meteo WMO weather codes to icon names and descriptions.
//

import Foundation

nonisolated enum WeatherCodeMapper {

    /// Returns the asset icon name for the given WMO weathercode.
    /// `isDay == false` turns clear sky into the night icon.
    static func iconName(for code: Int, isDay: Bool = true) -> String {
        switch code {
        case 0:
            return isDay ? "clear-day" : "clear-night"
        case 1, 2, 3:
            return "cloudy"
        case 45, 48:
            return "fog"
        case 51, 53, 55, 56, 57:
            return "rain" // Drizzle
        case 61, 63, 65, 66, 67:
            return "rain" // Rain
        case 71, 73, 75, 77:
            return "snow"
        case 80, 81, 82:
            return "rain" // Rain showers
        case 85, 86:
            return "snow" // Snow showers
        case 95, 96, 99:
            return "rain" // Thunderstorm
        default:
            return "clear-day"
        }
    }

    /// SF Symbol equivalente ao ícone: o `accessoryInline` do widget não desenha imagens do catálogo.
    static func systemImageName(for code: Int, isDay: Bool = true) -> String {
        switch code {
        case 1, 2, 3: "cloud.fill"
        case 45, 48: "cloud.fog.fill"
        case 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82: "cloud.rain.fill"
        case 71, 73, 75, 77, 85, 86: "cloud.snow.fill"
        case 95, 96, 99: "cloud.bolt.rain.fill"
        default: isDay ? "sun.max.fill" : "moon.stars.fill"
        }
    }

    /// Returns a localizable description for the weathercode (translations in Localizable.xcstrings).
    static func description(for code: Int) -> LocalizedStringResource {
        switch code {
        case 0: "Clear sky"
        case 1: "Mainly clear"
        case 2: "Partly cloudy"
        case 3: "Overcast"
        case 45: "Fog"
        case 48: "Depositing rime fog"
        case 51: "Light drizzle"
        case 53: "Moderate drizzle"
        case 55: "Dense drizzle"
        case 56: "Light freezing drizzle"
        case 57: "Dense freezing drizzle"
        case 61: "Slight rain"
        case 63: "Moderate rain"
        case 65: "Heavy rain"
        case 66: "Light freezing rain"
        case 67: "Heavy freezing rain"
        case 71: "Slight snow fall"
        case 73: "Moderate snow fall"
        case 75: "Heavy snow fall"
        case 77: "Snow grains"
        case 80: "Slight rain showers"
        case 81: "Moderate rain showers"
        case 82: "Violent rain showers"
        case 85: "Slight snow showers"
        case 86: "Heavy snow showers"
        case 95: "Thunderstorm"
        case 96: "Thunderstorm with slight hail"
        case 99: "Thunderstorm with heavy hail"
        default: "Unknown"
        }
    }
}
