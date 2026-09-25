//
//  SharedWeatherStore.swift
//  RainStorm
//
//  App Group lido pelo widget e escrito pelo app (e pelo próprio widget após uma busca):
//  última coordenada real do aparelho + último snapshot com o horário da busca.
//

import CoreLocation
import Foundation

nonisolated struct StoredWeather: Codable, Equatable, Sendable {
    let snapshot: WeatherSnapshot
    let fetchedAt: Date
}

final class SharedWeatherStore {

    static let appGroup = "group.com.guimagames.ios.RainStorm"

    /// Sem a entitlement (ex.: build sem assinatura), o domínio cai no `standard` do processo.
    static let shared = SharedWeatherStore(defaults: UserDefaults(suiteName: appGroup) ?? .standard)

    enum Key {
        static let coordinate = "widget.lastCoordinate"
        static let weather = "widget.lastWeather"
    }

    private nonisolated struct StoredCoordinate: Codable {
        let latitude: Double
        let longitude: Double
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    var lastCoordinate: CLLocationCoordinate2D? {
        read(StoredCoordinate.self, forKey: Key.coordinate)
            .map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }

    var lastWeather: StoredWeather? {
        read(StoredWeather.self, forKey: Key.weather)
    }

    func save(coordinate: CLLocationCoordinate2D) {
        write(StoredCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude), forKey: Key.coordinate)
    }

    func save(_ snapshot: WeatherSnapshot, fetchedAt: Date) {
        write(StoredWeather(snapshot: snapshot, fetchedAt: fetchedAt), forKey: Key.weather)
    }

    /// Dado corrompido ou de uma versão antiga do modelo vira `nil` (o widget busca de novo).
    private func read<Value: Decodable>(_ type: Value.Type, forKey key: String) -> Value? {
        defaults.data(forKey: key).flatMap { try? JSONDecoder().decode(type, from: $0) }
    }

    private func write(_ value: some Encodable, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }
}
