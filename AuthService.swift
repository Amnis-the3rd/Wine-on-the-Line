//
//  AuthService.swift
//  want-space
//
//  Created by Amna on 2026-04-22.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import Firebase

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: User? = nil
    @Published var userProfile: UserProfile? = nil
    
    private init() {
        currentUser = Auth.auth().currentUser
        if let user = currentUser {
            fetchProfile(for: user.uid)
        }
        _ = Auth.auth().addStateDidChangeListener { _, user in
            self.currentUser = user
            if let user = user {
                self.fetchProfile(for: user.uid)
            } else {
                self.userProfile = nil
            }
        }
    }
    
    func signInWithGoogle(presenting viewController: UIViewController) async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        let user = result.user
        guard let idToken = user.idToken?.tokenString else { return }
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: user.accessToken.tokenString
        )
        try await Auth.auth().signIn(with: credential)
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
    }
    
    func saveProfile(_ profile: UserProfile) {
        guard let uid = currentUser?.uid else { return }
        let db = Firestore.firestore()
        try? db.collection("users").document(uid).setData(from: profile)
        self.userProfile = profile
    }
    
    func fetchProfile(for uid: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, _ in
            self.userProfile = try? snapshot?.data(as: UserProfile.self)
        }
    }
}

struct UserProfile: Codable, Identifiable {
    var id: String = UUID().uuidString
    var username: String
    var profileImageURL: String?
}
