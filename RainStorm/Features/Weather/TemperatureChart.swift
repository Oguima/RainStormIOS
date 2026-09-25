//
//  TemperatureChart.swift
//  RainStorm
//
//  Swift Charts (iOS 16): faixa de mínima/máxima por dia.
//

import Accessibility
import Charts
import SwiftUI

struct TemperatureChart: View {

    let days: [WeatherSnapshot.Day]
    let timeZone: TimeZone

    @Environment(\.locale) private var locale

    var body: some View {
        Chart(days) { day in
            BarMark(
                x: .value("Day", WeatherFormatter.shortWeekday(day.date, locale: locale, timeZone: timeZone)),
                yStart: .value("Min", day.temperatureMin),
                yEnd: .value("Max", day.temperatureMax),
                width: .fixed(14)
            )
            .foregroundStyle(Color.rainstorm.gradient)
            .clipShape(Capsule())
            .annotation(position: .top) { degrees(day.temperatureMax) }
            .annotation(position: .bottom) { degrees(day.temperatureMin) }
        }
        .chartYAxis(.hidden)
        // Gráfico denso: acima de xxLarge os rótulos se sobrepõem. Os mesmos valores aparecem
        // em texto grande na lista "Próximos dias", logo abaixo.
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .frame(height: 180)
        .padding(.vertical, 8)
        // Um elemento só (os rótulos desenhados no gráfico não existem na árvore de acessibilidade)
        // + chart descriptor: o VoiceOver oferece o Audio Graph para percorrer os dias.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Temperature this week"))
        .accessibilityValue(Text(summary))
        .accessibilityChartDescriptor(self)
        .accessibilityIdentifier("weather.chart")
    }

    private var summary: String {
        Self.summary(of: days, locale: locale)
    }

    /// "Mínima de 12,8 °C, máxima de 34,3 °C"
    static func summary(of days: [WeatherSnapshot.Day], locale: Locale) -> String {
        let minimum = days.map(\.temperatureMin).min() ?? 0
        let maximum = days.map(\.temperatureMax).max() ?? 0
        // LocalizedStringResource.locale escolhe o idioma; String(localized:locale:) só formata.
        var resource: LocalizedStringResource = "Minimum \(WeatherFormatter.temperature(minimum, locale: locale)), maximum \(WeatherFormatter.temperature(maximum, locale: locale))"
        resource.locale = locale
        return String(localized: resource)
    }

    /// Rótulo compacto ("21°") acima/abaixo de cada barra.
    private func degrees(_ value: Double) -> some View {
        let number = value.formatted(.number.precision(.fractionLength(0)).locale(locale))
        return Text(verbatim: "\(number)°")
            .font(.caption2)
            .foregroundStyle(Color.secondaryText)
    }
}

extension TemperatureChart: AXChartDescriptorRepresentable {

    func makeChartDescriptor() -> AXChartDescriptor {
        Self.chartDescriptor(for: days, locale: locale, timeZone: timeZone)
    }

    /// Estático e com locale explícito para poder ser testado fora da hierarquia de views.
    static func chartDescriptor(for days: [WeatherSnapshot.Day], locale: Locale, timeZone: TimeZone) -> AXChartDescriptor {
        let weekdays = days.map { WeatherFormatter.weekday($0.date, locale: locale, timeZone: timeZone) }
        let minimum = days.map(\.temperatureMin).min() ?? 0
        let maximum = days.map(\.temperatureMax).max() ?? 0

        let xAxis = AXCategoricalDataAxisDescriptor(title: String(localized: "Day"), categoryOrder: weekdays)
        let yAxis = AXNumericDataAxisDescriptor(title: String(localized: "Max"),
                                                range: minimum...max(maximum, minimum + 1),
                                                gridlinePositions: []) { WeatherFormatter.temperature($0, locale: locale) }

        let points = zip(days, weekdays).map { day, weekday in
            AXDataPoint(x: weekday,
                        y: day.temperatureMax,
                        additionalValues: [.number(day.temperatureMin)],
                        label: WeatherFormatter.temperatureRange(min: day.temperatureMin,
                                                                 max: day.temperatureMax,
                                                                 locale: locale))
        }

        return AXChartDescriptor(title: String(localized: "Temperature this week"),
                                 summary: summary(of: days, locale: locale),
                                 xAxis: xAxis,
                                 yAxis: yAxis,
                                 additionalAxes: [],
                                 series: [AXDataSeriesDescriptor(name: String(localized: "Temperature this week"),
                                                                 isContinuous: false,
                                                                 dataPoints: points)])
    }
}

#if DEBUG
#Preview {
    List {
        TemperatureChart(days: WeatherSnapshot.fixture.forecast, timeZone: WeatherSnapshot.fixture.timeZone)
    }
}
#endif
