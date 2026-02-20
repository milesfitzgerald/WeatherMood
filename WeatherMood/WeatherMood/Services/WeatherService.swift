//
//  WeatherService.swift
//  WeatherMood
//

import Foundation

struct WeatherService {
    // Barcelona coordinates, hardcoded
    private static let latitude = 41.39
    private static let longitude = 2.16
    private static let timezone = "Europe/Madrid"

    static func fetch() async throws -> OpenMeteoResponse {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            .init(name: "latitude", value: "\(latitude)"),
            .init(name: "longitude", value: "\(longitude)"),
            .init(name: "hourly", value: "apparent_temperature,temperature_2m,precipitation_probability,rain,windspeed_10m,windgusts_10m,relativehumidity_2m,uv_index"),
            .init(name: "past_days", value: "1"),
            .init(name: "forecast_days", value: "1"),
            .init(name: "timezone", value: timezone),
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(OpenMeteoResponse.self, from: data)
    }
}
