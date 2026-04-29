//
//  SunTrackerTabView.swift
//  want-space
//
//  Created by Amna on 2026-04-29.
//

import SwiftUI

struct SunTrackerTabView: View {
    @StateObject private var promoService = PromoCodeService.shared
    
    var body: some View {
        NavigationStack {
            if promoService.isUnlocked {
                SunTrackerUnlockedView()
            } else {
                SunTrackerPaywallView()
            }
        }
    }
}

// MARK: - Paywall View

struct SunTrackerPaywallView: View {
    @StateObject private var promoService = PromoCodeService.shared
    @State private var promoCode = ""
    @State private var showPromoField = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 12) {
                    Text("☀️")
                        .font(.system(size: 70))
                    Text("Sun Tracker")
                        .font(.largeTitle.bold())
                        .foregroundStyle(AppTheme.burgundy)
                    Text("Find out which bars have sun on their outdoor seating right now and for how long!")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.subtleText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // Preview teaser
                VStack(alignment: .leading, spacing: 12) {
                    Text("What you get:")
                        .font(.headline)
                        .foregroundStyle(AppTheme.burgundy)
                    
                    FeatureRow(icon: "sun.max.fill", color: .orange, text: "Real-time sun position for every bar")
                    FeatureRow(icon: "clock.fill", color: AppTheme.wine, text: "How long sun will stay on outdoor seating")
                    FeatureRow(icon: "safari.fill", color: AppTheme.metroBlue, text: "Visual sun path diagram")
                    FeatureRow(icon: "location.fill", color: AppTheme.metroGreen, text: "All bars in app")
                }
                .padding()
                .background(AppTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
                .padding(.horizontal)
                
                // Pricing
                VStack(spacing: 12) {
                    PricingOption(
                        title: "15 min pass",
                        price: "12 kr",
                        description: "Perfect for a quick check",
                        icon: "timer"
                    )
                    PricingOption(
                        title: "Day pass",
                        price: "45 kr",
                        description: "Full day access",
                        icon: "sun.max"
                    )
                }
                .padding(.horizontal)
                
                // Promo code
                VStack(spacing: 12) {
                    Button {
                        withAnimation { showPromoField.toggle() }
                    } label: {
                        Text("Have a promo code?")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.wine)
                    }
                    
                    if showPromoField {
                        VStack(spacing: 12) {
                            TextField("Enter promo code", text: $promoCode)
                                .textInputAutocapitalization(.characters)
                                .padding()
                                .background(AppTheme.secondaryBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            if let error = promoService.errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                            
                            Button {
                                Task {
                                    await promoService.redeemCode(promoCode)
                                }
                            } label: {
                                if promoService.isLoading {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(AppTheme.burgundy)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                } else {
                                    Text("Redeem Code")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(promoCode.isEmpty ? AppTheme.subtleText : AppTheme.burgundy)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                            .disabled(promoCode.isEmpty || promoService.isLoading)
                        }
                        .padding(.horizontal)
                        .transition(.opacity)
                    }
                }
                
                Spacer()
            }
        }
        .navigationTitle("Sun Tracker")
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Unlocked View

struct SunTrackerUnlockedView: View {
    @StateObject private var promoService = PromoCodeService.shared
    @State private var selectedBar: WineBar? = nil
    
    var sunnyBars: [WineBar] {
        SampleData.wineBars.filter { bar in
            guard bar.hasOutdoorSeating,
                  let direction = bar.outdoorFacingDirection else { return false }
            return SolarCalculator.isInSun(coordinate: bar.coordinate, facingDirection: direction)
        }
    }
    
    var shadyBars: [WineBar] {
        SampleData.wineBars.filter { bar in
            guard bar.hasOutdoorSeating,
                  let direction = bar.outdoorFacingDirection else { return false }
            return !SolarCalculator.isInSun(coordinate: bar.coordinate, facingDirection: direction)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Access status
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(promoService.formatExpiry())
                        .font(.caption)
                        .foregroundStyle(AppTheme.subtleText)
                }
                .padding(.horizontal)
                
                // Sunny bars
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("☀️ In the sun now")
                            .font(.title3.bold())
                            .foregroundStyle(AppTheme.burgundy)
                        Spacer()
                        Text("\(sunnyBars.count) bars")
                            .font(.caption)
                            .foregroundStyle(AppTheme.subtleText)
                    }
                    .padding(.horizontal)
                    
                    if sunnyBars.isEmpty {
                        Text("No bars with outdoor sun right now")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.subtleText)
                            .padding(.horizontal)
                    } else {
                        ForEach(sunnyBars) { bar in
                            SunBarRow(bar: bar)
                                .padding(.horizontal)
                                .onTapGesture { selectedBar = bar }
                        }
                    }
                }
                
                // Shady bars
                VStack(alignment: .leading, spacing: 12) {
                    Text("🌥️ Currently in shade")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.burgundy)
                        .padding(.horizontal)
                    
                    ForEach(shadyBars) { bar in
                        SunBarRow(bar: bar)
                            .padding(.horizontal)
                            .onTapGesture { selectedBar = bar }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Sun Tracker")
        .sheet(item: $selectedBar) { bar in
            WineBarDetailSheet(bar: bar)
        }
    }
}

// MARK: - Sun Bar Row

struct SunBarRow: View {
    let bar: WineBar
    
    var isInSun: Bool {
        guard let direction = bar.outdoorFacingDirection else { return false }
        return SolarCalculator.isInSun(coordinate: bar.coordinate, facingDirection: direction)
    }
    
    var remainingTime: TimeInterval? {
        guard let direction = bar.outdoorFacingDirection else { return nil }
        return SolarCalculator.sunRemainingTime(coordinate: bar.coordinate, facingDirection: direction)
    }
    
    var body: some View {
        HStack(spacing: 14) {
            Text(isInSun ? "☀️" : "🌥️")
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(isInSun ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(bar.name)
                    .font(.headline)
                Text(bar.nearestStation)
                    .font(.caption)
                    .foregroundStyle(AppTheme.subtleText)
                if let remaining = remainingTime {
                    Text(SolarCalculator.formatRemainingTime(remaining))
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.subtleText)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Pricing Option

struct PricingOption: View {
    let title: String
    let price: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(AppTheme.wine)
                .frame(width: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(AppTheme.subtleText)
            }
            Spacer()
            Text(price)
                .font(.title3.bold())
                .foregroundStyle(AppTheme.burgundy)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}
