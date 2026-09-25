//
//  EmptyStateView.swift
//  RainStorm
//
//  Substitui os UIAlertController do RootViewController.
//  (ContentUnavailableView só existe no iOS 17+.)
//

import SwiftUI

struct EmptyStateView: View {

    let error: WeatherDataError
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: error.systemImage)
                .font(.system(size: 48))
                .foregroundStyle(Color.secondaryText)
                .accessibilityHidden(true)

            Text(error.title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(error.message)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.secondaryText)

            Button(action: retry) {
                Label("Try again", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("weather.error.retry")
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // `.contain`: sem isso o identificador do container sobrescreve o do botão de retry.
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("weather.error")
    }
}

#if DEBUG
#Preview("Sem conexão") {
    EmptyStateView(error: .offline) {}
        .tint(.rainstorm)
}

#Preview("Serviço indisponível") {
    EmptyStateView(error: .serviceUnavailable) {}
        .tint(.rainstorm)
}
#endif
