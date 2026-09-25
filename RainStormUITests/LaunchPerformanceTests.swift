//
//  LaunchPerformanceTests.swift
//  RainStormUITests
//
//  Lento (várias aberturas): roda só no Nightly.xctestplan.
//

import MachO
import XCTest

final class LaunchPerformanceTests: XCTestCase {

    @MainActor
    func testLaunchPerformance() throws {
        // Sanitizers distorcem o tempo de abertura (e o TSan derruba as aberturas repetidas
        // do XCTApplicationLaunchMetric): medir só no build sem instrumentação.
        if Self.isRunningUnderSanitizer {
            throw XCTSkip("Medição de performance não é confiável com sanitizer ativo")
        }

        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-scenario", "success"]

        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }

    /// O runtime do sanitizer é linkado ao runner (não vem por DYLD_INSERT_LIBRARIES):
    /// procura a biblioteca entre as imagens carregadas.
    private static var isRunningUnderSanitizer: Bool {
        (0..<_dyld_image_count()).contains { index in
            guard let name = _dyld_get_image_name(index) else { return false }
            let path = String(cString: name)
            return path.contains("libclang_rt.tsan") || path.contains("libclang_rt.asan")
        }
    }
}
