//
//  FriendsService.swift
//  want-space
//
//  Created by Amna on 2026-04-28.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct FriendRequest: Identifiable, Codable {
    var id: String = UUID().uuidString
    let fromUID: String
    let fromUsername: String
    let toUID: String
    let status: String // "pending", "accepted", "declined"
    let date: Date
}

struct FriendProfile: Identifiable {
    let id: String
    let username: String
    let profileImageURL: String?
    var favoriteBarNames: [String] = []
}

class FriendsService: ObservableObject {
    static let shared = FriendsService()
    private let db = Firestore.firestore()

    @Published var friends: [FriendProfile] = []
    @Published var pendingRequests: [FriendRequest] = []
    @Published var searchResults: [UserProfile] = []

    func searchUsers(by username: String) {
        guard !username.isEmpty else {
            searchResults = []
            return
        }
        db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: username)
            .whereField("username", isLessThan: username + "z")
            .getDocuments { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.searchResults = docs.compactMap { try? $0.data(as: UserProfile.self) }
            }
    }

    func sendFriendRequest(to user: UserProfile) {
        guard let currentUID = Auth.auth().currentUser?.uid,
              let currentUsername = AuthService.shared.userProfile?.username,
              let toUID = user.id as String? else { return }

        let request = FriendRequest(
            fromUID: currentUID,
            fromUsername: currentUsername,
            toUID: toUID,
            status: "pending",
            date: Date()
        )
        try? db.collection("friendRequests").document(request.id).setData(from: request)
    }

    func fetchPendingRequests() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("friendRequests")
            .whereField("toUID", isEqualTo: uid)
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                self.pendingRequests = docs.compactMap { try? $0.data(as: FriendRequest.self) }
            }
    }

    func acceptRequest(_ request: FriendRequest) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("friendRequests").document(request.id).updateData(["status": "accepted"])
        db.collection("users").document(uid).updateData([
            "friends": FieldValue.arrayUnion([request.fromUID])
        ])
        db.collection("users").document(request.fromUID).updateData([
            "friends": FieldValue.arrayUnion([uid])
        ])
        fetchFriends()
    }

    func declineRequest(_ request: FriendRequest) {
        db.collection("friendRequests").document(request.id).updateData(["status": "declined"])
    }

    func fetchFriends() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).getDocument { snapshot, _ in
            guard let friendUIDs = snapshot?.data()?["friends"] as? [String] else { return }
            self.friends = []
            for friendUID in friendUIDs {
                self.db.collection("users").document(friendUID).getDocument { snap, _ in
                    guard let profile = try? snap?.data(as: UserProfile.self) else { return }
                    let friendProfile = FriendProfile(
                        id: friendUID,
                        username: profile.username,
                        profileImageURL: profile.profileImageURL
                    )
                    DispatchQueue.main.async {
                        self.friends.append(friendProfile)
                    }
                }
            }
        }
    }

    func generateInviteLink() -> String {
        guard let uid = Auth.auth().currentUser?.uid else { return "" }
        return "wineontheline://addfriend?uid=\(uid)"
    }
}
