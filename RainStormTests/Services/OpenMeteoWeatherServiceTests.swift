//
//  OpenMeteoWeatherServiceTests.swift
//  RainStormTests
//

import CoreLocation
import Foundation
import Testing
@testable import RainStorm

@Suite("OpenMeteoWeatherService", .tags(.networking), .serialized)
struct OpenMeteoWeatherServiceTests {

    private let coordinate = CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333)

    @Test func buildsRequestWithExpectedQuery() async throws {
        let session = URLProtocolStub.session(returning: Fixture.data("forecast_success"), status: 200)
        _ = try await OpenMeteoWeatherService(session: session).forecast(for: coordinate)

        let url = try #require(URLProtocolStub.lastRequest?.url)
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []

        #expect(url.host == "api.open-meteo.com")
        #expect(url.path == "/v1/forecast")
        #expect(items.contains(URLQueryItem(name: "latitude", value: "-23.5505")))
        #expect(items.contains(URLQueryItem(name: "longitude", value: "-46.6333")))
        #expect(items.contains(URLQueryItem(name: "current_weather", value: "true")))
        #expect(items.contains(URLQueryItem(name: "timezone", value: "auto")))
        #expect(items.contains(URLQueryItem(name: "daily",
                                            value: "temperature_2m_max,temperature_2m_min,weathercode,windspeed_10m_max")))
        // Previsão horária para a timeline do widget (a resposta começa na hora atual).
        #expect(items.contains(URLQueryItem(name: "hourly", value: "temperature_2m,weathercode,windspeed_10m,is_day")))
        #expect(items.contains(URLQueryItem(name: "forecast_hours", value: "12")))
    }

    @Test func decodesSuccessfulResponse() async throws {
        let session = URLProtocolStub.session(returning: Fixture.data("forecast_success"), status: 200)
        let snapshot = try await OpenMeteoWeatherService(session: session).forecast(for: coordinate)

        #expect(snapshot.forecast.count == 7)
        #expect(snapshot.current.temperature == 15.9)
    }

    @Test(arguments: [400, 404, 429, 500, 503])
    func nonSuccessStatusMapsToServiceUnavailable(status: Int) async {
        let session = URLProtocolStub.session(returning: Fixture.data("forecast_success"), status: status)
        await #expect(throws: WeatherDataError.serviceUnavailable) {
            try await OpenMeteoWeatherService(session: session).forecast(for: coordinate)
        }
    }

    @Test func invalidPayloadMapsToInvalidData() async {
        let session = URLProtocolStub.session(returning: Data("{\"unexpected\":true}".utf8), status: 200)
        await #expect(throws: WeatherDataError.invalidData) {
            try await OpenMeteoWeatherService(session: session).forecast(for: coordinate)
        }
    }

    @Test func inconsistentPayloadMapsToInvalidData() async {
        let session = URLProtocolStub.session(returning: Fixture.data("forecast_mismatched_arrays"), status: 200)
        await #expect(throws: WeatherDataError.invalidData) {
            try await OpenMeteoWeatherService(session: session).forecast(for: coordinate)
        }
    }

    @Test(arguments: [URLError.Code.notConnectedToInternet, .timedOut, .networkConnectionLost])
    func connectivityErrorsMapToOffline(code: URLError.Code) async {
        let session = URLProtocolStub.session(failingWith: code)
        await #expect(throws: WeatherDataError.offline) {
            try await OpenMeteoWeatherService(session: session).forecast(for: coordinate)
        }
    }

    @Test func otherNetworkErrorsMapToServiceUnavailable() async {
        let session = URLProtocolStub.session(failingWith: .badServerResponse)
        await #expect(throws: WeatherDataError.serviceUnavailable) {
            try await OpenMeteoWeatherService(session: session).forecast(for: coordinate)
        }
    }
}
