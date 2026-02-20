//
//  RecommendationEngine.swift
//  WeatherMood
//

import Foundation

struct RecommendationEngine {

    // MARK: - Build DaySummary from raw hourly data for a given date

    static func summary(from hourly: HourlyData, for date: Date, isToday: Bool) -> DaySummary {
        // Open-Meteo returns times as "2026-02-19T14:00" — no seconds, no Z suffix
        let madridTZ = TimeZone(identifier: "Europe/Madrid")!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.timeZone = madridTZ

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = madridTZ

        // Collect indices for all hours on the target date, and daytime subset (8am–8pm)
        var allDayIndices: [Int] = []
        var daytimeIndices: [Int] = []
        for (i, timeStr) in hourly.time.enumerated() {
            guard let t = formatter.date(from: timeStr) else { continue }
            guard calendar.isDate(t, inSameDayAs: date) else { continue }
            allDayIndices.append(i)
            let hour = calendar.component(.hour, from: t)
            if hour >= 8 && hour <= 20 {
                daytimeIndices.append(i)
            }
        }

        guard !daytimeIndices.isEmpty else {
            return DaySummary(
                date: date,
                isToday: isToday,
                feelsLike: 0,
                dayLow: 0,
                dayHigh: 0,
                maxGust: 0,
                maxUV: 0,
                maxHumidity: 0,
                rainWindows: [],
                hasRainAllDay: false,
                recommendations: []
            )
        }

        // Full-day low/high from apparent temperature across all 24 hours
        let allApparent = allDayIndices.map { hourly.apparentTemperature[$0] }
        let dayLow = allApparent.min() ?? 0
        let dayHigh = allApparent.max() ?? 0

        // Daytime slices
        let feelsLikeValues = daytimeIndices.map { hourly.apparentTemperature[$0] }
        let gustValues = daytimeIndices.map { hourly.windgusts10m[$0] }
        let uvValues = daytimeIndices.map { hourly.uvIndex[$0] }
        let humidityValues = daytimeIndices.map { hourly.relativehumidity2m[$0] }
        let precipValues = daytimeIndices.map { hourly.precipitationProbability[$0] }

        let feelsLike = median(feelsLikeValues)
        let maxGust = gustValues.max() ?? 0
        let maxUV = uvValues.max() ?? 0
        let maxHumidity = humidityValues.max() ?? 0

        // Majority rainy = more than half of daytime hours have precip > 40%
        let rainyHours = precipValues.filter { $0 > 40 }.count
        let hasRainAllDay = rainyHours > precipValues.count / 2

        // Rain windows: contiguous hours where precip > 50%
        let rainWindows = buildRainWindows(
            indices: daytimeIndices,
            times: hourly.time,
            precip: precipValues,
            parseFormatter: formatter,
            timeZone: madridTZ
        )

        let recommendations = buildRecommendations(
            feelsLike: feelsLike,
            maxGust: maxGust,
            maxUV: maxUV,
            maxHumidity: maxHumidity,
            rainWindows: rainWindows
        )

        return DaySummary(
            date: date,
            isToday: isToday,
            feelsLike: feelsLike,
            dayLow: dayLow,
            dayHigh: dayHigh,
            maxGust: maxGust,
            maxUV: maxUV,
            maxHumidity: maxHumidity,
            rainWindows: rainWindows,
            hasRainAllDay: hasRainAllDay,
            recommendations: recommendations
        )
    }

    // MARK: - Recommendation rules

    private static func buildRecommendations(
        feelsLike: Double,
        maxGust: Double,
        maxUV: Double,
        maxHumidity: Int,
        rainWindows: [String]
    ) -> [Recommendation] {
        var recs: [Recommendation] = []

        // Jacket / layer
        if feelsLike < 10 {
            recs.append(Recommendation(emoji: "🧥", text: "Wear a warm jacket"))
        } else if feelsLike < 16 {
            recs.append(Recommendation(emoji: "🧥", text: "Bring a light layer"))
        }

        // Wind
        if maxGust > 50 {
            recs.append(Recommendation(emoji: "💨", text: "Very gusty — hold onto your hat"))
        } else if maxGust > 30 {
            recs.append(Recommendation(emoji: "💨", text: "Breezy — a wind layer helps"))
        }

        // Rain
        if !rainWindows.isEmpty {
            let timeLabel = rainWindows.joined(separator: ", ")
            recs.append(Recommendation(emoji: "☂️", text: "Take an umbrella (rain likely \(timeLabel))"))
        }

        // UV
        if maxUV > 7 {
            recs.append(Recommendation(emoji: "🧴", text: "High UV — sunscreen and a hat"))
        } else if maxUV > 4 {
            recs.append(Recommendation(emoji: "🧴", text: "Wear sunscreen"))
        }

        // Humidity + heat
        if maxHumidity > 80 && feelsLike > 25 {
            recs.append(Recommendation(emoji: "💧", text: "It'll feel muggy"))
        }

        return recs
    }

    // MARK: - Rain window builder

    private static func buildRainWindows(
        indices: [Int],
        times: [String],
        precip: [Int],
        parseFormatter: DateFormatter,
        timeZone: TimeZone
    ) -> [String] {
        // precip is already sliced to daytime, indices maps back to hourly arrays
        var windows: [String] = []
        var windowStart: Date? = nil
        var windowEnd: Date? = nil

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "h a"
        displayFormatter.timeZone = timeZone

        for (offset, globalIdx) in indices.enumerated() {
            let prob = precip[offset]
            guard let t = parseFormatter.date(from: times[globalIdx]) else { continue }

            if prob > 50 {
                if windowStart == nil { windowStart = t }
                windowEnd = t
            } else {
                if let start = windowStart, let end = windowEnd {
                    let endPlusOne = end.addingTimeInterval(3600)
                    windows.append("\(displayFormatter.string(from: start))–\(displayFormatter.string(from: endPlusOne))")
                    windowStart = nil
                    windowEnd = nil
                }
            }
        }
        // Close any open window
        if let start = windowStart, let end = windowEnd {
            let endPlusOne = end.addingTimeInterval(3600)
            windows.append("\(displayFormatter.string(from: start))–\(displayFormatter.string(from: endPlusOne))")
        }

        return windows
    }

    // MARK: - Condition label

    static func conditionLabel(feelsLike: Double, maxGust: Double, rainWindows: [String], maxUV: Double) -> String {
        let hasRain = !rainWindows.isEmpty
        let windy = maxGust > 35

        switch feelsLike {
        case ..<5:
            return windy ? "Very cold & windy" : "Very cold"
        case 5..<10:
            return windy ? "Cold & breezy" : "Cold"
        case 10..<16:
            return hasRain ? "Cool & rainy" : windy ? "Cool & breezy" : "Cool"
        case 16..<22:
            return hasRain ? "Mild & rainy" : windy ? "Mild & breezy" : "Mild"
        case 22..<28:
            return hasRain ? "Warm & rainy" : windy ? "Warm & breezy" : (maxUV > 5 ? "Warm & sunny" : "Warm")
        default:
            return maxUV > 6 ? "Hot & sunny" : "Hot"
        }
    }

    // MARK: - Helpers

    private static func median(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let mid = sorted.count / 2
        return sorted.count.isMultiple(of: 2)
            ? (sorted[mid - 1] + sorted[mid]) / 2
            : sorted[mid]
    }
}
