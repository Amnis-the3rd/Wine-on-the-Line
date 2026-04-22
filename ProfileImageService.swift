//
//  ProfileImageService.swift
//  want-space
//
//  Created by Amna on 2026-04-22.
//

import Foundation
import FirebaseStorage
import UIKit

class ProfileImageService {
    static let shared = ProfileImageService()
    
    func uploadProfileImage(_ image: UIImage, userID: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw URLError(.badServerResponse)
        }
        
        let ref = Storage.storage().reference().child("profile_pictures/\(userID).jpg")
        _ = try await ref.putDataAsync(imageData)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
    
    func fetchImage(from urlString: String) async throws -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        return UIImage(data: data)
    }
}
