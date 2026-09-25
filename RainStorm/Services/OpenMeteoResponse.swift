//
//  OpenMeteoResponse.swift
//  RainStorm
//
//  DTO da Open-Meteo API. O decode valida os dados (datas e tamanhos dos arrays)
//  e falha com DecodingError em vez de travar ou inventar valores.
//

import Foundation

nonisolated struct OpenMeteoResponse: Decodable, Sendable {

    let latitude: Double
    let longitude: Double
    let timeZone: TimeZone
    let current: WeatherSnapshot.Current
    let forecast: [WeatherSnapshot.Day]

    var snapshot: WeatherSnapshot {
        WeatherSnapshot(timeZone: timeZone, current: current, forecast: forecast)
    }

    private enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case timezone
        case utcOffsetSeconds = "utc_offset_seconds"
        case currentWeather = "current_weather"
        case daily
    }

    private struct RawCurrent: Decodable {
        let time: String
        let temperature: Double
        let windspeed: Double
        let weathercode: Int
        let isDay: Int?

        enum CodingKeys: String, CodingKey {
            case time, temperature, windspeed, weathercode
            case isDay = "is_day"
        }
    }

    private struct RawDaily: Decodable {
        let time: [String]
        let temperatureMin: [Double]
        let temperatureMax: [Double]
        let weathercode: [Int]
        let windspeedMax: [Double]

        enum CodingKeys: String, CodingKey {
            case time
            case temperatureMin = "temperature_2m_min"
            case temperatureMax = "temperature_2m_max"
            case weathercode
            case windspeedMax = "windspeed_10m_max"
        }
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)

        // Com `timezone=auto` a API devolve horários locais sem offset ("2026-09-24T19:45").
        let identifier = try container.decodeIfPresent(String.self, forKey: .timezone)
        let offset = try container.decodeIfPresent(Int.self, forKey: .utcOffsetSeconds) ?? 0
        let timeZone = identifier.flatMap(TimeZone.init(identifier:))
            ?? TimeZone(secondsFromGMT: offset)
            ?? .gmt
        self.timeZone = timeZone

        let rawCurrent = try container.decode(RawCurrent.self, forKey: .currentWeather)
        guard let currentDate = try? Date(rawCurrent.time, strategy: Self.dateTimeStrategy(timeZone)) else {
            throw DecodingError.dataCorruptedError(forKey: .currentWeather, in: container,
                                                   debugDescription: "Invalid time '\(rawCurrent.time)'")
        }
        current = WeatherSnapshot.Current(date: currentDate,
                                          temperature: rawCurrent.temperature,
                                          windSpeed: rawCurrent.windspeed,
                                          weatherCode: rawCurrent.weathercode,
                                          isDay: rawCurrent.isDay != 0)

        let daily = try container.decode(RawDaily.self, forKey: .daily)
        let count = daily.time.count
        guard [daily.temperatureMin.count, daily.temperatureMax.count,
               daily.weathercode.count, daily.windspeedMax.count].allSatisfy({ $0 == count }) else {
            throw DecodingError.dataCorruptedError(forKey: .daily, in: container,
                                                   debugDescription: "Daily arrays have different lengths")
        }

        let dateStrategy = Self.dateStrategy(timeZone)
        forecast = try daily.time.indices.map { index in
            guard let date = try? Date(daily.time[index], strategy: dateStrategy) else {
                throw DecodingError.dataCorruptedError(forKey: .daily, in: container,
                                                       debugDescription: "Invalid date '\(daily.time[index])'")
            }
            return WeatherSnapshot.Day(date: date,
                                       temperatureMin: daily.temperatureMin[index],
                                       temperatureMax: daily.temperatureMax[index],
                                       windSpeedMax: daily.windspeedMax[index],
                                       weatherCode: daily.weathercode[index])
        }
    }

    /// "yyyy-MM-dd'T'HH:mm". `isLenient: false`: sem isso "2026-13-45" vira uma data válida.
    private static func dateTimeStrategy(_ timeZone: TimeZone) -> Date.ParseStrategy {
        Date.ParseStrategy(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)T\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)",
                           locale: Locale(identifier: "en_US_POSIX"),
                           timeZone: timeZone,
                           isLenient: false)
    }

    /// "yyyy-MM-dd"
    private static func dateStrategy(_ timeZone: TimeZone) -> Date.ParseStrategy {
        Date.ParseStrategy(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",
                           locale: Locale(identifier: "en_US_POSIX"),
                           timeZone: timeZone,
                           isLenient: false)
    }
}
