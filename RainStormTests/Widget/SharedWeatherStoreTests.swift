//
//  SharedWeatherStoreTests.swift
//  RainStormTests
//

import CoreLocation
import Foundation
import Testing
@testable import RainStorm

/// Cada teste usa um domínio de UserDefaults próprio (nada vaza para o App Group real).
@Suite("SharedWeatherStore", .tags(.widget))
final class SharedWeatherStoreTests {

    private let suiteName = "SharedWeatherStoreTests.\(UUID().uuidString)"
    private let defaults: UserDefaults
    private let sut: SharedWeatherStore

    init() throws {
        defaults = try #require(UserDefaults(suiteName: suiteName))
        sut = SharedWeatherStore(defaults: defaults)
    }

    deinit {
        UserDefaults().removePersistentDomain(forName: suiteName)
    }

    @Test func startsEmpty() {
        #expect(sut.lastCoordinate == nil)
        #expect(sut.lastWeather == nil)
    }

    @Test func weatherRoundTrips() {
        let fetchedAt = Date(timeIntervalSince1970: 1_790_000_000)
        sut.save(.sample, fetchedAt: fetchedAt)

        #expect(sut.lastWeather == StoredWeather(snapshot: .sample, fetchedAt: fetchedAt))
    }

    @Test func coordinateRoundTrips() throws {
        sut.save(coordinate: StubLocationProvider.rioDeJaneiro.coordinate)

        let coordinate = try #require(sut.lastCoordinate)
        #expect(coordinate.latitude == StubLocationProvider.rioDeJaneiro.coordinate.latitude)
        #expect(coordinate.longitude == StubLocationProvider.rioDeJaneiro.coordinate.longitude)
    }

    @Test func corruptedDataReadsAsNil() {
        defaults.set(Data("not json".utf8), forKey: SharedWeatherStore.Key.weather)
        defaults.set(Data("{\"latitude\":1}".utf8), forKey: SharedWeatherStore.Key.coordinate)

        #expect(sut.lastWeather == nil)
        #expect(sut.lastCoordinate == nil)
    }
}
