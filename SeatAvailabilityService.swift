//
//  SeatAvailabilityService.swift
//  want-space
//
//  Created by Amna on 2026-04-29.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct SeatReport: Identifiable, Codable {
    var id: String = UUID().uuidString
    let barName: String
    let hasSeats: Bool
    let reporterUID: String
    let reporterName: String
    let timestamp: Date
    
    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > 1800 // 30 minutes
    }
    
    var timeAgoText: String {
        let minutes = Int(Date().timeIntervalSince(timestamp) / 60)
        if minutes < 1 { return "Just now" }
        if minutes == 1 { return "1 minute ago" }
        return "\(minutes) minutes ago"
    }
}

class SeatAvailabilityService: ObservableObject {
    static let shared = SeatAvailabilityService()
    private let db = Firestore.firestore()
    
    @Published var latestReport: SeatReport? = nil
    
    func fetchLatestReport(for barName: String) {
        db.collection("seatReports")
            .whereField("barName", isEqualTo: barName)
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .addSnapshotListener { snapshot, _ in
                guard let doc = snapshot?.documents.first,
                      let report = try? doc.data(as: SeatReport.self) else {
                    self.latestReport = nil
                    return
                }
                self.latestReport = report.isExpired ? nil : report
            }
    }
    
    func reportSeats(for barName: String, hasSeats: Bool) {
        guard let uid = Auth.auth().currentUser?.uid,
              let username = AuthService.shared.userProfile?.username else { return }
        
        let report = SeatReport(
            barName: barName,
            hasSeats: hasSeats,
            reporterUID: uid,
            reporterName: username,
            timestamp: Date()
        )
        try? db.collection("seatReports").document(report.id).setData(from: report)
        self.latestReport = report
    }
}
