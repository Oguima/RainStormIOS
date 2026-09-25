//
//  CurrentWeatherView.swift
//  RainStorm
//
//  Substitui DayViewController + DayViewModel.
//

import SwiftUI

struct CurrentWeatherView: View {

    let current: WeatherSnapshot.Current
    let timeZone: TimeZone

    @Environment(\.locale) private var locale

    var body: some View {
        VStack(spacing: 8) {
            Text(WeatherFormatter.fullDate(current.date, locale: locale, timeZone: timeZone))
                .font(.headline)
                .foregroundStyle(.tint)
                .multilineTextAlignment(.center)

            Text(WeatherFormatter.time(current.date, locale: locale, timeZone: timeZone))
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)

            Image(current.iconName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text(WeatherFormatter.temperature(current.temperature, locale: locale))
                .font(.system(.largeTitle, design: .rounded).weight(.semibold))

            Text(current.summary)
                .font(.title3)

            Label(WeatherFormatter.windSpeed(current.windSpeed, locale: locale), systemImage: "wind")
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("weather.current")
    }
}

#if DEBUG
#Preview {
    List {
        CurrentWeatherView(current: WeatherSnapshot.fixture.current, timeZone: WeatherSnapshot.fixture.timeZone)
    }
    .tint(.rainstorm)
}
#endif
