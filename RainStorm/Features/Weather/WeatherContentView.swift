//
//  WeatherContentView.swift
//  RainStorm
//

import SwiftUI

struct WeatherContentView: View {

    let snapshot: WeatherSnapshot
    let source: WeatherViewModel.LocationSource

    var body: some View {
        List {
            if source == .fallback {
                Section {
                    FallbackLocationBanner()
                }
            }

            Section {
                CurrentWeatherView(current: snapshot.current, timeZone: snapshot.timeZone)
            }

            Section {
                TemperatureChart(days: snapshot.forecast, timeZone: snapshot.timeZone)
            } header: {
                SectionHeader("Temperature this week")
            }

            Section {
                ForEach(snapshot.forecast) { day in
                    ForecastRow(day: day, timeZone: snapshot.timeZone)
                }
            } header: {
                SectionHeader("Next days")
            }
        }
        .listStyle(.insetGrouped)
    }
}

/// Cabeçalho de seção com fonte de Dynamic Type e trait de header (navegação por títulos no VoiceOver).
/// O identificador permite ao UI test tratar um falso positivo do performAccessibilityAudit
/// em cabeçalhos de List; o snapshot `loadedWithLargestAccessibilityTextSize` prova que ele escala.
private struct SectionHeader: View {
    let title: LocalizedStringKey

    init(_ title: LocalizedStringKey) {
        self.title = title
    }

    var body: some View {
        // Cor primária: `.secondary` sobre o fundo agrupado reprova no audit de contraste.
        Text(title)
            .font(.headline)
            .foregroundStyle(.primary)
            .textCase(nil)
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier("weather.sectionHeader")
    }
}

struct FallbackLocationBanner: View {

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Showing the forecast for \(Defaults.locationName)", systemImage: "location.slash")
                .font(.subheadline.weight(.semibold))
            Text("Allow location access in Settings to see the weather where you are.")
                .font(.footnote)
                .foregroundStyle(Color.secondaryText)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            .font(.footnote.weight(.semibold))
        }
        .padding(.vertical, 4)
        // `.contain`: o identificador fica no container sem sobrescrever o dos filhos (botão).
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("weather.fallbackBanner")
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        WeatherContentView(snapshot: .fixture, source: .fallback)
            .navigationTitle("RainStorm")
    }
    .tint(.rainstorm)
}
#endif
