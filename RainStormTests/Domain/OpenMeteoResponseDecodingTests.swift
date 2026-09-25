//
//  OpenMeteoResponseDecodingTests.swift
//  RainStormTests
//
//  Fixtures derivadas de uma resposta real da Open-Meteo para São Paulo (24/09/2026).
//

import Foundation
import Testing
@testable import RainStorm

@Suite("OpenMeteoResponse", .tags(.decoding))
struct OpenMeteoResponseDecodingTests {

    private func decode(_ fixture: String) throws -> OpenMeteoResponse {
        let data = try #require(Fixture.data(fixture), "Fixture '\(fixture)' não encontrada")
        return try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
    }

    private func components(_ date: Date, in timeZone: TimeZone) -> DateComponents {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    }

    @Test func decodesRecordedResponse() throws {
        let response = try decode("forecast_success")

        #expect(response.timeZone.identifier == "America/Sao_Paulo")
        #expect(response.forecast.count == 7)
        #expect(response.current.temperature == 15.9)
        #expect(response.current.windSpeed == 6.5)
        #expect(response.current.weatherCode == 3)
        #expect(response.current.isDay == false)
        #expect(response.forecast.first?.temperatureMax == 21.1)
        #expect(response.forecast.first?.temperatureMin == 12.8)
    }

    @Test func currentTimeIsInterpretedInTheLocationTimeZone() throws {
        let response = try decode("forecast_success")
        let local = components(response.current.date, in: .saoPaulo)

        #expect(local.year == 2026 && local.month == 9 && local.day == 24)
        #expect(local.hour == 19 && local.minute == 45)
    }

    @Test func dailyDatesAreLocalMidnight() throws {
        let response = try decode("forecast_success")

        for (offset, day) in response.forecast.enumerated() {
            let local = components(day.date, in: .saoPaulo)
            #expect(local.day == 24 + offset)
            #expect(local.hour == 0 && local.minute == 0)
        }
    }

    @Test func fallsBackToUTCOffsetWhenTimeZoneIsMissing() throws {
        let response = try decode("forecast_without_timezone")
        #expect(response.timeZone.secondsFromGMT() == -3 * 3600)
    }

    @Test func mismatchedDailyArraysThrowInsteadOfCrashing() {
        #expect(throws: DecodingError.self) {
            try decode("forecast_mismatched_arrays")
        }
    }

    @Test func invalidDateThrowsInsteadOfBecomingToday() {
        #expect(throws: DecodingError.self) {
            try decode("forecast_invalid_date")
        }
    }

    @Test func snapshotCarriesTimeZoneAndForecast() throws {
        let response = try decode("forecast_success")
        let snapshot = response.snapshot

        #expect(snapshot.timeZone == response.timeZone)
        #expect(snapshot.current == response.current)
        #expect(snapshot.forecast == response.forecast)
    }
}
