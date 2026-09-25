//
//  WeatherFormatterTests.swift
//  RainStormTests
//
//  Locale e fuso explícitos: o resultado não depende do simulador.
//

import Foundation
import Testing
@testable import RainStorm

@Suite("WeatherFormatter", .tags(.formatting))
struct WeatherFormatterTests {

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 0, _ minute: Int = 0) throws -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .saoPaulo
        return try #require(calendar.date(from: DateComponents(year: year, month: month, day: day,
                                                               hour: hour, minute: minute)))
    }

    // MARK: Temperatura e vento

    @Test(arguments: [(24.54, "24,5 °C"), (-3.0, "-3,0 °C"), (0.0, "0,0 °C")])
    func temperatureInBrazilianPortuguese(value: Double, expected: String) {
        #expect(WeatherFormatter.temperature(value, locale: .ptBR).normalizingSpaces == expected)
    }

    @Test func temperatureUsesFahrenheitInTheUnitedStates() {
        #expect(WeatherFormatter.temperature(24.54, locale: .enUS).normalizingSpaces == "76.2°F")
    }

    @Test func temperatureRangeJoinsMinAndMax() {
        #expect(WeatherFormatter.temperatureRange(min: 12.8, max: 21.1, locale: .ptBR).normalizingSpaces
                == "12,8 °C – 21,1 °C")
    }

    @Test func windSpeedInKilometersPerHour() {
        #expect(WeatherFormatter.windSpeed(6.5, locale: .ptBR).normalizingSpaces == "6 km/h")
    }

    @Test func windSpeedUsesMilesPerHourInTheUnitedStates() {
        #expect(WeatherFormatter.windSpeed(16.1, locale: .enUS).normalizingSpaces == "10 mph")
    }

    // MARK: Datas

    @Test func fullDateInBrazilianPortuguese() throws {
        let value = WeatherFormatter.fullDate(try date(2026, 9, 24), locale: .ptBR, timeZone: .saoPaulo)
        #expect(value == "quinta-feira, 24 de setembro de 2026")
    }

    /// Regressão do bug do "YYYY" (week-year) do antigo DayViewModel:
    /// 29/12/2025 pertence à semana ISO 1 de 2026.
    @Test func fullDateUsesCalendarYearNotWeekYear() throws {
        let value = WeatherFormatter.fullDate(try date(2025, 12, 29), locale: .ptBR, timeZone: .saoPaulo)
        #expect(value.contains("2025"))
        #expect(!value.contains("2026"))
    }

    @Test func timeUses24HourClockInBrazil() throws {
        let value = WeatherFormatter.time(try date(2026, 9, 24, 19, 45), locale: .ptBR, timeZone: .saoPaulo)
        #expect(value == "19:45")
    }

    @Test func timeUses12HourClockInTheUnitedStates() throws {
        let value = WeatherFormatter.time(try date(2026, 9, 24, 19, 45), locale: .enUS, timeZone: .saoPaulo)
        #expect(value.normalizingSpaces == "7:45 PM")
    }

    @Test func datesAreShownInTheForecastTimeZone() throws {
        // 00:30 em São Paulo ainda é dia 24, mesmo que em UTC já seja 24 03:30.
        let value = WeatherFormatter.dayAndMonth(try date(2026, 9, 24, 0, 30), locale: .ptBR, timeZone: .saoPaulo)
        #expect(value == "24 de setembro")
    }

    @Test func weekdayNames() throws {
        let thursday = try date(2026, 9, 24)
        #expect(WeatherFormatter.weekday(thursday, locale: .ptBR, timeZone: .saoPaulo) == "Quinta-feira")
        #expect(WeatherFormatter.shortWeekday(thursday, locale: .ptBR, timeZone: .saoPaulo) == "qui.")
        #expect(WeatherFormatter.weekday(thursday, locale: .enUS, timeZone: .saoPaulo) == "Thursday")
    }
}
