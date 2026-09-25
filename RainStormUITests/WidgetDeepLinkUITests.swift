//
//  WidgetDeepLinkUITests.swift
//  RainStormUITests
//
//  O toque no widget abre `rainstorm://weather`. Adicionar o widget na tela inicial via
//  SpringBoard é instável no XCUITest, então o teste abre a mesma URL direto.
//

import XCTest

final class WidgetDeepLinkUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testWidgetURLBringsTheAppBackWithTheCurrentWeather() throws {
        guard #available(iOS 16.4, *) else {
            throw XCTSkip("XCUISystem.open(_:) exige iOS 16.4+")
        }
        let page = WeatherScreenPage(app: .launch(.success))
        XCTAssertTrue(page.current.waitForExistence(timeout: 5))

        XCUIDevice.shared.press(.home)
        XCTAssertTrue(page.app.wait(for: .runningBackgroundSuspended, timeout: 5)
                      || page.app.wait(for: .runningBackground, timeout: 1))

        // `system.open` roteia pelo esquema registrado, como o SpringBoard no toque do widget.
        // (`app.open` entrega a URL direto ao app e passaria mesmo sem CFBundleURLTypes.)
        XCUIDevice.shared.system.open(URL(string: "rainstorm://weather")!)

        XCTAssertTrue(page.app.wait(for: .runningForeground, timeout: 10))
        XCTAssertTrue(page.current.waitForExistence(timeout: 5))
    }
}
