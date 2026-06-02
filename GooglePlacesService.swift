//
//  GooglePlacesService.swift
//  
//
//  Created by Amna on 2026-04-09.
//

import Foundation

class GooglePlacesService {
    static let shared = GooglePlacesService()
    private let apiKey = "AIzaSyABbUd716mll2X4DG4ED7epB0K_zlOsAd0"  // new key restricted one: AIzaSyDNPSHsdvLpu6yA-CP_2OYFlasVtL38s1Y
    
    func findPlaceID(for barName: String) async throws -> String? {
        let query = "\(barName) Stockholm wine bar"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=\(query)&inputtype=textquery&fields=place_id&key=\(apiKey)"
        
        print("🔍 Searching Places for: \(barName)")
        
        guard let url = URL(string: urlString) else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONDecoder().decode(FindPlaceResponse.self, from: data)
        
        print("📍 Place ID found: \(json.candidates.first?.place_id ?? "none")")
        return json.candidates.first?.place_id
    }
    
    func fetchDetails(placeID: String) async throws -> PlaceDetails? {
        let fields = "name,rating,price_level,opening_hours,reviews,user_ratings_total"
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&fields=\(fields)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONDecoder().decode(PlaceDetailsResponse.self, from: data)
        return json.result
    }
}

// MARK: - Response Models

struct FindPlaceResponse: Codable {
    let candidates: [Candidate]
    struct Candidate: Codable {
        let place_id: String
    }
}

struct PlaceDetailsResponse: Codable {
    let result: PlaceDetails
}

struct PlaceDetails: Codable {
    let name: String?
    let rating: Double?
    let price_level: Int?
    let user_ratings_total: Int?
    let opening_hours: OpeningHours?
    let reviews: [GoogleReview]?
}

struct OpeningHours: Codable {
    let open_now: Bool?
    let weekday_text: [String]?
}

struct GoogleReview: Codable, Identifiable {
    var id: String { author_name }
    let author_name: String
    let rating: Int
    let text: String
    let relative_time_description: String
}

