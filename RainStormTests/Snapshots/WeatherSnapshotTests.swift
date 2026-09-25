//
//  WeatherSnapshotTests.swift
//  RainStormTests
//
//  Referências gravadas no iPhone 17 / iOS 26.5 (em __Snapshots__/).
//  Para regravar de propósito: troque `.missing` por `.all`, rode, e volte para `.missing`.
//

import SnapshotTesting
import SwiftUI
import Testing
@testable import RainStorm

@Suite("Snapshots", .tags(.snapshot), .snapshots(record: .missing))
struct WeatherSnapshotTests {

    /// Mesmo "chrome" do app (navegação, cor da marca e pt-BR fixos) + comparação da imagem.
    /// Repassa a origem da chamada para o nome do snapshot vir do teste que chamou.
    private func verify(
        _ content: some View,
        device: ViewImageConfig = .iPhone8,
        traits: UITraitCollection = .init(),
        named name: String? = nil,
        fileID: StaticString = #fileID,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        let view = NavigationStack {
            content.navigationTitle("RainStorm")
        }
        .tint(.rainstorm)
        .environment(\.locale, .ptBR)

        assertSnapshot(of: view,
                       as: .image(perceptualPrecision: 0.98, layout: .device(config: device), traits: traits),
                       named: name,
                       fileID: fileID, file: file, testName: testName, line: line, column: column)
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func loaded(style: UIUserInterfaceStyle) {
        verify(WeatherContentView(snapshot: .fixture, source: .device),
               traits: UITraitCollection(userInterfaceStyle: style),
               named: style == .dark ? "dark" : "light")
    }

    @Test func loadedOnLargerScreen() {
        verify(WeatherContentView(snapshot: .fixture, source: .device), device: .iPhone13Pro)
    }

    @Test func fallbackLocationBanner() {
        verify(WeatherContentView(snapshot: .fixture, source: .fallback))
    }

    @Test(arguments: [WeatherDataError.offline, .serviceUnavailable, .invalidData])
    func error(error: WeatherDataError) {
        verify(EmptyStateView(error: error) {}, named: "\(error)")
    }

    /// Tela inteira (altura estendida) no maior tamanho de acessibilidade: cabeçalhos e textos escalam.
    @Test func loadedWithLargestAccessibilityTextSize() {
        let tall = ViewImageConfig(safeArea: ViewImageConfig.iPhone8.safeArea,
                                   size: CGSize(width: 375, height: 2600),
                                   traits: ViewImageConfig.iPhone8.traits)
        verify(WeatherContentView(snapshot: .fixture, source: .device),
               device: tall,
               traits: UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge))
    }

    @Test func forecastWithLargestAccessibilityTextSize() {
        let rows = List(WeatherSnapshot.fixture.forecast) { day in
            ForecastRow(day: day, timeZone: WeatherSnapshot.fixture.timeZone)
        }
        verify(rows, traits: UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge))
    }
}
