//
//  Fixture.swift
//  RainStormTests
//

import Foundation

private final class BundleToken {}

enum Fixture {
    /// Carrega `Fixtures/<name>.json` do bundle de testes.
    static func data(_ name: String) -> Data? {
        Bundle(for: BundleToken.self)
            .url(forResource: name, withExtension: "json")
            .flatMap { try? Data(contentsOf: $0) }
    }
}

extension Locale {
    static let ptBR = Locale(identifier: "pt_BR")
    static let enUS = Locale(identifier: "en_US")
}

extension TimeZone {
    static let saoPaulo = TimeZone(identifier: "America/Sao_Paulo")!
}

extension String {
    /// Foundation usa espaços não separáveis (U+00A0 / U+202F) em números e datas.
    var normalizingSpaces: String {
        replacingOccurrences(of: "\u{00A0}", with: " ")
            .replacingOccurrences(of: "\u{202F}", with: " ")
    }
}
