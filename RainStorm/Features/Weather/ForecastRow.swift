//
//  ForecastRow.swift
//  RainStorm
//
//  Substitui WeekDayTableViewCell + WeekDayViewModel.
//

import SwiftUI

struct ForecastRow: View {

    let day: WeatherSnapshot.Day
    let timeZone: TimeZone

    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        // AnyLayout (iOS 16): empilha na vertical nos tamanhos de acessibilidade.
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: 12))

        layout {
            VStack(alignment: .leading, spacing: 2) {
                Text(WeatherFormatter.weekday(day.date, locale: locale, timeZone: timeZone))
                    .font(.headline)
                    .foregroundStyle(.tint)
                Text(WeatherFormatter.dayAndMonth(day.date, locale: locale, timeZone: timeZone))
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: 0)
            }

            Image(day.iconName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .foregroundStyle(.tint)
                .accessibilityLabel(Text(day.summary))

            VStack(alignment: dynamicTypeSize.isAccessibilitySize ? .leading : .trailing, spacing: 2) {
                Text(WeatherFormatter.temperatureRange(min: day.temperatureMin, max: day.temperatureMax, locale: locale))
                    .font(.subheadline)
                Label(WeatherFormatter.windSpeed(day.windSpeedMax, locale: locale), systemImage: "wind")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("weather.forecast.row")
    }
}

#if DEBUG
#Preview {
    List(WeatherSnapshot.fixture.forecast) { day in
        ForecastRow(day: day, timeZone: WeatherSnapshot.fixture.timeZone)
    }
    .tint(.rainstorm)
}
#endif
