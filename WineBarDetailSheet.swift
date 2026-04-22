//
//  WineBarDetailSheet.swift
//  
//
//  Created by Amna on 2026-04-14.
//

import SwiftUI

struct WineBarDetailSheet: View {
    let bar: WineBar
    @State private var placeDetails: PlaceDetails?
    @State private var isLoading = true
    @State private var showReviewForm = false
    @Environment(\.dismiss) private var dismiss
    @StateObject private var reviewService = ReviewService()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                if isLoading {
                    ProgressView("Loading details...")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else {
                    if let details = placeDetails {
                        openingHoursSection(details)
                        googleReviewsSection(details)
                    } else {
                        Text("Couldn't load details.")
                            .foregroundStyle(AppTheme.subtleText)
                            .padding()
                    }
                    userReviewsSection
                }
            }
            .padding()
        }
        .task {
            await loadDetails()
            reviewService.fetchReviews(for: bar.name)
        }
        .sheet(isPresented: $showReviewForm) {
            WriteReviewView(bar: bar)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(bar.name)
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.burgundy)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.subtleText)
                }
            }
            Text(bar.subtitle)
                .font(.subheadline)
                .foregroundStyle(AppTheme.subtleText)
            HStack(spacing: 12) {
                Label("\(bar.rating, specifier: "%.1f")", systemImage: "star.fill")
                    .foregroundStyle(AppTheme.gold)
                    .font(.subheadline.bold())
                Label(bar.nearestStation, systemImage: "tram.fill")
                    .foregroundStyle(AppTheme.subtleText)
                    .font(.subheadline)
                Text(bar.priceLevelText)
                    .foregroundStyle(AppTheme.subtleText)
                    .font(.subheadline)
            }
        }
    }

    // MARK: - Opening Hours

    private func openingHoursSection(_ details: PlaceDetails) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Opening Hours")
                .font(.headline)
                .foregroundStyle(AppTheme.burgundy)
            if let isOpen = details.opening_hours?.open_now {
                HStack {
                    Circle()
                        .fill(isOpen ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                    Text(isOpen ? "Open now" : "Closed now")
                        .font(.subheadline.bold())
                }
            }
            if let hours = details.opening_hours?.weekday_text {
                ForEach(hours, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundStyle(AppTheme.subtleText)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }

    // MARK: - Google Reviews

    private func googleReviewsSection(_ details: PlaceDetails) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Google Reviews")
                    .font(.headline)
                    .foregroundStyle(AppTheme.burgundy)
                Spacer()
                if let total = details.user_ratings_total {
                    Text("\(total) reviews")
                        .font(.caption)
                        .foregroundStyle(AppTheme.subtleText)
                }
            }
            if let reviews = details.reviews {
                ForEach(reviews) { review in
                    ReviewRow(review: review)
                }
            }
        }
    }

    // MARK: - User Reviews

    private var userReviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Reviews from Friends")
                    .font(.headline)
                    .foregroundStyle(AppTheme.burgundy)
                Spacer()
                Button {
                    showReviewForm = true
                } label: {
                    Label("Write Review", systemImage: "square.and.pencil")
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.wine)
                }
            }
            if reviewService.reviews.isEmpty {
                Text("No reviews yet — be the first!")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.subtleText)
                    .padding()
            } else {
                ForEach(reviewService.reviews) { review in
                    UserReviewRow(review: review)
                }
            }
        }
    }

    // MARK: - Load Data

    private func loadDetails() async {
        do {
            if let placeID = try await GooglePlacesService.shared.findPlaceID(for: bar.name) {
                placeDetails = try await GooglePlacesService.shared.fetchDetails(placeID: placeID)
            }
        } catch {
            print("Error loading place details: \(error)")
        }
        isLoading = false
    }
}

// MARK: - Google Review Row

struct ReviewRow: View {
    let review: GoogleReview

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(review.author_name)
                    .font(.subheadline.bold())
                Spacer()
                HStack(spacing: 2) {
                    ForEach(0..<review.rating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.gold)
                    }
                }
            }
            Text(review.text)
                .font(.caption)
                .foregroundStyle(AppTheme.subtleText)
                .lineLimit(3)
            Text(review.relative_time_description)
                .font(.caption2)
                .foregroundStyle(AppTheme.subtleText.opacity(0.7))
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}

// MARK: - User Review Row

struct UserReviewRow: View {
    let review: UserReview

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(review.authorName)
                    .font(.subheadline.bold())
                Spacer()
                HStack(spacing: 2) {
                    ForEach(0..<review.rating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.gold)
                    }
                }
            }
            Text(review.text)
                .font(.caption)
                .foregroundStyle(AppTheme.subtleText)
            Text(review.formattedDate)
                .font(.caption2)
                .foregroundStyle(AppTheme.subtleText.opacity(0.7))
        }
        .padding()
        .background(AppTheme.champagne.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}
