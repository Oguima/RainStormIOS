//
//  CurrentWeatherWidget.swift
//  RainStormWidget
//
//  O card "clima atual" do app na tela inicial (pequeno/médio) e na tela de bloqueio.
//

import SwiftUI
import WidgetKit

struct CurrentWeatherWidget: Widget {

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetKind.currentWeather, provider: WeatherTimelineProvider()) { entry in
            CurrentWeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Current weather")
        .description("The current conditions and today's range, as in the app.")
        .supportedFamilies([.systemSmall, .systemMedium,
                            .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

/// Lê a família do ambiente (somente leitura) e repassa para a view compartilhada.
struct CurrentWeatherWidgetEntryView: View {

    let entry: WeatherWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        CurrentWeatherWidgetView(entry: entry, family: family)
    }
}

#if DEBUG
// `#Preview(as:)` exige iOS 17; PreviewProvider funciona no iOS 16.
struct CurrentWeatherWidget_Previews: PreviewProvider {

    static let families: [WidgetFamily] = [.systemSmall, .systemMedium,
                                           .accessoryCircular, .accessoryRectangular, .accessoryInline]

    static var previews: some View {
        ForEach(families, id: \.self) { family in
            CurrentWeatherWidgetView(entry: .sample(), family: family)
                .previewContext(WidgetPreviewContext(family: family))
                .previewDisplayName("\(family)")
        }
        CurrentWeatherWidgetView(entry: WeatherWidgetEntry(date: .now, content: .unavailable), family: .systemSmall)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Indisponível")
    }
}
#endif
