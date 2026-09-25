//
//  Mocks.swift
//  RainStorm
//
//  Dependências falsas para testes e previews. Ficam no target do app (em DEBUG)
//  para que os UI tests possam ativá-las via launch arguments.
//

#if DEBUG
import CoreLocation
import Foundation

/// Cenário escolhido por `-ui-testing -scenario <nome>`.
enum UITestScenario: Equatable {
    case success
    case loading
    case locationDenied
    case failure(WeatherDataError)

    init(arguments: [String]) {
        let name = arguments.firstIndex(of: "-scenario").flatMap { index in
            arguments.indices.contains(index + 1) ? arguments[index + 1] : nil
        }
        switch name {
        case "loading": self = .loading
        case "locationDenied": self = .locationDenied
        case "offline": self = .failure(.offline)
        case "serviceUnavailable": self = .failure(.serviceUnavailable)
        case "invalidData": self = .failure(.invalidData)
        default: self = .success
        }
    }
}

final class MockWeatherService: WeatherServicing {

    private(set) var requestedCoordinates: [CLLocationCoordinate2D] = []
    private let result: Result<WeatherSnapshot, WeatherDataError>?

    /// `result == nil` simula uma requisição que nunca termina (estado de loading).
    init(result: Result<WeatherSnapshot, WeatherDataError>?) {
        self.result = result
    }

    convenience init(scenario: UITestScenario) {
        switch scenario {
        case .success, .locationDenied: self.init(result: .success(.fixture))
        case .loading: self.init(result: nil)
        case .failure(let error): self.init(result: .failure(error))
        }
    }

    func forecast(for coordinate: CLLocationCoordinate2D) async throws(WeatherDataError) -> WeatherSnapshot {
        requestedCoordinates.append(coordinate)
        guard let result else {
            // Esperas curtas em laço: `Task.sleep(nanoseconds: .max)` estoura o prazo e
            // retorna na hora no iOS 18 (o "loading" virava erro no UI test).
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 60 * 1_000_000_000)
            }
            throw .serviceUnavailable
        }
        return try result.get()
    }
}

/// Registra as chamadas em vez de escrever no App Group (testes, previews e UI tests).
final class MockWidgetSync: WidgetSyncing {

    private(set) var fetches: [(snapshot: WeatherSnapshot, deviceCoordinate: CLLocationCoordinate2D?)] = []

    func didFetch(_ snapshot: WeatherSnapshot, deviceCoordinate: CLLocationCoordinate2D?) {
        fetches.append((snapshot, deviceCoordinate))
    }
}

final class StubLocationProvider: LocationProviding {

    static let saoPaulo = CLLocation(latitude: -23.5505, longitude: -46.6333)
    static let rioDeJaneiro = CLLocation(latitude: -22.9068, longitude: -43.1729)

    private let result: Result<CLLocation, LocationError>

    init(_ result: Result<CLLocation, LocationError>) {
        self.result = result
    }

    convenience init(scenario: UITestScenario) {
        self.init(scenario == .locationDenied ? .failure(.notAuthorized) : .success(Self.rioDeJaneiro))
    }

    func currentLocation() async throws(LocationError) -> CLLocation {
        try result.get()
    }
}
#endif
