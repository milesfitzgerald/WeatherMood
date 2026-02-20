//
//  WeatherViewModel.swift
//  WeatherMood
//

import Foundation
import Observation

@Observable
class WeatherViewModel {
    var today: DaySummary?
    var yesterday: DaySummary?
    var isLoading = false
    var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await WeatherService.fetch()
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "Europe/Madrid")!
            let todayDate = calendar.startOfDay(for: Date())
            let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: todayDate)!

            await MainActor.run {
                self.today = RecommendationEngine.summary(
                    from: response.hourly,
                    for: todayDate,
                    isToday: true
                )
                self.yesterday = RecommendationEngine.summary(
                    from: response.hourly,
                    for: yesterdayDate,
                    isToday: false
                )
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Couldn't load weather. Check your connection."
                self.isLoading = false
            }
        }
    }
}
