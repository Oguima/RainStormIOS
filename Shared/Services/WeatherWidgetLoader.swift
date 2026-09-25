//
//  WeatherWidgetLoader.swift
//  RainStorm
//
//  O que o TimelineProvider do widget faz, fora do WidgetKit para ser testável:
//  busca na rede; sem rede, usa o cache do App Group; sem cache, pede para abrir o app.
//

import CoreLocation
import Foundation

struct WeatherWidgetLoader {

    let service: any WeatherServicing
    let store: SharedWeatherStore
    var policy: WeatherTimelinePolicy = .standard

    func timeline(now: Date) async -> WeatherTimelineBuilder.Result {
        let coordinate = store.lastCoordinate ?? Defaults.location.coordinate
        do {
            let snapshot = try await service.forecast(for: coordinate)
            store.save(snapshot, fetchedAt: now)
            return WeatherTimelineBuilder.build(for: snapshot, now: now, staleSince: nil, policy: policy)
        } catch {
            if let cached = store.lastWeather, now.timeIntervalSince(cached.fetchedAt) <= policy.maxCacheAge {
                return WeatherTimelineBuilder.build(for: cached.snapshot, now: now,
                                                    staleSince: cached.fetchedAt, policy: policy)
            }
            return WeatherTimelineBuilder.Result(entries: [WeatherWidgetEntry(date: now, content: .unavailable)],
                                                 reloadDate: now.addingTimeInterval(policy.reloadInterval))
        }
    }
}
