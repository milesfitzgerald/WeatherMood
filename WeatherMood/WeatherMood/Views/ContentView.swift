//
//  ContentView.swift
//  WeatherMood
//

import SwiftUI

struct ContentView: View {
    @State private var vm = WeatherViewModel()
    @State private var selectedPage = 0   // 0 = today, 1 = yesterday

    var body: some View {
        ZStack {
            if vm.isLoading {
                loadingView
            } else if let error = vm.errorMessage {
                errorView(message: error)
            } else if vm.today != nil && vm.yesterday != nil {
                cardPager
            } else {
                loadingView
            }
        }
        .task {
            await vm.load()
        }
    }

    // MARK: - Card pager

    private var cardPager: some View {
        // Force-unwrap is safe here — cardPager is only shown when both are non-nil
        let today = vm.today!
        let yesterday = vm.yesterday!

        return ZStack(alignment: .bottom) {
            TabView(selection: $selectedPage) {
                DayCardView(summary: today)
                    .tag(0)
                DayCardView(summary: yesterday)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Page indicator + label
            HStack(spacing: 8) {
                pageIndicatorDot(active: selectedPage == 0, label: "Today")
                pageIndicatorDot(active: selectedPage == 1, label: "Yesterday")
            }
            .padding(.bottom, 32)
        }
    }

    @ViewBuilder
    private func pageIndicatorDot(active: Bool, label: String) -> some View {
        Text(label)
            .font(.caption.weight(active ? .semibold : .regular))
            .foregroundStyle(active ? Color.primary : Color.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(active ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Color.clear))
            )
            .animation(.easeInOut(duration: 0.2), value: active)
    }

    // MARK: - Loading

    private var loadingView: some View {
        ZStack {
            Color(uiColor: .systemBackground).ignoresSafeArea()
            ProgressView()
                .scaleEffect(1.5)
        }
    }

    // MARK: - Error

    private func errorView(message: String) -> some View {
        ZStack {
            Color(uiColor: .systemBackground).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                Text(message)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Button("Try again") {
                    Task { await vm.load() }
                }
                .buttonStyle(.bordered)
            }
            .padding(40)
        }
    }
}

#Preview {
    ContentView()
}
