//
//  RecommendationRow.swift
//  WeatherMood
//

import SwiftUI

struct RecommendationRow: View {
    let recommendation: Recommendation

    var body: some View {
        HStack(spacing: 12) {
            Text(recommendation.emoji)
                .font(.title3)
            Text(recommendation.text)
                .font(.subheadline)
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
    }
}
