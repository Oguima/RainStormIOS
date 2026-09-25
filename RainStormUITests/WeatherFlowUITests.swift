//
//  WeatherFlowUITests.swift
//  RainStormUITests
//

import XCTest

final class WeatherFlowUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testShowsCurrentWeatherAndForecastOnLaunch() {
        let page = WeatherScreenPage(app: .launch(.success))

        XCTAssertTrue(page.current.waitForExistence(timeout: 5))
        XCTAssertTrue(page.chart.exists)
        XCTAssertFalse(page.fallbackBanner.exists)

        page.app.swipeUp()
        XCTAssertTrue(page.forecastRows.firstMatch.waitForExistence(timeout: 2))
    }

    @MainActor
    func testShowsLoadingWhileFetching() {
        let page = WeatherScreenPage(app: .launch(.loading))

        XCTAssertTrue(page.loading.waitForExistence(timeout: 5))
        XCTAssertFalse(page.current.exists)
    }

    @MainActor
    func testShowsFallbackBannerWhenLocationIsDenied() {
        let page = WeatherScreenPage(app: .launch(.locationDenied))

        XCTAssertTrue(page.fallbackBanner.waitForExistence(timeout: 5))
        XCTAssertTrue(page.current.exists)
    }

    @MainActor
    func testShowsErrorAndRetryWhenOffline() {
        let page = WeatherScreenPage(app: .launch(.offline))

        XCTAssertTrue(page.retryButton.waitForExistence(timeout: 5))
        page.retryButton.tap()

        // O cenário continua offline: depois de tentar de novo, o erro volta.
        XCTAssertTrue(page.retryButton.waitForExistence(timeout: 5))
        XCTAssertFalse(page.current.exists)
    }

    @MainActor
    func testPullToRefreshKeepsContent() {
        let page = WeatherScreenPage(app: .launch(.success))
        XCTAssertTrue(page.current.waitForExistence(timeout: 5))

        let start = page.current.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
        start.press(forDuration: 0.1, thenDragTo: start.withOffset(CGVector(dx: 0, dy: 400)))

        XCTAssertTrue(page.current.waitForExistence(timeout: 5))
    }

    @MainActor
    func testAccessibilityAudit() throws {
        guard #available(iOS 17, *) else {
            throw XCTSkip("performAccessibilityAudit exige runtime iOS 17+")
        }
        // A auditoria reporta cada issue como falha: continuar para listar todas de uma vez.
        continueAfterFailure = true
        let page = WeatherScreenPage(app: .launch(.success))
        XCTAssertTrue(page.current.waitForExistence(timeout: 5))

        try page.app.performAccessibilityAudit { issue in
            // Falso positivo conhecido: cabeçalhos de seção da List (views suplementares) são
            // reportados como sem Dynamic Type mesmo usando fonte de estilo. O snapshot
            // `loadedWithLargestAccessibilityTextSize` comprova que eles escalam.
            // Retornar true = ignorar a issue; todas as outras continuam falhando o teste.
            issue.auditType == .dynamicType && issue.element?.identifier == "weather.sectionHeader"
        }
    }
}
