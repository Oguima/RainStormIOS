//
//  WeatherWidgetEntry.swift
//  RainStorm
//
//  Uma entrada da timeline: o clima de um instante (agora ou uma hora futura).
//

import Foundation
import WidgetKit

nonisolated struct WeatherWidgetEntry: TimelineEntry, Equatable, Sendable {

    enum Content: Equatable, Sendable {
        case weather(WeatherWidgetContent)
        /// Sem rede e sem cache: o widget pede para abrir o app.
        case unavailable
    }

    let date: Date
    let content: Content

    /// Placeholder, galeria de widgets e previews.
    static func sample(date: Date = WeatherSnapshot.sample.current.date) -> WeatherWidgetEntry {
        WeatherTimelineBuilder.build(for: .sample, now: date, staleSince: nil, policy: .standard).entries[0]
    }
}

/// O mesmo conteúdo do card do app, mais a faixa do dia e a marca de "desatualizado".
nonisolated struct WeatherWidgetContent: Equatable, Sendable {
    /// Condição exibida; `date` é o horário da observação (atual) ou da hora prevista.
    let condition: WeatherSnapshot.Current
    let timeZone: TimeZone
    /// Mínima e máxima do dia de `condition.date`; `nil` se a previsão diária não cobre esse dia.
    let temperatureMin: Double?
    let temperatureMax: Double?
    /// Quando os dados vêm do cache (sem rede): horário da última busca bem-sucedida.
    let staleSince: Date?
}
