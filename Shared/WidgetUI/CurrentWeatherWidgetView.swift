//
//  CurrentWeatherWidgetView.swift
//  RainStorm
//
//  Raiz do widget: escolhe a view da família. Fica em Shared para os snapshot tests
//  do app renderizarem exatamente o que a extensão mostra.
//

import SwiftUI
import WidgetKit

struct CurrentWeatherWidgetView: View {

    let entry: WeatherWidgetEntry
    let family: WidgetFamily

    var body: some View {
        content
            .tint(.rainstorm)
            .widgetURL(DeepLink.weather)
            .widgetBackground(for: family)
    }

    @ViewBuilder
    private var content: some View {
        switch entry.content {
        case .weather(let weather):
            switch family {
            case .systemMedium: MediumWeatherWidgetView(content: weather)
            case .accessoryCircular: CircularWeatherWidgetView(content: weather)
            case .accessoryRectangular: RectangularWeatherWidgetView(content: weather)
            case .accessoryInline: InlineWeatherWidgetView(content: weather)
            default: SmallWeatherWidgetView(content: weather)
            }
        case .unavailable:
            UnavailableWeatherWidgetView(family: family)
        }
    }
}

/// Textos formatados uma vez, no locale do ambiente (mesmos formatadores do card do app).
struct WidgetWeatherText {

    let content: WeatherWidgetContent
    let locale: Locale

    var condition: WeatherSnapshot.Current { content.condition }
    var temperature: String { WeatherFormatter.temperature(condition.temperature, locale: locale) }
    var compactTemperature: String { WeatherFormatter.compactTemperature(condition.temperature, locale: locale) }
    var wind: String { WeatherFormatter.windSpeed(condition.windSpeed, locale: locale) }
    var date: String { WeatherFormatter.fullDate(condition.date, locale: locale, timeZone: content.timeZone) }
    var time: String { WeatherFormatter.time(condition.date, locale: locale, timeZone: content.timeZone) }

    var range: String? {
        guard let min = content.temperatureMin, let max = content.temperatureMax else { return nil }
        return WeatherFormatter.temperatureRange(min: min, max: max, locale: locale)
    }

    /// "Atualizado às 19:45" quando os dados vêm do cache.
    var staleNotice: Text? {
        content.staleSince.map { Text("Updated at \(WeatherFormatter.time($0, locale: locale, timeZone: content.timeZone))") }
    }

    /// "Nublado, 15,9 °C, vento 7 km/h": um único elemento para o VoiceOver.
    var accessibilityLabel: Text {
        let separator = Text(verbatim: ", ")
        var label = Text(condition.summary) + separator + Text(verbatim: temperature) + separator + Text("wind \(wind)")
        if let range {
            label = label + separator + Text("today \(range)")
        }
        if let staleNotice {
            label = label + separator + staleNotice
        }
        return label
    }
}

private struct WeatherIcon: View {
    let condition: WeatherSnapshot.Current
    let size: CGFloat

    var body: some View {
        Image(condition.iconName)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(.tint)
            .accessibilityHidden(true)
    }
}

// MARK: - Tela inicial

/// Réplica horizontal do card do app. Em tamanhos de acessibilidade o layout completo não
/// cabe em 170 pt: `ViewThatFits` troca para o compacto (sem data e vento, que continuam no VoiceOver).
struct MediumWeatherWidgetView: View {

    let content: WeatherWidgetContent
    @Environment(\.locale) private var locale

    var body: some View {
        let text = WidgetWeatherText(content: content, locale: locale)
        ViewThatFits(in: .vertical) {
            full(text)
            CompactWeatherLayout(text: text)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text.accessibilityLabel)
    }

    private func full(_ text: WidgetWeatherText) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: text.date)
                    .font(.headline)
                    .foregroundStyle(.tint)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                (text.staleNotice ?? Text(text.time))
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
                    .lineLimit(1)
                Spacer(minLength: 4)
                Text(text.condition.summary)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Label(text.wind, systemImage: "wind")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 2) {
                WeatherIcon(condition: text.condition, size: 52)
                Spacer(minLength: 0)
                Text(text.temperature)
                    .font(.system(.title, design: .rounded).weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                if let range = text.range {
                    Text(range)
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
        }
    }
}

struct SmallWeatherWidgetView: View {

    let content: WeatherWidgetContent
    @Environment(\.locale) private var locale

