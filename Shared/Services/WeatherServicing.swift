//
//  WeatherServicing.swift
//  RainStorm
//

import CoreLocation
import Foundation

extension URLSession {
    /// Timeout curto para o widget: com o padrão de 60 s, uma rede ruim pode estourar o tempo
    /// da extensão antes do fallback para o cache.
    nonisolated static let widget: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 20
        return URLSession(configuration: configuration)
    }()
}

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
