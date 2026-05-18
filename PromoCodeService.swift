//
//  PromoCodeService.swift
//  want-space
//
//  Created by Amna on 2026-04-29.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

enum UnlockDuration {
    case minutes(Int)
    case hours(Int)
    case permanent
}

struct PromoCode: Identifiable, Codable {
    @DocumentID var id: String?
    let code: String
    let duration: String
    var usedBy: [String]
    let maxUses: Int
    
    var isValid: Bool {
        usedBy.count < maxUses
    }
}

class PromoCodeService: ObservableObject {
    static let shared = PromoCodeService()
    private let db = Firestore.firestore()
    
    @Published var isUnlocked = false
    @Published var unlockExpiry: Date? = nil
    @Published var errorMessage: String? = nil
    @Published var isLoading = false
    
    private let unlockedKey = "sunTrackerUnlocked"
    private let expiryKey = "sunTrackerExpiry"
    
    init() {
        checkLocalUnlock()
    }
    
    private func checkLocalUnlock() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: unlockedKey) {
            if let expiry = defaults.object(forKey: expiryKey) as? Date {
                if expiry > Date() {
                    isUnlocked = true
                    unlockExpiry = expiry
                } else {
                    isUnlocked = false
                    unlockExpiry = nil
                }
            } else {
                // Permanent unlock
                isUnlocked = true
                unlockExpiry = nil
            }
        }
    }
    
    func redeemCode(_ code: String) async {
        await MainActor.run { isLoading = true }
        
        let upperCode = code.uppercased().trimmingCharacters(in: .whitespaces)
        
        do {
            let snapshot = try await db.collection("promoCodes").getDocuments()
            
            let filtered = snapshot.documents.filter {
                ($0.data()["code"] as? String) == upperCode
            }
            
            guard let doc = filtered.first,
                  let promo = try? doc.data(as: PromoCode.self) else {
                await MainActor.run {
                    errorMessage = "Invalid code. Please try again."
                    isLoading = false
                }
                return
            }
            
            guard promo.isValid else {
                await MainActor.run {
                    errorMessage = "This code has already been used."
                    isLoading = false
                }
                return
            }
            
            let uid = Auth.auth().currentUser?.uid ?? "anonymous"
            
            guard !promo.usedBy.contains(uid) else {
                await MainActor.run {
                    errorMessage = "You've already used this code."
                    isLoading = false
                }
                return
            }
            
            try await db.collection("promoCodes").document(doc.documentID).updateData([
                "usedBy": FieldValue.arrayUnion([uid])
            ])
            
            await MainActor.run {
                applyUnlock(duration: promo.duration)
                isLoading = false
                errorMessage = nil
            }
            
        } catch {
            await MainActor.run {
                errorMessage = "Something went wrong. Please try again."
                isLoading = false
            }
        }
    
    }
    private func applyUnlock(duration: String) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: unlockedKey)
        
        switch duration {
        case "15min":
            let expiry = Date().addingTimeInterval(15 * 60)
            defaults.set(expiry, forKey: expiryKey)
            unlockExpiry = expiry
        case "day":
            let expiry = Calendar.current.startOfDay(for: Date()).addingTimeInterval(24 * 3600)
            defaults.set(expiry, forKey: expiryKey)
            unlockExpiry = expiry
        case "permanent":
            defaults.removeObject(forKey: expiryKey)
            unlockExpiry = nil
        default:
            break
        }
        isUnlocked = true
    }
    
    func formatExpiry() -> String {
        guard let expiry = unlockExpiry else { return "Permanent access" }
        let remaining = expiry.timeIntervalSince(Date())
        if remaining < 3600 {
            let minutes = Int(remaining / 60)
            return "\(minutes) minutes remaining"
        } else {
            let hours = Int(remaining / 3600)
            return "Valid for \(hours) more hours"
        }
    }
}
