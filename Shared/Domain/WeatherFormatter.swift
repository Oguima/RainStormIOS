//
//  WeatherFormatter.swift
//  RainStorm
//
//  Substitui os DateFormatter por instância e o String(format:) dos antigos ViewModels.
//  Locale e fuso são parâmetros para que a formatação seja determinística nos testes.
//

import Foundation

nonisolated enum WeatherFormatter {

    /// "24,5 °C" em pt-BR; converte para °F em locales que usam Fahrenheit (ex.: en-US).
    static func temperature(_ celsius: Double, locale: Locale) -> String {
        Measurement(value: celsius, unit: UnitTemperature.celsius)
            .formatted(.measurement(width: .abbreviated,
                                    usage: .weather,
                                    numberFormatStyle: .number.precision(.fractionLength(1)))
                .locale(locale))
    }

    /// "16°C" em pt-BR, "61°" em en-US: sem casa decimal, para o gauge circular do widget.
    static func compactTemperature(_ celsius: Double, locale: Locale) -> String {
        Measurement(value: celsius, unit: UnitTemperature.celsius)
            .formatted(.measurement(width: .narrow,
                                    usage: .weather,
                                    numberFormatStyle: .number.precision(.fractionLength(0)))
                .locale(locale))
    }

    /// "12 – 21 °C": faixa de mínima e máxima do dia.
    static func temperatureRange(min: Double, max: Double, locale: Locale) -> String {
        "\(temperature(min, locale: locale)) – \(temperature(max, locale: locale))"
    }

    /// "7 km/h" em pt-BR; mph em locales que usam milhas.
    static func windSpeed(_ kilometersPerHour: Double, locale: Locale) -> String {
        Measurement(value: kilometersPerHour, unit: UnitSpeed.kilometersPerHour)
            .formatted(.measurement(width: .abbreviated,
                                    usage: .general,
                                    numberFormatStyle: .number.precision(.fractionLength(0)))
                .locale(locale))
    }

    /// "quinta-feira, 24 de setembro de 2026" (ano do calendário, não o week-year "YYYY").
    static func fullDate(_ date: Date, locale: Locale, timeZone: TimeZone) -> String {
        date.formatted(style(locale, timeZone).weekday(.wide).day().month(.wide).year())
    }

    /// "19:45" em pt-BR, "7:45 PM" em en-US.
    static func time(_ date: Date, locale: Locale, timeZone: TimeZone) -> String {
        date.formatted(style(locale, timeZone).hour().minute())
    }

    /// "Quinta-feira" (maiúscula só no início, pela regra do idioma; "Quinta-Feira" estaria errado).
    static func weekday(_ date: Date, locale: Locale, timeZone: TimeZone) -> String {
        var format = style(locale, timeZone).weekday(.wide)
        format.capitalizationContext = .beginningOfSentence
        return date.formatted(format)
    }

    /// "qui." — usado no eixo do gráfico.
    static func shortWeekday(_ date: Date, locale: Locale, timeZone: TimeZone) -> String {
        date.formatted(style(locale, timeZone).weekday(.abbreviated))
    }

    /// "24 de setembro"
    static func dayAndMonth(_ date: Date, locale: Locale, timeZone: TimeZone) -> String {
        date.formatted(style(locale, timeZone).day().month(.wide))
    }

    private static func style(_ locale: Locale, _ timeZone: TimeZone) -> Date.FormatStyle {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return Date.FormatStyle(locale: locale, calendar: calendar, timeZone: timeZone)
    }
}
