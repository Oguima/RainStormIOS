//
//  WeatherTimelineBuilder.swift
//  RainStorm
//
//  Função pura: snapshot + agora → entradas da timeline + data da próxima recarga.
//  Sem WidgetKit de verdade nem relógio do sistema, para ser testável.
//

import Foundation

/// Quantas horas futuras entram na timeline e quando pedir uma nova.
/// Trade-off: o iOS dá ~40–70 recargas por dia a um widget; entradas horárias mantêm o
/// widget coerente mesmo quando a recarga é adiada, mas envelhecem com a previsão.
nonisolated struct WeatherTimelinePolicy: Equatable, Sendable {
    var maxFutureEntries: Int
    var reloadInterval: TimeInterval
    /// Sem rede, até quando o último clima salvo ainda vale (o `hourly` cobre 12 h).
    var maxCacheAge: TimeInterval

    static let standard = WeatherTimelinePolicy(maxFutureEntries: 6,
                                                reloadInterval: 60 * 60,
                                                maxCacheAge: 12 * 60 * 60)
}

nonisolated enum WeatherTimelineBuilder {

    struct Result: Equatable, Sendable {
        let entries: [WeatherWidgetEntry]
        let reloadDate: Date
    }

    static func build(for snapshot: WeatherSnapshot,
                      now: Date,
                      staleSince: Date?,
                      policy: WeatherTimelinePolicy) -> Result {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = snapshot.timeZone

        func entry(at date: Date, _ condition: WeatherSnapshot.Current) -> WeatherWidgetEntry {
            // Faixa do dia daquela hora, no fuso do local (após a meia-noite, vale o dia seguinte).
            let day = snapshot.forecast.first { calendar.isDate($0.date, inSameDayAs: condition.date) }
            return WeatherWidgetEntry(date: date, content: .weather(WeatherWidgetContent(
                condition: condition,
                timeZone: snapshot.timeZone,
                temperatureMin: day?.temperatureMin,
                temperatureMax: day?.temperatureMax,
                staleSince: staleSince)))
        }

        func condition(_ hour: WeatherSnapshot.Hour) -> WeatherSnapshot.Current {
            WeatherSnapshot.Current(date: hour.date, temperature: hour.temperature, windSpeed: hour.windSpeed,
                                    weatherCode: hour.weatherCode, isDay: hour.isDay)
        }

        // Do cache, a hora prevista mais recente descreve "agora" melhor que a observação antiga.
        let nowCondition = staleSince == nil
            ? snapshot.current
            : snapshot.hourly.last { $0.date <= now && $0.date > snapshot.current.date }.map(condition) ?? snapshot.current

        let future = snapshot.hourly
            .filter { $0.date > now }
            .prefix(policy.maxFutureEntries)
            .map { entry(at: $0.date, condition($0)) }

        return Result(entries: [entry(at: now, nowCondition)] + future,
                      reloadDate: now.addingTimeInterval(policy.reloadInterval))
    }
}
