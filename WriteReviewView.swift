//
//  WriteReviewView.swift
//  want-space
//
//  Created by Amna on 2026-04-20.
//

import SwiftUI

struct WriteReviewView: View {
    let bar: WineBar
    @State private var authorName = ""
    @State private var reviewText = ""
    @State private var rating = 3
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Reviewing \(bar.name)")
                        .font(.headline)
                        .foregroundStyle(AppTheme.burgundy)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your name")
                            .font(.subheadline.bold())
                        TextField("Enter your name", text: $authorName)
                            .padding()
                            .background(AppTheme.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rating")
                            .font(.subheadline.bold())
                        HStack {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundStyle(AppTheme.gold)
                                    .onTapGesture { rating = star }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your review")
                            .font(.subheadline.bold())
                        TextEditor(text: $reviewText)
                            .frame(height: 120)
                            .padding()
                            .background(AppTheme.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        submitReview()
                    } label: {
                        Text("Submit Review")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(authorName.isEmpty || reviewText.isEmpty ? AppTheme.subtleText : AppTheme.burgundy)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(authorName.isEmpty || reviewText.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Write a Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func submitReview() {
        let review = UserReview(
            barName: bar.name,
            authorName: authorName,
            rating: rating,
            text: reviewText,
            date: Date()
        )
        ReviewService.shared.addReview(review)
        dismiss()
    }
}
