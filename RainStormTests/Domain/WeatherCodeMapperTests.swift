//
//  WeatherCodeMapperTests.swift
//  RainStormTests
//

import Foundation
import Testing
import UIKit
@testable import RainStorm

@Suite("WeatherCodeMapper", .tags(.domain))
struct WeatherCodeMapperTests {

    nonisolated static let knownCodes = [0, 1, 2, 3, 45, 48, 51, 53, 55, 56, 57, 61, 63, 65, 66, 67,
                             71, 73, 75, 77, 80, 81, 82, 85, 86, 95, 96, 99]

    @Test(arguments: [
        (0, "clear-day"), (1, "cloudy"), (3, "cloudy"), (45, "fog"), (48, "fog"),
        (51, "rain"), (61, "rain"), (67, "rain"), (71, "snow"), (77, "snow"),
        (80, "rain"), (85, "snow"), (95, "rain"), (99, "rain"), (1234, "clear-day")
    ])
    func iconName(code: Int, expected: String) {
        #expect(WeatherCodeMapper.iconName(for: code) == expected)
    }

    @Test func clearSkyAtNightUsesNightIcon() {
        #expect(WeatherCodeMapper.iconName(for: 0, isDay: false) == "clear-night")
        #expect(WeatherCodeMapper.iconName(for: 3, isDay: false) == "cloudy")
    }

    /// O `accessoryInline` do widget só desenha SF Symbols (os PNGs do catálogo somem).
    @Test(arguments: [
        (0, true, "sun.max.fill"), (0, false, "moon.stars.fill"), (2, true, "cloud.fill"),
        (45, true, "cloud.fog.fill"), (61, true, "cloud.rain.fill"), (71, true, "cloud.snow.fill"),
        (95, true, "cloud.bolt.rain.fill"), (1234, true, "sun.max.fill")
    ])
    func systemImageName(code: Int, isDay: Bool, expected: String) {
        #expect(WeatherCodeMapper.systemImageName(for: code, isDay: isDay) == expected)
    }

    @Test(arguments: knownCodes)
    func systemImageExists(code: Int) {
        #expect(UIImage(systemName: WeatherCodeMapper.systemImageName(for: code, isDay: true)) != nil)
        #expect(UIImage(systemName: WeatherCodeMapper.systemImageName(for: code, isDay: false)) != nil)
    }

    @Test(arguments: knownCodes)
    func knownCodeHasDescription(code: Int) {
        #expect(WeatherCodeMapper.description(for: code).key != "Unknown")
    }

    @Test(arguments: knownCodes + [1234])
    func descriptionIsTranslatedToPortuguese(code: Int) {
        var resource = WeatherCodeMapper.description(for: code)
        resource.locale = .ptBR
        #expect(String(localized: resource) != resource.key, "Falta tradução pt-BR para '\(resource.key)'")
    }

    @Test func translatesSlightRain() {
        var resource = WeatherCodeMapper.description(for: 61)
        resource.locale = .ptBR
        #expect(String(localized: resource) == "Chuva fraca")
    }
}
