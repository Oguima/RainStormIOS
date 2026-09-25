//
//  WeatherServicing.swift
//  RainStorm
//

import CoreLocation
import Foundation

protocol WeatherServicing {
    func forecast(for coordinate: CLLocationCoordinate2D) async throws(WeatherDataError) -> WeatherSnapshot
}

struct OpenMeteoWeatherService: WeatherServicing {

    var session: URLSession = .shared
    var baseUrl: URL = WeatherService.baseUrl

    func forecast(for coordinate: CLLocationCoordinate2D) async throws(WeatherDataError) -> WeatherSnapshot {
        let request = WeatherRequest(baseUrl: baseUrl, coordinate: coordinate)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: request.url)
        } catch let error as URLError {
            throw WeatherDataError(error)
        } catch {
            throw .serviceUnavailable
        }

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw .serviceUnavailable
        }

        do {
            return try JSONDecoder().decode(OpenMeteoResponse.self, from: data).snapshot
        } catch {
            throw .invalidData
        }
    }
}
