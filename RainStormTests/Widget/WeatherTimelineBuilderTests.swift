//
//  WeatherTimelineBuilderTests.swift
//  RainStormTests
//
//  `sample`: atual às 19:45 de 24/09 (São Paulo) e horas das 19:00 às 06:00 do dia 25.
//

import Foundation
import Testing
@testable import RainStorm

@Suite("WeatherTimelineBuilder", .tags(.widget))
struct WeatherTimelineBuilderTests {

    private let snapshot = WeatherSnapshot.sample

    private func date(day: Int, hour: Int, minute: Int = 0) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .saoPaulo
        return calendar.date(from: DateComponents(year: 2026, month: 9, day: day, hour: hour, minute: minute))!
    }

    private func build(now: Date, snapshot: WeatherSnapshot? = nil, staleSince: Date? = nil) -> WeatherTimelineBuilder.Result {
        WeatherTimelineBuilder.build(for: snapshot ?? self.snapshot, now: now, staleSince: staleSince, policy: .standard)
    }

    private func weather(_ entry: WeatherWidgetEntry) throws -> WeatherWidgetContent {
        guard case .weather(let content) = entry.content else {
            Issue.record("Entrada sem clima: \(entry.content)")
            throw CancellationError()
        }
        return content
    }

    @Test func firstEntryIsNowWithCurrentCondition() throws {
        let now = date(day: 24, hour: 19, minute: 50)
        let first = try #require(build(now: now).entries.first)

        #expect(first.date == now)
        #expect(try weather(first).condition == snapshot.current)
    }

    @Test func discardsPastAndCurrentHours() throws {
        let entries = build(now: date(day: 24, hour: 21, minute: 45)).entries

        // 19:00, 20:00 e 21:00 já passaram: a primeira hora futura é 22:00.
        #expect(entries.dropFirst().first?.date == date(day: 24, hour: 22))
        #expect(entries.dropFirst().allSatisfy { $0.date > date(day: 24, hour: 21, minute: 45) })
    }

    @Test func limitsFutureEntriesToPolicy() {
        let entries = build(now: date(day: 24, hour: 19, minute: 45)).entries

        #expect(entries.count == 1 + WeatherTimelinePolicy.standard.maxFutureEntries)
        #expect(entries.map(\.date) == entries.map(\.date).sorted())
    }

    @Test func futureEntriesUseTheHourlyCondition() throws {
        let entries = build(now: date(day: 24, hour: 19, minute: 45)).entries
        let hour = try #require(snapshot.hourly.first { $0.date == date(day: 24, hour: 22) })
        let entry = try #require(entries.first { $0.date == hour.date })
        let condition = try weather(entry).condition

        #expect(condition.date == hour.date)
        #expect(condition.temperature == hour.temperature)
        #expect(condition.windSpeed == hour.windSpeed)
        #expect(condition.weatherCode == hour.weatherCode)
        #expect(condition.isDay == hour.isDay)
    }

    @Test func dailyRangeFollowsTheEntryDayAcrossMidnight() throws {
        let entries = build(now: date(day: 24, hour: 19, minute: 45)).entries
        let beforeMidnight = try weather(try #require(entries.first { $0.date == date(day: 24, hour: 23) }))
        let afterMidnight = try weather(try #require(entries.first { $0.date == date(day: 25, hour: 0) }))

        #expect(beforeMidnight.temperatureMin == 12.8 && beforeMidnight.temperatureMax == 21.1)
        #expect(afterMidnight.temperatureMin == 15.1 && afterMidnight.temperatureMax == 26.2)
    }

    @Test func missingDayHasNoRange() throws {
        let noForecast = WeatherSnapshot(timeZone: snapshot.timeZone, current: snapshot.current,
                                         forecast: [], hourly: snapshot.hourly)
        let content = try weather(try #require(build(now: date(day: 24, hour: 19, minute: 45), snapshot: noForecast).entries.first))

        #expect(content.temperatureMin == nil && content.temperatureMax == nil)
    }

    @Test func emptyHourlyYieldsSingleEntry() {
        let noHourly = WeatherSnapshot(timeZone: snapshot.timeZone, current: snapshot.current, forecast: snapshot.forecast)
        #expect(build(now: date(day: 24, hour: 19, minute: 45), snapshot: noHourly).entries.count == 1)
    }

    @Test func reloadsAfterPolicyInterval() {
        let now = date(day: 24, hour: 19, minute: 45)
        #expect(build(now: now).reloadDate == now.addingTimeInterval(WeatherTimelinePolicy.standard.reloadInterval))
    }

    @Test func staleDatePropagatesToEveryEntry() throws {
        let fetchedAt = date(day: 24, hour: 19, minute: 45)
        let entries = build(now: date(day: 24, hour: 21, minute: 10), staleSince: fetchedAt).entries

        #expect(try entries.map { try weather($0).staleSince } == Array(repeating: fetchedAt, count: entries.count))
        #expect(try build(now: fetchedAt).entries.allSatisfy { try weather($0).staleSince == nil })
    }

    /// Cache das 19:45 lido às 23:20: a hora prevista das 23:00 vale mais que a observação antiga.
    @Test func staleNowEntryUsesTheLatestForecastHour() throws {
        let fetchedAt = date(day: 24, hour: 19, minute: 45)
        let now = date(day: 24, hour: 23, minute: 20)
        let first = try weather(try #require(build(now: now, staleSince: fetchedAt).entries.first))
        let hour = try #require(snapshot.hourly.first { $0.date == date(day: 24, hour: 23) })

        #expect(first.condition.date == hour.date)
        #expect(first.condition.temperature == hour.temperature)
    }

    @Test func freshNowEntryKeepsTheObservation() throws {
        let now = date(day: 24, hour: 20, minute: 10)
        #expect(try weather(try #require(build(now: now).entries.first)).condition == snapshot.current)
    }

    @Test func standardPolicyMatchesThePlan() {
        #expect(WeatherTimelinePolicy.standard.maxFutureEntries == 6)
        #expect(WeatherTimelinePolicy.standard.reloadInterval == 60 * 60)
        #expect(WeatherTimelinePolicy.standard.maxCacheAge == 12 * 60 * 60)
    }
}
