//
//  WeatherTimelineProvider.swift
//  RainStormWidget
//
//  Casca WidgetKit sobre o WeatherWidgetLoader (Shared, testado no RainStormTests).
//  O WidgetKit chama o provider fora do main actor; a busca roda no main actor, como no app.
//

import SwiftUI
import WidgetKit

nonisolated struct WeatherTimelineProvider: TimelineProvider {

    func placeholder(in context: Context) -> WeatherWidgetEntry {
        .sample()
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherWidgetEntry) -> Void) {
        // Galeria de widgets: resposta imediata, sem rede.
        guard !context.isPreview else {
            completion(.sample())
            return
        }
        // O SDK não marca o completion como @Sendable, mas o WidgetKit aceita chamá-lo
        // de qualquer thread: o opt-out fica restrito a esta captura.
        nonisolated(unsafe) let completion = completion
        Task { @MainActor in
            completion(await Self.makeLoader().timeline(now: .now).entries[0])
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherWidgetEntry>) -> Void) {
        nonisolated(unsafe) let completion = completion
        Task { @MainActor in
            let result = await Self.makeLoader().timeline(now: .now)
            completion(Timeline(entries: result.entries, policy: .after(result.reloadDate)))
        }
    }

    @MainActor
    private static func makeLoader() -> WeatherWidgetLoader {
        WeatherWidgetLoader(service: OpenMeteoWeatherService(session: .widget), store: .shared)
    }
}
