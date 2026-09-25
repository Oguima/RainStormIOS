//
//  TemperatureChartAccessibilityTests.swift
//  RainStormTests
//
//  O gráfico é um único elemento de acessibilidade; estes testes garantem o que o
//  VoiceOver lê e o que o Audio Graph percorre.
//

import Accessibility
import Foundation
import Testing
@testable import RainStorm

@Suite("TemperatureChart acessível")
struct TemperatureChartAccessibilityTests {

    private let days = WeatherSnapshot.fixture.forecast

    @Test func summaryReadsWeekMinimumAndMaximum() {
        let summary = TemperatureChart.summary(of: days, locale: .ptBR).normalizingSpaces
        #expect(summary == "Mínima de 12,8 °C, máxima de 34,3 °C")
    }

    @Test func descriptorHasOneDataPointPerDay() throws {
        let descriptor = TemperatureChart.chartDescriptor(for: days, locale: .ptBR, timeZone: .saoPaulo)
        let points = descriptor.series.first?.dataPoints ?? []

        #expect(points.count == days.count)
        // O overlay Swift não expõe a leitura de x/y; o rótulo é o que o VoiceOver fala por ponto.
        let first = try #require(points.first)
        #expect(first.label?.normalizingSpaces == "12,8 °C – 21,1 °C")
    }

    @Test func descriptorCategoriesFollowForecastOrder() throws {
        let descriptor = TemperatureChart.chartDescriptor(for: days, locale: .ptBR, timeZone: .saoPaulo)
        let xAxis = try #require(descriptor.xAxis as? AXCategoricalDataAxisDescriptor)

        #expect(xAxis.categoryOrder.first == "Quinta-feira")
        #expect(xAxis.categoryOrder.count == 7)
    }
}
