//
//  RainStormApp.swift
//  RainStorm
//
//  Substitui AppDelegate + SceneDelegate + Main.storyboard.
//

import SwiftUI

@main
struct RainStormApp: App {

    var body: some Scene {
        WindowGroup {
            WeatherScreen(viewModel: AppDependencies.makeViewModel(arguments: ProcessInfo.processInfo.arguments))
                .tint(.rainstorm)
        }
    }
}

enum AppDependencies {

    static func makeViewModel(arguments: [String]) -> WeatherViewModel {
        #if DEBUG
        if arguments.contains("-ui-testing") {
            let scenario = UITestScenario(arguments: arguments)
            let location: any LocationProviding = arguments.contains("-real-location")
                ? LocationProvider()
                : StubLocationProvider(scenario: scenario)
            return WeatherViewModel(service: MockWeatherService(scenario: scenario), location: location,
                                    widgetSync: MockWidgetSync())
        }
        // Unit tests rodam hospedados no app: não pedir localização nem acessar a rede.
        if NSClassFromString("XCTestCase") != nil {
            return WeatherViewModel(service: MockWeatherService(scenario: .loading),
                                    location: StubLocationProvider(scenario: .loading),
                                    widgetSync: MockWidgetSync())
        }
        #endif
        return WeatherViewModel(service: OpenMeteoWeatherService(), location: LocationProvider(),
                                widgetSync: WidgetCenterSync())
    }
}
