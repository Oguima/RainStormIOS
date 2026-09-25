//
//  WeatherDataError.swift
//  RainStorm
//

import Foundation

nonisolated enum WeatherDataError: Error, Equatable, Sendable {
    /// Sem conexão ou tempo esgotado.
    case offline
    /// A API respondeu com erro (HTTP fora de 2xx) ou falhou por outro motivo de rede.
    case serviceUnavailable
    /// A resposta chegou, mas não pôde ser decodificada ou é inconsistente.
    case invalidData

    init(_ error: URLError) {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .timedOut, .dataNotAllowed,
             .internationalRoamingOff, .cannotConnectToHost, .cannotFindHost:
            self = .offline
        default:
            self = .serviceUnavailable
        }
    }
}
