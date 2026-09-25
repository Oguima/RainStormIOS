//
//  WeatherViewModelTests.swift
//  RainStormTests
//

import CoreLocation
import Testing
@testable import RainStorm

@Suite("WeatherViewModel", .tags(.viewModel))
struct WeatherViewModelTests {

    @Test func startsLoading() {
        let sut = WeatherViewModel(service: MockWeatherService(result: .success(.fixture)),
                                   location: StubLocationProvider(.success(StubLocationProvider.saoPaulo)))
        #expect(sut.state == .loading)
    }

    @Test func loadsForecastForDeviceLocation() async throws {
        let service = MockWeatherService(result: .success(.fixture))
        let sut = WeatherViewModel(service: service,
                                   location: StubLocationProvider(.success(StubLocationProvider.rioDeJaneiro)))

        await sut.load()

        #expect(sut.state == .loaded(.fixture, .device))
        let requested = try #require(service.requestedCoordinates.first)
        #expect(requested.latitude == StubLocationProvider.rioDeJaneiro.coordinate.latitude)
        #expect(requested.longitude == StubLocationProvider.rioDeJaneiro.coordinate.longitude)
    }

    @Test(arguments: [LocationError.notAuthorized, .unavailable])
    func fallsBackToDefaultLocationWhenLocationFails(error: LocationError) async throws {
        let service = MockWeatherService(result: .success(.fixture))
        let sut = WeatherViewModel(service: service, location: StubLocationProvider(.failure(error)))

        await sut.load()

        #expect(sut.state == .loaded(.fixture, .fallback))
        let requested = try #require(service.requestedCoordinates.first)
        #expect(requested.latitude == Defaults.location.coordinate.latitude)
        #expect(requested.longitude == Defaults.location.coordinate.longitude)
    }

    @Test(arguments: [WeatherDataError.offline, .serviceUnavailable, .invalidData])
    func exposesServiceError(error: WeatherDataError) async {
        let sut = WeatherViewModel(service: MockWeatherService(result: .failure(error)),
                                   location: StubLocationProvider(.success(StubLocationProvider.saoPaulo)))

        await sut.load()

        #expect(sut.state == .failed(error))
    }

    @Test func retryAfterFailureRecovers() async {
        let sut = WeatherViewModel(service: MockWeatherService(result: .success(.fixture)),
                                   location: StubLocationProvider(.success(StubLocationProvider.saoPaulo)),
                                   initialState: .failed(.offline))

        await sut.load()

        #expect(sut.state == .loaded(.fixture, .device))
    }

    @Test func refreshFetchesAgain() async {
        let service = MockWeatherService(result: .success(.fixture))
        let sut = WeatherViewModel(service: service,
                                   location: StubLocationProvider(.success(StubLocationProvider.saoPaulo)))

        await sut.load()
        await sut.load()

        #expect(service.requestedCoordinates.count == 2)
        #expect(sut.state == .loaded(.fixture, .device))
    }
}

@Suite("UITestScenario")
struct UITestScenarioTests {

    @Test(arguments: [
        (["-ui-testing"], UITestScenario.success),
        (["-ui-testing", "-scenario", "success"], .success),
        (["-ui-testing", "-scenario", "loading"], .loading),
        (["-ui-testing", "-scenario", "locationDenied"], .locationDenied),
        (["-ui-testing", "-scenario", "offline"], .failure(.offline)),
        (["-ui-testing", "-scenario", "serviceUnavailable"], .failure(.serviceUnavailable)),
        (["-ui-testing", "-scenario", "invalidData"], .failure(.invalidData)),
        (["-ui-testing", "-scenario"], .success)
    ])
    func parsesLaunchArguments(arguments: [String], expected: UITestScenario) {
        #expect(UITestScenario(arguments: arguments) == expected)
    }
}
