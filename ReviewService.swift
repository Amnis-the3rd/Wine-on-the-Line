import Foundation
import FirebaseFirestore

struct UserReview: Identifiable, Codable {
    var id: String = UUID().uuidString
    let barName: String
    let authorName: String
    let rating: Int
    let text: String
    let date: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

class ReviewService: ObservableObject {
    static let shared = ReviewService()
    private let db = Firestore.firestore()
    
    @Published var reviews: [UserReview] = []
    
    func fetchReviews(for barName: String) {
        db.collection("reviews")
            .whereField("barName", isEqualTo: barName)
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.reviews = documents.compactMap { doc in
                    try? doc.data(as: UserReview.self)
                }
            }
    }
    
    func addReview(_ review: UserReview) {
        try? db.collection("reviews").document(review.id).setData(from: review)
    }
}
