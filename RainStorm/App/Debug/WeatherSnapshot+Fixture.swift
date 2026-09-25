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

    static let fixture: WeatherSnapshot = {
        let timeZone = TimeZone(identifier: "America/Sao_Paulo")!
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let start = calendar.date(from: DateComponents(year: 2026, month: 9, day: 24))!

        let days: [(min: Double, max: Double, wind: Double, code: Int)] = [
            (12.8, 21.1, 14.0, 3),
            (15.1, 26.2, 11.2, 2),
            (16.8, 30.2, 9.7, 0),
            (18.1, 30.6, 12.5, 1),
            (17.5, 33.6, 16.1, 80),
            (19.2, 34.3, 21.4, 95),
            (19.2, 32.7, 18.0, 61)
        ]

        return WeatherSnapshot(
            timeZone: timeZone,
            current: Current(date: calendar.date(byAdding: .minute, value: 19 * 60 + 45, to: start)!,
                             temperature: 15.9,
                             windSpeed: 6.5,
                             weatherCode: 3,
                             isDay: false),
            forecast: days.enumerated().map { offset, day in
                Day(date: calendar.date(byAdding: .day, value: offset, to: start)!,
                    temperatureMin: day.min,
                    temperatureMax: day.max,
                    windSpeedMax: day.wind,
                    weatherCode: day.code)
            }
        )
    }()
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
                                initialState: state)
    }
}
#endif
