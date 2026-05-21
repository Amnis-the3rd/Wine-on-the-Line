//
//  SunTrackerView.swift
//  want-space
//
//  Created by Amna on 2026-04-29.
//

import SwiftUI
import CoreLocation

struct SunTrackerView: View {
    let bar: WineBar
    @State private var currentTime = Date()
    @State private var osmObstructions: [ShadowObstruction] = []
    @State private var isLoadingOSM = true
    @StateObject private var weatherService = WeatherService.shared
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var allObstructions: [ShadowObstruction] {
        osmObstructions.isEmpty ? bar.shadowObstructions : osmObstructions
    }

    var sunPosition: SolarPosition {
        SolarCalculator.sunPosition(at: bar.coordinate, date: currentTime)
    }

    var facesTheSun: Bool {
        bar.outdoorFacingDirection.contains { direction in
            SolarCalculator.isInSun(
                coordinate: bar.coordinate,
                facingDirection: direction,
                obstructions: allObstructions,
                date: currentTime
            )
        }
    }

    var isActuallySunny: Bool {
        guard let weather = weatherService.currentWeather else { return facesTheSun }
        return facesTheSun && weather.isSunny
    }

    var remainingTime: TimeInterval? {
        bar.outdoorFacingDirection
            .compactMap { direction in
                SolarCalculator.sunRemainingTime(
                    coordinate: bar.coordinate,
                    facingDirection: direction,
                    obstructions: allObstructions
                )
            }
            .max()
    }

    var sunStatusIcon: String {
        guard sunPosition.isAboveHorizon else { return "🌙" }
        if !facesTheSun { return "🌥️" }
        if let weather = weatherService.currentWeather, weather.isCloudy { return "🌥️" }
        return "☀️"
    }

    var sunStatusText: String {
        guard sunPosition.isAboveHorizon else { return "Sun has set for today" }
        guard facesTheSun else { return "In shade right now" }
        if let weather = weatherService.currentWeather, weather.isCloudy {
            return "Cloudy today, but faces the sun"
        }
        return "Sunny right now!"
    }

    var sunStatusColor: Color {
        guard sunPosition.isAboveHorizon && facesTheSun else { return AppTheme.subtleText }
        if let weather = weatherService.currentWeather, weather.isCloudy { return .gray }
        return .orange
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("☀️ Outdoor Sun Tracker")
                .font(.headline)
                .foregroundStyle(AppTheme.burgundy)

            if !bar.hasOutdoorSeating {
                Text("No outdoor seating at this bar")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.subtleText)
            } else if bar.outdoorFacingDirection.isEmpty {
                Text("Outdoor seating direction not yet added")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.subtleText)
            } else {
                HStack(spacing: 16) {
                    // Big status icon
                    ZStack {
                        Circle()
                            .fill(isActuallySunny ? Color.yellow.opacity(0.15) : Color.gray.opacity(0.08))
                            .frame(width: 64, height: 64)
                        Text(sunStatusIcon)
                            .font(.system(size: 34))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(sunStatusText)
                            .font(.headline)
                            .foregroundStyle(sunStatusColor)

                        if let weather = weatherService.currentWeather {
                            Text(weather.weatherDescription)
                                .font(.caption)
                                .foregroundStyle(AppTheme.subtleText)
                        }

                        if facesTheSun, let remaining = remainingTime {
                            Text(SolarCalculator.formatRemainingTime(remaining))
                                .font(.caption.bold())
                                .foregroundStyle(isActuallySunny ? .orange : AppTheme.subtleText)
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        .task {
            async let buildings = OSMBuildingService.shared.fetchNearbyBuildings(coordinate: bar.coordinate)
            async let weather: () = weatherService.fetchWeather(for: bar.coordinate)
            osmObstructions = await buildings
            await weather
            isLoadingOSM = false
        }
        .onReceive(timer) { time in
            currentTime = time
        }
    }
}
