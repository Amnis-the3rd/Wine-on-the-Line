//
//  OSMBuildingService.swift
//  want-space
//
//  Created by Amna on 2026-04-29.
//
import Foundation
import CoreLocation

struct OSMBuilding {
    let height: Double      // meters
    let distance: Double    // meters from bar
    let direction: Double   // degrees from bar
    
    var angularHeight: Double {
        // Calculate how many degrees above horizon the building appears
        atan2(height, distance) * 180 / .pi
    }
    
    var asShadowObstruction: ShadowObstruction {
        ShadowObstruction(direction: direction, angularHeight: angularHeight)
    }
}

class OSMBuildingService {
    static let shared = OSMBuildingService()
    
    func fetchNearbyBuildings(coordinate: CLLocationCoordinate2D) async -> [ShadowObstruction] {
        let lat = coordinate.latitude
        let lon = coordinate.longitude
        let radius = 50 // meters
        
        // Overpass API query for buildings within radius
        let query = """
        [out:json];
        way["building"](around:\(radius),\(lat),\(lon));
        out center;
        """
        
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://overpass-api.de/api/interpreter?data=\(encoded)") else {
            return []
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONDecoder().decode(OverpassResponse.self, from: data)
            
            var obstructions: [ShadowObstruction] = []
            
            for element in json.elements {
                guard let center = element.center else { continue }
                
                let buildingLoc = CLLocation(latitude: center.lat, longitude: center.lon)
                let barLoc = CLLocation(latitude: lat, longitude: lon)
                let distance = buildingLoc.distance(from: barLoc)
                
                // Get building height - default to 10m if not specified
                let heightString = element.tags?["height"]
                let levelsString = element.tags?["building:levels"]
                let levelsHeight: String? = levelsString.flatMap { levels in
                    guard let l = Double(levels) else { return nil }
                    return String(Int(l * 3.5))
                }
                let height = Double(heightString ?? levelsHeight ?? "10") ?? 10.0
                // Calculate direction from bar to building
                let dLon = center.lon - lon
                let dLat = center.lat - lat
                let direction = atan2(dLon, dLat) * 180 / .pi
                let normalizedDirection = (direction + 360).truncatingRemainder(dividingBy: 360)
                
                let building = OSMBuilding(
                    height: height,
                    distance: distance,
                    direction: normalizedDirection
                )
                
                obstructions.append(building.asShadowObstruction)
            }
            
            return obstructions
        } catch {
            print("OSM fetch error: \(error)")
            return []
        }
    }
}

// MARK: - Overpass Response Models

struct OverpassResponse: Codable {
    let elements: [OverpassElement]
}

struct OverpassElement: Codable {
    let center: OverpassCenter?
    let tags: [String: String]?
}

struct OverpassCenter: Codable {
    let lat: Double
    let lon: Double
}
