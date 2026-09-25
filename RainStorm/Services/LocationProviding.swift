//
//  LocationProviding.swift
//  RainStorm
//
//  Wrapper async sobre CLLocationManager (CLLocationUpdate.liveUpdates só existe no iOS 17+).
//

import CoreLocation

nonisolated enum LocationError: Error, Equatable, Sendable {
    case notAuthorized
    case unavailable
}

protocol LocationProviding {
    func currentLocation() async throws(LocationError) -> CLLocation
}

final class LocationProvider: NSObject, LocationProviding {

    private let manager = CLLocationManager()
    /// Chamadas simultâneas (ex.: `.task` + pull-to-refresh) aguardam a mesma leitura.
    private var pending: [CheckedContinuation<CLLocation, any Error>] = []

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func currentLocation() async throws(LocationError) -> CLLocation {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                pending.append(continuation)
                if pending.count == 1 {
                    requestLocationIfAuthorized()
                }
            }
        } catch let error as LocationError {
            throw error
        } catch {
            throw .unavailable
        }
    }

    private func requestLocationIfAuthorized() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()   // continua em locationManagerDidChangeAuthorization
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            finish(with: .failure(LocationError.notAuthorized))
        }
    }

    private func authorizationDidChange() {
        guard !pending.isEmpty, manager.authorizationStatus != .notDetermined else { return }
        requestLocationIfAuthorized()
    }

    private func finish(with result: Result<CLLocation, any Error>) {
        let continuations = pending
        pending.removeAll()
        continuations.forEach { $0.resume(with: result) }
    }
}

extension LocationProvider: CLLocationManagerDelegate {

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in self.authorizationDidChange() }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in self.finish(with: .success(location)) }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        Task { @MainActor in self.finish(with: .failure(LocationError.unavailable)) }
    }
}
