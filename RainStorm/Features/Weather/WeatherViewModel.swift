//
//  WeatherViewModel.swift
//  RainStorm
//
//  Substitui RootViewModel + DayViewModel + WeekViewModel + WeekDayViewModel.
//  iOS 16: ObservableObject + @Published (o @Observable exige iOS 17).
//

import Combine
import CoreLocation
import Foundation

final class WeatherViewModel: ObservableObject {

    enum LocationSource: Equatable {
        /// Localização atual do aparelho.
        case device
        /// Permissão negada ou localização indisponível: usa `Defaults.location`.
        case fallback
    }

    enum State: Equatable {
        case loading
        case loaded(WeatherSnapshot, LocationSource)
        case failed(WeatherDataError)
    }

    @Published private(set) var state: State

    private let service: any WeatherServicing
    private let location: any LocationProviding
    private let widgetSync: any WidgetSyncing

    init(service: any WeatherServicing,
         location: any LocationProviding,
         widgetSync: any WidgetSyncing,
         initialState: State = .loading) {
        self.service = service
        self.location = location
        self.widgetSync = widgetSync
        self.state = initialState
    }

    func load() async {
        // No pull-to-refresh o conteúdo atual continua visível até chegar o novo.
        if case .loaded = state {} else { state = .loading }

        let coordinate: CLLocationCoordinate2D
        let source: LocationSource
        do {
            coordinate = try await location.currentLocation().coordinate
            source = .device
        } catch {
            coordinate = Defaults.location.coordinate
            source = .fallback
        }

        do {
            let snapshot = try await service.forecast(for: coordinate)
            state = .loaded(snapshot, source)
            // O widget reaproveita o resultado; só uma posição real vira a coordenada dele.
            widgetSync.didFetch(snapshot, deviceCoordinate: source == .device ? coordinate : nil)
        } catch {
            state = .failed(error)
        }
    }
}
