//
//  WidgetSyncing.swift
//  RainStorm
//
//  Ponte app → widget: depois de cada busca bem-sucedida no app, grava no App Group
//  e pede ao WidgetKit uma timeline nova.
//

import CoreLocation
import Foundation
import WidgetKit

nonisolated enum WidgetKind {
    static let currentWeather = "CurrentWeatherWidget"
}

protocol WidgetSyncing {
    /// `deviceCoordinate == nil`: a busca usou o fallback (São Paulo) e não deve
    /// sobrescrever a última posição real do aparelho.
    func didFetch(_ snapshot: WeatherSnapshot, deviceCoordinate: CLLocationCoordinate2D?)
}

struct WidgetCenterSync: WidgetSyncing {

    var store: SharedWeatherStore = .shared
    var now: () -> Date = Date.init
    var reloadTimelines: (String) -> Void = { WidgetCenter.shared.reloadTimelines(ofKind: $0) }

    func didFetch(_ snapshot: WeatherSnapshot, deviceCoordinate: CLLocationCoordinate2D?) {
        store.save(snapshot, fetchedAt: now())
        if let deviceCoordinate {
            store.save(coordinate: deviceCoordinate)
        }
        reloadTimelines(WidgetKind.currentWeather)
    }
}
