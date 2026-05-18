//
//  WeatherService.swift
//  want-space
//
//  Created by Amna on 2026-05-04.
//

import Foundation
import CoreLocation

struct CurrentWeather {
    let cloudCover: Double      // 0-100%
    let directRadiation: Double // W/m²
    
    var isSunny: Bool {
        cloudCover < 30 && directRadiation > 100
    }
    
    var isCloudy: Bool {
        cloudCover >= 30
    }
    
    var weatherDescription: String {
        if cloudCover < 20 { return "Clear sky" }
        if cloudCover < 50 { return "Partly cloudy" }
        if cloudCover < 80 { return "Mostly cloudy" }
        return "Overcast"
    }
}

class WeatherService: ObservableObject {
    static let shared = WeatherService()
    
    @Published var currentWeather: CurrentWeather? = nil
    @Published var isLoading = false
    
    func fetchWeather(for coordinate: CLLocationCoordinate2D) async {
        await MainActor.run { isLoading = true }
        
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(coordinate.latitude)&longitude=\(coordinate.longitude)&current=cloud_cover,direct_radiation&timezone=Europe%2FStockholm"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
            
            await MainActor.run {
                currentWeather = CurrentWeather(
                    cloudCover: json.current.cloud_cover,
                    directRadiation: json.current.direct_radiation
                )
                isLoading = false
            }
        } catch {
            print("Weather fetch error: \(error)")
            await MainActor.run { isLoading = false }
        }
    }
}

// MARK: - Response Models

struct OpenMeteoResponse: Codable {
    let current: OpenMeteoCurrent
}

struct OpenMeteoCurrent: Codable {
    let cloud_cover: Double
    let direct_radiation: Double
}
