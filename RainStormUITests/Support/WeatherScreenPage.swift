//
//  WeatherScreenPage.swift
//  RainStormUITests
//
//  Page Object: os testes falam em "temperatura atual" e "botão de tentar de novo",
//  não em queries do XCUITest. Tudo por accessibilityIdentifier (independe do idioma).
//

import XCTest

@MainActor
struct WeatherScreenPage {

    let app: XCUIApplication

    var loading: XCUIElement { element("weather.loading") }
    var current: XCUIElement { element("weather.current") }
    var chart: XCUIElement { element("weather.chart") }
    var fallbackBanner: XCUIElement { element("weather.fallbackBanner") }
    var errorView: XCUIElement { element("weather.error") }
    var retryButton: XCUIElement { app.buttons["weather.error.retry"] }
    var forecastRows: XCUIElementQuery {
        app.descendants(matching: .any).matching(identifier: "weather.forecast.row")
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier].firstMatch
    }
}

enum Scenario: String {
    case success, loading, locationDenied, offline, serviceUnavailable, invalidData
}

extension XCUIApplication {

    /// Abre o app com dependências mockadas (nenhum acesso à rede real).
    @MainActor
    static func launch(_ scenario: Scenario, extraArguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-scenario", scenario.rawValue] + extraArguments
        app.launch()
        return app
    }
}
