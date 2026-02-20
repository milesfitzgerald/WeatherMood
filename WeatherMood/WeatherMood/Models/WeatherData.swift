//
//  WeatherData.swift
//  WeatherMood
//

import Foundation

// MARK: - Open-Meteo API Response

struct OpenMeteoResponse: Codable {
    let hourly: HourlyData

    enum CodingKeys: String, CodingKey {
        case hourly
    }
}

struct HourlyData: Codable {
    let time: [String]
    let apparentTemperature: [Double]
    let temperature2m: [Double]
    let precipitationProbability: [Int]
    let rain: [Double]
    let windspeed10m: [Double]
    let windgusts10m: [Double]
    let relativehumidity2m: [Int]
    let uvIndex: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case apparentTemperature = "apparent_temperature"
        case temperature2m = "temperature_2m"
        case precipitationProbability = "precipitation_probability"
        case rain
        case windspeed10m = "windspeed_10m"
        case windgusts10m = "windgusts_10m"
        case relativehumidity2m = "relativehumidity_2m"
        case uvIndex = "uv_index"
    }
}

// MARK: - Processed Day Summary

struct DaySummary {
    let date: Date
    let isToday: Bool
    let feelsLike: Double       // median daytime apparent temp (8am–8pm)
    let dayLow: Double          // min apparent temp across full day
    let dayHigh: Double         // max apparent temp across full day
    let maxGust: Double         // km/h
    let maxUV: Double
    let maxHumidity: Int
    let rainWindows: [String]   // e.g. ["3 PM–5 PM"]
    let hasRainAllDay: Bool     // majority of day is rainy
    let recommendations: [Recommendation]
}

struct Recommendation: Identifiable {
    let id = UUID()
    let emoji: String
    let text: String
}