    var body: some View {
        let text = WidgetWeatherText(content: content, locale: locale)
        ViewThatFits(in: .vertical) {
            full(text)
            CompactWeatherLayout(text: text)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text.accessibilityLabel)
    }

    private func full(_ text: WidgetWeatherText) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            WeatherIcon(condition: text.condition, size: 40)
            Spacer(minLength: 0)
            Text(text.temperature)
                .font(.system(.title, design: .rounded).weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(text.condition.summary)
                .font(.subheadline)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            FooterText(text: text)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

/// Último recurso do `ViewThatFits` (Dynamic Type de acessibilidade): encolhe em vez de cortar.
private struct CompactWeatherLayout: View {
    let text: WidgetWeatherText

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                WeatherIcon(condition: text.condition, size: 28)
                Text(text.temperature)
                    .font(.system(.title2, design: .rounded).weight(.semibold))
            }
            Text(text.condition.summary)
                .font(.subheadline)
            FooterText(text: text)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

/// "Atualizado às 19:45" (cache) ou a faixa do dia.
private struct FooterText: View {
    let text: WidgetWeatherText

    var body: some View {
        Group {
            if let staleNotice = text.staleNotice {
                staleNotice
            } else if let range = text.range {
                Text(range)
            }
        }
        .font(.caption)
        .foregroundStyle(Color.secondaryText)
        .lineLimit(1)
        .minimumScaleFactor(0.6)
    }
}

// MARK: - Tela de bloqueio

/// Mínima → máxima do dia, com a temperatura atual no centro.
struct CircularWeatherWidgetView: View {

    let content: WeatherWidgetContent
    @Environment(\.locale) private var locale

    var body: some View {
        let text = WidgetWeatherText(content: content, locale: locale)
        Group {
            if let min = content.temperatureMin, let max = content.temperatureMax, min < max {
                Gauge(value: Swift.min(Swift.max(text.condition.temperature, min), max), in: min...max) {
                    Image(systemName: WeatherCodeMapper.systemImageName(for: text.condition.weatherCode,
                                                                        isDay: text.condition.isDay))
                } currentValueLabel: {
                    Text(text.compactTemperature)
                }
                .gaugeStyle(.accessoryCircular)
            } else {
                ZStack {
                    AccessoryWidgetBackground()
                    Text(text.compactTemperature)
                        .font(.headline)
                        .minimumScaleFactor(0.6)
                }
            }
        }
        .widgetAccentable()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text.accessibilityLabel)
    }
}

struct RectangularWeatherWidgetView: View {

    let content: WeatherWidgetContent
    @Environment(\.locale) private var locale

    var body: some View {
        let text = WidgetWeatherText(content: content, locale: locale)
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: WeatherCodeMapper.systemImageName(for: text.condition.weatherCode,
                                                                    isDay: text.condition.isDay))
                Text(text.temperature)
            }
            .font(.headline)
            .widgetAccentable()
            Text(text.condition.summary)
                .font(.subheadline)
            (text.staleNotice ?? Text("Wind \(text.wind)"))
                .font(.caption)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text.accessibilityLabel)
    }
}

/// "☁ 15,9 °C · Nublado" (uma linha acima do relógio).
struct InlineWeatherWidgetView: View {

    let content: WeatherWidgetContent
    @Environment(\.locale) private var locale

    var body: some View {
        let text = WidgetWeatherText(content: content, locale: locale)
        Label {
            Text(verbatim: "\(text.temperature) · ") + Text(text.condition.summary)
        } icon: {
            Image(systemName: WeatherCodeMapper.systemImageName(for: text.condition.weatherCode,
                                                                isDay: text.condition.isDay))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text.accessibilityLabel)
    }
}

// MARK: - Sem dados

struct UnavailableWeatherWidgetView: View {

    let family: WidgetFamily

    var body: some View {
        switch family {
        case .accessoryInline:
            Label("RainStorm", systemImage: "cloud")
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "cloud")
                    .font(.title2)
            }
            .accessibilityLabel(Text("Open RainStorm to load the weather"))
        case .accessoryRectangular:
            Text("Open RainStorm to load the weather")
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
        default:
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "cloud")
                    .font(.title)
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
                Spacer(minLength: 0)
                Text("Open RainStorm to load the weather")
                    .font(.subheadline)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
