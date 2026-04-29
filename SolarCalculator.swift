//
//  SolarCalculator.swift
//  want-space
//
//  Created by Amna on 2026-04-29.
//

import Foundation
import CoreLocation

struct SolarPosition {
    let altitude: Double  // degrees above horizon
    let azimuth: Double   // degrees clockwise from North
    let isAboveHorizon: Bool
}

class SolarCalculator {
    
    // Calculate sun position for a given location and time
    static func sunPosition(at coordinate: CLLocationCoordinate2D, date: Date = Date()) -> SolarPosition {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .timeZone], from: date)
        
        let lat = coordinate.latitude * .pi / 180
        let lon = coordinate.longitude
        
        // Day of year
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        
        // Solar declination
        let declination = -23.45 * cos(2 * .pi / 365 * Double(dayOfYear + 10)) * .pi / 180
        
        // Time correction
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT()) / 3600
        let solarNoon = 12.0 - (lon / 15.0) + timeZoneOffset
        
        let hour = Double(components.hour ?? 12)
        let minute = Double(components.minute ?? 0)
        let currentHour = hour + minute / 60.0
        
        let hourAngle = (currentHour - solarNoon) * 15.0 * .pi / 180
        
        // Solar altitude
        let sinAltitude = sin(lat) * sin(declination) + cos(lat) * cos(declination) * cos(hourAngle)
        let altitude = asin(sinAltitude) * 180 / .pi
        
        // Solar azimuth
        let cosAzimuth = (sin(declination) - sin(lat) * sinAltitude) / (cos(lat) * cos(asin(sinAltitude)))
        var azimuth = acos(max(-1, min(1, cosAzimuth))) * 180 / .pi
        if hourAngle > 0 { azimuth = 360 - azimuth }
        
        return SolarPosition(
            altitude: altitude,
            azimuth: azimuth,
            isAboveHorizon: altitude > 0
        )
    }
    
    // Check if outdoor seating is in sun
    static func isInSun(
        coordinate: CLLocationCoordinate2D,
        facingDirection: Double,
        obstructions: [ShadowObstruction] = [],
        date: Date = Date()
    ) -> Bool {
        let position = sunPosition(at: coordinate, date: date)
        guard position.isAboveHorizon else { return false }
        
        // Check if sun direction is within seating's view angle
        let angleDiff = abs(position.azimuth - facingDirection)
        let normalizedDiff = min(angleDiff, 360 - angleDiff)
        guard normalizedDiff < 90 else { return false }
        
        // Check if any obstruction blocks the sun
        for obstruction in obstructions {
            let obsDiff = abs(position.azimuth - obstruction.direction)
            let normalizedObsDiff = min(obsDiff, 360 - obsDiff)
            
            // If sun is within 30 degrees of obstruction direction
            // AND sun altitude is below obstruction angular height
            if normalizedObsDiff < 30 && position.altitude < obstruction.angularHeight {
                return false
            }
        }
        
        return true
    }

    static func sunRemainingTime(
        coordinate: CLLocationCoordinate2D,
        facingDirection: Double,
        obstructions: [ShadowObstruction] = []
    ) -> TimeInterval? {
        let now = Date()
        guard isInSun(
            coordinate: coordinate,
            facingDirection: facingDirection,
            obstructions: obstructions,
            date: now
        ) else { return nil }
        
        var checkTime = now
        let interval: TimeInterval = 300

        for _ in 0..<48 {
            checkTime += interval
            if !isInSun(
                coordinate: coordinate,
                facingDirection: facingDirection,
                obstructions: obstructions,
                date: checkTime
            ) {
                return checkTime.timeIntervalSince(now)
            }
        }
        return 4 * 3600
    }
    // Format remaining time nicely
    static func formatRemainingTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m of sun remaining"
        }
        return "\(minutes) minutes of sun remaining"
    }
}
