//
//  LocationPermissionUITests.swift
//  RainStormUITests
//
//  Único fluxo que usa o LocationProvider real (-real-location). O clima continua mockado.
//

import CoreLocation
import XCTest

final class LocationPermissionUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testAllowingLocationShowsForecastWithoutFallbackBanner() throws {
        let page = try launchResettingPermission()

        tapPermissionButton(matching: ["While Using", "Durante o Uso"])

        XCTAssertTrue(page.current.waitForExistence(timeout: 10))
        XCTAssertFalse(page.fallbackBanner.exists)
    }

    @MainActor
    func testDenyingLocationShowsFallbackBanner() throws {
        let page = try launchResettingPermission()

        tapPermissionButton(matching: ["Don", "Não Permitir"])

        XCTAssertTrue(page.fallbackBanner.waitForExistence(timeout: 10))
    }

    // MARK: Helpers

    @MainActor
    private func launchResettingPermission() throws -> WeatherScreenPage {
        let app = XCUIApplication()
        app.resetAuthorizationStatus(for: .location)
        // Posição simulada (São Paulo) sem precisar de arquivo GPX.
        guard #available(iOS 16.4, *) else {
            throw XCTSkip("Simulação de localização exige runtime iOS 16.4+")
        }
        XCUIDevice.shared.location = XCUILocation(location: CLLocation(latitude: -23.5505, longitude: -46.6333))
        app.launchArguments = ["-ui-testing", "-scenario", "success", "-real-location"]
        app.launch()
        return WeatherScreenPage(app: app)
    }

    /// O alerta de permissão pertence ao SpringBoard, não ao app.
    @MainActor
    private func tapPermissionButton(matching labels: [String]) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let alert = springboard.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 10), "Alerta de permissão de localização não apareceu")

        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: labels.map {
            NSPredicate(format: "label CONTAINS[c] %@", $0)
        })
        let button = alert.buttons.matching(predicate).firstMatch
        XCTAssertTrue(button.exists, "Botão \(labels) não encontrado em: \(alert.buttons.allElementsBoundByIndex.map(\.label))")
        button.tap()
    }
}
