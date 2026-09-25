//
//  WeatherScreen.swift
//  RainStorm
//
//  Substitui RootViewController (container de Day + Week view controllers).
//

import SwiftUI

struct WeatherScreen: View {

    @StateObject private var viewModel: WeatherViewModel

    init(viewModel: @autoclosure @escaping () -> WeatherViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("RainStorm")
        }
        .task { await viewModel.load() }
        // Toque no widget: volta ao app e atualiza (o widget recebe o resultado via WidgetSyncing).
        .onOpenURL { url in
            guard url.scheme == DeepLink.weather.scheme else { return }
            Task { await viewModel.load() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Loading weather…")
                .accessibilityIdentifier("weather.loading")
        case .loaded(let snapshot, let source):
            WeatherContentView(snapshot: snapshot, source: source)
                .refreshable { await viewModel.load() }
        case .failed(let error):
            EmptyStateView(error: error) {
                Task { await viewModel.load() }
            }
        }
    }
}

#if DEBUG
#Preview("Carregado") {
    WeatherScreen(viewModel: .preview(.loaded(.fixture, .device)))
}

#Preview("Localização negada") {
    WeatherScreen(viewModel: .preview(.loaded(.fixture, .fallback)))
}

#Preview("Carregando") {
    WeatherScreen(viewModel: .preview(.loading))
}

#Preview("Erro") {
    WeatherScreen(viewModel: .preview(.failed(.offline)))
}
#endif
