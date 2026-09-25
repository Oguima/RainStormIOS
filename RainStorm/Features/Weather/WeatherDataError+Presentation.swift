//
//  WeatherDataError+Presentation.swift
//  RainStorm
//
//  O que o usuário vê em cada falha (usado pelo EmptyStateView).
//  Os textos são chaves do Localizable.xcstrings (inglês → tradução pt-BR).
//

import Foundation

extension WeatherDataError {

    var title: LocalizedStringResource {
        "Unable to load the weather"
    }

    var message: LocalizedStringResource {
        // TODO(Rafael): diferenciar a mensagem por caso (.offline, .serviceUnavailable, .invalidData).
        // Hoje todos os erros mostram o mesmo texto genérico.
        "Please try again in a few moments."
    }

    /// SF Symbol exibido acima do título.
    var systemImage: String {
        "cloud.bolt"
    }
}
