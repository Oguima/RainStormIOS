//
//  Configuration.swift
//  RainStorm
//
//  Created by Rafael Guimaraes Dos Santos on 21/11/19.
//  Copyright © 2019 Guima Games. All rights reserved.
//

import CoreLocation
import SwiftUI
import UIKit

nonisolated enum Defaults {
    /// Usada quando o usuário não autoriza a localização (São Paulo).
    static let location = CLLocation(latitude: -23.5505, longitude: -46.6333)
    static let locationName = "São Paulo"
}

nonisolated enum WeatherService {
    static let baseUrl = URL(string: "https://api.open-meteo.com/v1/forecast")!
}

extension Color {
    /// Cor da marca RainStorm (antes `UIColor.Rainstorm.base`, #4FB8D4).
    /// No modo claro usa o mesmo matiz escurecido (#367D90): o original tem contraste 2,3:1
    /// sobre branco e reprova no WCAG AA (4,5:1) e no performAccessibilityAudit.
    static let rainstorm = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.31, green: 0.72, blue: 0.83, alpha: 1)
            : UIColor(red: 0.212, green: 0.490, blue: 0.565, alpha: 1)   // #367D90
    })

    /// Texto secundário com contraste AA garantido (#5E5E63 no claro = 6,4:1; #AEAEB2 no escuro).
    /// O `.secondary` do sistema fica em ~3,4:1 e reprova no performAccessibilityAudit.
    static let secondaryText = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.682, green: 0.682, blue: 0.698, alpha: 1)   // #AEAEB2
            : UIColor(red: 0.369, green: 0.369, blue: 0.388, alpha: 1)   // #5E5E63
    })
}
