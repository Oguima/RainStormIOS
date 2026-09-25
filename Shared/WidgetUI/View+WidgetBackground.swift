//
//  View+WidgetBackground.swift
//  RainStorm
//

import SwiftUI
import WidgetKit

extension View {

    /// iOS 17+: `containerBackground` (sem ele o sistema mostra "Please adopt containerBackground API")
    /// e margens automáticas. iOS 16: fundo e margem manuais nas famílias da tela inicial.
    @ViewBuilder
    func widgetBackground(for family: WidgetFamily) -> some View {
        let background = family.isAccessory ? Color.clear : Color(uiColor: .systemBackground)
        if #available(iOS 17, *) {
            containerBackground(background, for: .widget)
        } else if family.isAccessory {
            self
        } else {
            padding().frame(maxWidth: .infinity, maxHeight: .infinity).background(background)
        }
    }
}

extension WidgetFamily {
    /// Famílias da tela de bloqueio (iOS 16+).
    var isAccessory: Bool {
        switch self {
        case .accessoryCircular, .accessoryRectangular, .accessoryInline: true
        default: false
        }
    }
}
