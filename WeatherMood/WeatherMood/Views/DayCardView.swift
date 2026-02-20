//
//  DayCardView.swift
//  WeatherMood
//

import SwiftUI

struct DayCardView: View {
    let summary: DaySummary

    private var conditionLabel: String {
        RecommendationEngine.conditionLabel(
            feelsLike: summary.feelsLike,
            maxGust: summary.maxGust,
            rainWindows: summary.rainWindows,
            maxUV: summary.maxUV
        )
    }

    private var dayLabel: String {
        summary.isToday ? "Today" : "Yesterday"
    }

    @State private var showingInfo = false

    var body: some View {
        ZStack {
            weatherGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Header row: city/day label + info button
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Barcelona")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.7))
                            Text(dayLabel)
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                        Spacer()
                        Button {
                            showingInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.75))
                                .padding(4)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 24)
                    .sheet(isPresented: $showingInfo) {
                        InfoSheetView()
                    }

                    // Big temperature + L/H
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text("\(Int(summary.feelsLike.rounded()))°")
                            .font(.system(size: 96, weight: .thin, design: .rounded))
                            .foregroundStyle(.white)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("H:\(Int(summary.dayHigh.rounded()))°")
                                .font(.callout.weight(.medium))
                                .foregroundStyle(.white.opacity(0.85))
                            Text("L:\(Int(summary.dayLow.rounded()))°")
                                .font(.callout.weight(.medium))
                                .foregroundStyle(.white.opacity(0.65))
                        }
                        .padding(.leading, 8)
                        .padding(.bottom, 14)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)

                    // Condition summary
                    Text(conditionLabel)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.horizontal, 24)
                        .padding(.top, 2)

                    // Detail pills
                    detailPills
                        .padding(.top, 20)
                        .padding(.horizontal, 24)

                    // Recommendations
                    if !summary.recommendations.isEmpty {
                        Text(summary.isToday ? "What to wear" : "What you needed")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                            .textCase(.uppercase)
                            .tracking(0.8)
                            .padding(.horizontal, 24)
                            .padding(.top, 28)
                            .padding(.bottom, 2)

                        VStack(spacing: 8) {
                            ForEach(summary.recommendations) { rec in
                                RecommendationRow(recommendation: rec)
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    Spacer(minLength: 48)
                }
            }
        }
        .saturation(summary.isToday ? 1.0 : 0.35)
        .opacity(summary.isToday ? 1.0 : 0.85)
    }

    // MARK: - Weather-condition gradient

    private var weatherGradient: some View {
        let isRainy = summary.hasRainAllDay || !summary.rainWindows.isEmpty
        let isSunny = summary.maxUV > 4 && !isRainy
        let isWindy = summary.maxGust > 40
        let temp = summary.feelsLike

        let colors: [Color]

        if isRainy {
            // Rainy: deep slate → steel blue
            colors = [
                Color(red: 0.28, green: 0.33, blue: 0.45),
                Color(red: 0.42, green: 0.50, blue: 0.62),
                Color(red: 0.55, green: 0.63, blue: 0.72)
            ]
        } else if isSunny {
            switch temp {
            case ..<15:
                // Sunny but cool: pale gold → sky blue
                colors = [
                    Color(red: 0.36, green: 0.55, blue: 0.78),
                    Color(red: 0.68, green: 0.80, blue: 0.90),
                    Color(red: 0.95, green: 0.88, blue: 0.62)
                ]
            case 15..<24:
                // Sunny and warm: rich blue → warm gold
                colors = [
                    Color(red: 0.18, green: 0.48, blue: 0.82),
                    Color(red: 0.52, green: 0.75, blue: 0.92),
                    Color(red: 0.99, green: 0.82, blue: 0.38)
                ]
            default:
                // Hot and sunny: deep sky → vivid orange
                colors = [
                    Color(red: 0.12, green: 0.42, blue: 0.78),
                    Color(red: 0.95, green: 0.62, blue: 0.22),
                    Color(red: 0.98, green: 0.40, blue: 0.12)
                ]
            }
        } else if isWindy {
            // Windy: cool grey-green → slate
            colors = [
                Color(red: 0.32, green: 0.42, blue: 0.50),
                Color(red: 0.48, green: 0.58, blue: 0.62),
                Color(red: 0.66, green: 0.74, blue: 0.76)
            ]
        } else {
            // Overcast / mild: temperature-driven muted tones
            switch temp {
            case ..<5:
                colors = [
                    Color(red: 0.28, green: 0.35, blue: 0.52),
                    Color(red: 0.44, green: 0.52, blue: 0.68),
                    Color(red: 0.62, green: 0.70, blue: 0.82)
                ]
            case 5..<12:
                colors = [
                    Color(red: 0.30, green: 0.42, blue: 0.60),
                    Color(red: 0.48, green: 0.60, blue: 0.75),
                    Color(red: 0.68, green: 0.78, blue: 0.88)
                ]
            case 12..<20:
                colors = [
                    Color(red: 0.28, green: 0.50, blue: 0.65),
                    Color(red: 0.45, green: 0.65, blue: 0.78),
                    Color(red: 0.68, green: 0.82, blue: 0.88)
                ]
            default:
                colors = [
                    Color(red: 0.42, green: 0.55, blue: 0.55),
                    Color(red: 0.60, green: 0.72, blue: 0.68),
                    Color(red: 0.80, green: 0.88, blue: 0.82)
                ]
            }
        }

        return LinearGradient(
            colors: colors,
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Detail pills

    @ViewBuilder
    private var detailPills: some View {
        HStack(spacing: 10) {
            if !summary.rainWindows.isEmpty {
                DetailPill(emoji: "🌧", text: summary.rainWindows.first!)
            }
            if summary.maxGust > 20 {
                DetailPill(emoji: "💨", text: "\(Int(summary.maxGust)) km/h gusts")
            }
            if summary.maxUV > 2 {
                DetailPill(emoji: "☀️", text: "UV \(Int(summary.maxUV))")
            }
        }
    }
}

// MARK: - Detail Pill

struct DetailPill: View {
    let emoji: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Text(emoji)
                .font(.caption)
            Text(text)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.white.opacity(0.2), in: Capsule())
    }
}
