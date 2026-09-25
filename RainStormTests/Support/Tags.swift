//
//  Tags.swift
//  RainStormTests
//
//  Permitem filtrar execuções (ex.: só `networking` ou pular `snapshot`).
//

import Testing

extension Tag {
    @Tag static var domain: Self
    @Tag static var decoding: Self
    @Tag static var formatting: Self
    @Tag static var networking: Self
    @Tag static var viewModel: Self
    @Tag static var snapshot: Self
}
