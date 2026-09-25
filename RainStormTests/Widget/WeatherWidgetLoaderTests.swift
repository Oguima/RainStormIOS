//
//  WeatherWidgetLoaderTests.swift
//  RainStormTests
//

import CoreLocation
import Foundation
import Testing
@testable import RainStorm

@Suite("WeatherWidgetLoader", .tags(.widget))
final class WeatherWidgetLoaderTests {

    private let suiteName = "WeatherWidgetLoaderTests.\(UUID().uuidString)"
    private let store: SharedWeatherStore
    private let now = WeatherSnapshot.sample.current.date.addingTimeInterval(5 * 60)

    init() throws {
        store = SharedWeatherStore(defaults: try #require(UserDefaults(suiteName: suiteName)))
    }

    deinit {
        UserDefaults().removePersistentDomain(forName: suiteName)
    }

    private func load(_ result: Result<WeatherSnapshot, WeatherDataError>) async -> (WeatherTimelineBuilder.Result, MockWeatherService) {
        let service = MockWeatherService(result: result)
        let loader = WeatherWidgetLoader(service: service, store: store)
        return (await loader.timeline(now: now), service)
    }

    @Test func successIsFreshAndCached() async throws {
        let (result, _) = await load(.success(.sample))

        #expect(result == WeatherTimelineBuilder.build(for: .sample, now: now, staleSince: nil, policy: .standard))
        #expect(store.lastWeather == StoredWeather(snapshot: .sample, fetchedAt: now))
    }

    @Test func failureWithCacheIsStale() async {
        let fetchedAt = now.addingTimeInterval(-2 * 60 * 60)
        store.save(.sample, fetchedAt: fetchedAt)

        let (result, _) = await load(.failure(.offline))

        #expect(result == WeatherTimelineBuilder.build(for: .sample, now: now, staleSince: fetchedAt, policy: .standard))
    }

    /// Um dia sem rede: não mostrar o clima de ontem como se fosse atual.
    @Test func failureWithExpiredCacheIsUnavailable() async {
        store.save(.sample, fetchedAt: now.addingTimeInterval(-13 * 60 * 60))

        let (result, _) = await load(.failure(.offline))

        #expect(result.entries == [WeatherWidgetEntry(date: now, content: .unavailable)])
    }

    @Test func failureWithoutCacheIsUnavailable() async {
        let (result, _) = await load(.failure(.serviceUnavailable))

        #expect(result.entries == [WeatherWidgetEntry(date: now, content: .unavailable)])
        #expect(result.reloadDate > now)
    }

    @Test func withoutSavedCoordinateUsesSaoPaulo() async throws {
        let (_, service) = await load(.success(.sample))

        let requested = try #require(service.requestedCoordinates.first)
        #expect(requested.latitude == Defaults.location.coordinate.latitude)
        #expect(requested.longitude == Defaults.location.coordinate.longitude)
    }

    @Test func usesTheLastCoordinateSavedByTheApp() async throws {
        store.save(coordinate: StubLocationProvider.rioDeJaneiro.coordinate)

        let (_, service) = await load(.success(.sample))

        let requested = try #require(service.requestedCoordinates.first)
        #expect(requested.latitude == StubLocationProvider.rioDeJaneiro.coordinate.latitude)
        #expect(requested.longitude == StubLocationProvider.rioDeJaneiro.coordinate.longitude)
    }
}

@Suite("URLSession.widget", .tags(.widget))
struct WidgetURLSessionTests {

    /// Em rede ruim o padrão de 60 s pode estourar o tempo da extensão antes do fallback para o cache.
    @Test func timesOutBeforeWidgetKitGivesUp() {
        let configuration = URLSession.widget.configuration
        #expect(configuration.timeoutIntervalForRequest == 15)
        #expect(configuration.timeoutIntervalForResource == 20)
    }
}

@Suite("WidgetCenterSync", .tags(.widget))
final class WidgetCenterSyncTests {

    private let suiteName = "WidgetCenterSyncTests.\(UUID().uuidString)"
    private let store: SharedWeatherStore
    private var reloadedKinds: [String] = []
    private let now = Date(timeIntervalSince1970: 1_790_000_000)

    init() throws {
        store = SharedWeatherStore(defaults: try #require(UserDefaults(suiteName: suiteName)))
    }

    deinit {
        UserDefaults().removePersistentDomain(forName: suiteName)
    }

    private func makeSync() -> WidgetCenterSync {
        WidgetCenterSync(store: store, now: { [now] in now }, reloadTimelines: { [weak self] in self?.reloadedKinds.append($0) })
    }

    @Test func deviceFetchSavesCoordinateSnapshotAndReloads() throws {
        makeSync().didFetch(.sample, deviceCoordinate: StubLocationProvider.rioDeJaneiro.coordinate)

        #expect(store.lastWeather == StoredWeather(snapshot: .sample, fetchedAt: now))
        #expect(try #require(store.lastCoordinate).latitude == StubLocationProvider.rioDeJaneiro.coordinate.latitude)
        #expect(reloadedKinds == [WidgetKind.currentWeather])
    }

    @Test func fallbackFetchKeepsTheLastRealCoordinate() throws {
        store.save(coordinate: StubLocationProvider.rioDeJaneiro.coordinate)

        makeSync().didFetch(.sample, deviceCoordinate: nil)

        #expect(try #require(store.lastCoordinate).latitude == StubLocationProvider.rioDeJaneiro.coordinate.latitude)
        #expect(store.lastWeather?.snapshot == .sample)
        #expect(reloadedKinds == [WidgetKind.currentWeather])
    }
}
