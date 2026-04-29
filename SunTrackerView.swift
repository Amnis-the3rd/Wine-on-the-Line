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
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var allObstructions: [ShadowObstruction] {
        // Combine manual + OSM obstructions
        // OSM takes priority but manual fills gaps
        osmObstructions.isEmpty ? bar.shadowObstructions : osmObstructions
    }

    var isInSun: Bool {
        guard let direction = bar.outdoorFacingDirection else { return false }
        return SolarCalculator.isInSun(
            coordinate: bar.coordinate,
            facingDirection: direction,
            obstructions: allObstructions,
            date: currentTime
        )
    }

    var remainingTime: TimeInterval? {
        guard let direction = bar.outdoorFacingDirection else { return nil }
        return SolarCalculator.sunRemainingTime(
            coordinate: bar.coordinate,
            facingDirection: direction,
            obstructions: allObstructions
        )
    }

    var sunPosition: SolarPosition {
        SolarCalculator.sunPosition(at: bar.coordinate, date: currentTime)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("☀️ Outdoor Sun Tracker")
                    .font(.headline)
                    .foregroundStyle(AppTheme.burgundy)
                Spacer()
                if isLoadingOSM {
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Loading buildings...")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.subtleText)
                    }
                } else {
                    Text("Building data loaded")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.metroGreen)
                }
            }

            if !bar.hasOutdoorSeating {
                Text("No outdoor seating at this bar")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.subtleText)
            } else if bar.outdoorFacingDirection == nil {
                Text("Outdoor seating direction not yet added")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.subtleText)
            } else {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(isInSun ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.1))
                            .frame(width: 56, height: 56)
                        Text(isInSun ? "☀️" : "🌥️")
                            .font(.title)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isInSun ? "Sunny right now!" : "In shade right now")
                            .font(.headline)
                            .foregroundStyle(isInSun ? .orange : AppTheme.subtleText)
                        if let remaining = remainingTime {
                            Text(SolarCalculator.formatRemainingTime(remaining))
                                .font(.caption)
                                .foregroundStyle(AppTheme.subtleText)
                        } else if sunPosition.isAboveHorizon {
                            Text("No sun on outdoor seating now")
                                .font(.caption)
                                .foregroundStyle(AppTheme.subtleText)
                        } else {
                            Text("Sun has set for today")
                                .font(.caption)
                                .foregroundStyle(AppTheme.subtleText)
                        }
                        
                        if !allObstructions.isEmpty {
                            Text("\(allObstructions.count) nearby buildings detected")
                                .font(.caption2)
                                .foregroundStyle(AppTheme.subtleText.opacity(0.7))
                        }
                    }
                }

                SunPathDiagram(
                    sunAzimuth: sunPosition.azimuth,
                    sunAltitude: sunPosition.altitude,
                    facingDirection: bar.outdoorFacingDirection ?? 180,
                    obstructions: allObstructions,
                    isInSun: isInSun
                )
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        .task {
            osmObstructions = await OSMBuildingService.shared.fetchNearbyBuildings(
                coordinate: bar.coordinate
            )
            isLoadingOSM = false
        }
        .onReceive(timer) { time in
            currentTime = time
        }
    }
}
// MARK: - Sun Path Diagram

struct SunPathDiagram: View {
    let sunAzimuth: Double
    let sunAltitude: Double
    let facingDirection: Double
    let obstructions: [ShadowObstruction]
    let isInSun: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.champagne, lineWidth: 2)
                .frame(width: 160, height: 160)

            // Obstruction indicators
            ForEach(obstructions.indices, id: \.self) { i in
                let obs = obstructions[i]
                let angle = (obs.direction - 90) * .pi / 180
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 8, height: 20)
                    .offset(
                        x: 65 * cos(angle),
                        y: 65 * sin(angle)
                    )
            }

            ForEach(["N", "E", "S", "W"].indices, id: \.self) { i in
                let angle = Double(i) * 90.0 - 90.0
                let label = ["N", "E", "S", "W"][i]
                Text(label)
                    .font(.caption2.bold())
                    .foregroundStyle(AppTheme.subtleText)
                    .offset(
                        x: 85 * cos(angle * .pi / 180),
                        y: 85 * sin(angle * .pi / 180)
                    )
            }

            Rectangle()
                .fill(AppTheme.burgundy.opacity(0.4))
                .frame(width: 4, height: 60)
                .offset(y: -30)
                .rotationEffect(Angle(degrees: facingDirection - 90))

            if sunAltitude > 0 {
                Circle()
                    .fill(isInSun ? Color.yellow : Color.gray.opacity(0.5))
                    .frame(width: 24, height: 24)
                    .overlay(Circle().stroke(isInSun ? Color.orange : Color.gray, lineWidth: 2))
                    .offset(
                        x: 60 * cos((sunAzimuth - 90) * .pi / 180),
                        y: 60 * sin((sunAzimuth - 90) * .pi / 180)
                    )
            }

            Circle()
                .fill(AppTheme.burgundy)
                .frame(width: 8, height: 8)

            VStack {
                Spacer()
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(AppTheme.burgundy.opacity(0.4))
                            .frame(width: 12, height: 4)
                        Text("Seating")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.subtleText)
                    }
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 8, height: 8)
                        Text("Sun")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.subtleText)
                    }
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 12)
                        Text("Buildings")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.subtleText)
                    }
                }
            }
            .frame(width: 160, height: 160)
        }
        .frame(width: 160, height: 160)
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}
