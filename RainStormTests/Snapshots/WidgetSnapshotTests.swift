//
//  WidgetSnapshotTests.swift
//  RainStormTests
//
//  As mesmas views que a extensão desenha (Shared/WidgetUI), nos tamanhos típicos do iPhone.
//  Fora do WidgetKit o `containerBackground` não desenha nada: o harness faz o papel do
//  container (fundo + margem de 16 pt nas famílias da tela inicial).
//  Referências gravadas no iPhone 17 / iOS 26.5, como os snapshots do app.
//

import SnapshotTesting
import SwiftUI
import Testing
import UIKit
import WidgetKit
@testable import RainStorm

@Suite("Widget snapshots", .tags(.snapshot, .widget), .snapshots(record: .missing))
struct WidgetSnapshotTests {

    nonisolated static let families: [WidgetFamily] = [.systemSmall, .systemMedium,
                                                       .accessoryCircular, .accessoryRectangular, .accessoryInline]
    nonisolated static let styles: [UIUserInterfaceStyle] = [.light, .dark]

    private static func size(of family: WidgetFamily) -> CGSize {
        switch family {
        case .systemMedium: CGSize(width: 364, height: 170)
        case .accessoryCircular: CGSize(width: 72, height: 72)
        case .accessoryRectangular: CGSize(width: 172, height: 76)
        case .accessoryInline: CGSize(width: 250, height: 26)
        default: CGSize(width: 170, height: 170)
        }
    }

    private func verify(
        _ entry: WeatherWidgetEntry,
        family: WidgetFamily,
        traits: UITraitCollection = .init(),
        named name: String,
        fileID: StaticString = #fileID,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        let size = Self.size(of: family)
        let view = CurrentWeatherWidgetView(entry: entry, family: family)
            .padding(family.isAccessory ? 0 : 16)
            .frame(width: size.width, height: size.height)
            .background(Color(uiColor: .systemBackground))
            .environment(\.locale, .ptBR)

        assertSnapshot(of: view,
                       as: .image(perceptualPrecision: 0.98,
                                  layout: .fixed(width: size.width, height: size.height),
                                  traits: traits),
                       named: name,
                       fileID: fileID, file: file, testName: testName, line: line, column: column)
    }

    /// Duas horas depois da última busca, sem rede: dados do cache com "Atualizado às 19:45".
    private static let staleEntry = WeatherTimelineBuilder.build(
        for: .sample,
        now: WeatherSnapshot.sample.current.date.addingTimeInterval(2 * 60 * 60),
        staleSince: WeatherSnapshot.sample.current.date,
        policy: .standard
    ).entries[0]

    @Test(arguments: families, styles)
    func fresh(family: WidgetFamily, style: UIUserInterfaceStyle) {
        verify(.sample(), family: family,
               traits: UITraitCollection(userInterfaceStyle: style),
               named: "\(family)-\(style == .dark ? "dark" : "light")")
    }

    @Test(arguments: families)
    func stale(family: WidgetFamily) {
        verify(Self.staleEntry, family: family, named: "\(family)")
    }

    @Test(arguments: families)
    func unavailable(family: WidgetFamily) {
        verify(WeatherWidgetEntry(date: WeatherSnapshot.sample.current.date, content: .unavailable), family: family, named: "\(family)")
    }

    @Test func mediumWithLargestAccessibilityTextSize() {
        verify(.sample(), family: .systemMedium,
               traits: UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge),
               named: "systemMedium")
    }
}
