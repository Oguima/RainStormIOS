//
//  WeatherSnapshot+Fixture.swift
//  RainStorm
//
//  Dados fixos compartilhados por #Preview, snapshot tests, unit tests e UI tests.
//  Só existe em DEBUG: nunca vai para a App Store.
//

#if DEBUG
import Foundation

extension WeatherSnapshot {

    /// Mesmos dados do `sample` (Shared), que o widget usa em Release.
    static var fixture: WeatherSnapshot { sample }
}

extension WeatherViewModel {

    /// ViewModel já no estado desejado, para #Preview e snapshots.
    static func preview(_ state: State) -> WeatherViewModel {
        let scenario: UITestScenario = switch state {
        case .loading: .loading
        case .loaded(_, .device): .success
        case .loaded(_, .fallback): .locationDenied
        case .failed(let error): .failure(error)
        }
        return WeatherViewModel(service: MockWeatherService(scenario: scenario),
                                location: StubLocationProvider(scenario: scenario),
                                widgetSync: MockWidgetSync(),
                                initialState: state)
    }
}
#endif
