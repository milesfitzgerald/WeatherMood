# WeatherMood

A minimal iOS weather app that tells you how the weather **actually feels** — not what the thermometer says — and what to wear.

> **Hardcoded for Barcelona.** Coordinates are fixed at 41.39°N, 2.16°E. No location detection, no settings screen.

---

## What it does

Two swipeable cards — Today and Yesterday — each showing:

- **Feels-like temperature** — the median apparent temperature between 8 AM and 8 PM, accounting for wind chill and humidity
- **H: / L:** — the highest and lowest apparent temperatures across the full 24-hour day
- **Condition summary** — "Cool & breezy", "Warm & sunny", etc.
- **Detail pills** — rain window timing, wind gusts, UV index
- **Dressing advice** — a rule-based list telling you exactly what to bring

Yesterday's card is desaturated and shows advice in past tense ("What you needed"), so you can check how accurate it would have been.

Tap the **ⓘ** icon to read how the feels-like temperature is calculated and how the recommendation rules work.

---

## Recommendation rules

| Condition | Advice |
|---|---|
| Feels like < 10°C | 🧥 Wear a warm jacket |
| Feels like 10–16°C | 🧥 Bring a light layer |
| Gusts > 30 km/h | 💨 Breezy — a wind layer helps |
| Gusts > 50 km/h | 💨 Very gusty — hold onto your hat |
| Any hour with precip > 50% | ☂️ Take an umbrella (with time window) |
| UV index > 4 | 🧴 Wear sunscreen |
| UV index > 7 | 🧴 High UV — sunscreen and a hat |
| Humidity > 80% and warm | 💧 It'll feel muggy |

---

## Background gradients

The card background shifts based on weather condition, not just temperature:

- 🌧 **Rainy** — deep slate to steel blue
- ☀️ **Sunny + cool** — blue to sky to pale gold
- ☀️ **Sunny + warm** — rich blue to warm gold
- ☀️ **Sunny + hot** — deep sky to vivid orange
- 💨 **Windy** — cool grey-green
- ⛅ **Overcast** — temperature-tinted blue-greys

---

## Tech stack

- **SwiftUI** — iOS 17+, no UIKit
- **Open-Meteo** — free, open-source weather API, no key required
- **URLSession + Codable** — no dependencies
- **`@Observable`** — Swift 5.9 observation macro

### API endpoint

```
https://api.open-meteo.com/v1/forecast
  ?latitude=41.39&longitude=2.16
  &hourly=apparent_temperature,temperature_2m,precipitation_probability,
          rain,windspeed_10m,windgusts_10m,relativehumidity_2m,uv_index
  &past_days=1&forecast_days=1
  &timezone=Europe/Madrid
```

One call returns yesterday + today in a single 48-hour window.

---

## Project structure

```
WeatherMood/
├── Models/WeatherData.swift          — Codable API structs + DaySummary
├── Services/WeatherService.swift     — URLSession fetch
├── Engine/RecommendationEngine.swift — Rule logic, condition labels
├── ViewModels/WeatherViewModel.swift — @Observable, async data loading
└── Views/
    ├── ContentView.swift             — TabView(.page) swipe container
    ├── DayCardView.swift             — Card UI, gradient, detail pills
    ├── RecommendationRow.swift       — Individual advice chip
    └── InfoSheetView.swift           — How it works sheet
```

---

## Build

1. Clone the repo
2. Open `WeatherMood/WeatherMood.xcodeproj` in Xcode 16+
3. Select an iPhone simulator
4. `Cmd+R`

No API keys. No dependencies to install.
