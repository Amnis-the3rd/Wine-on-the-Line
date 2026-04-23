//
//  SearchResultRow.swift
//  want-space
//
//  Created by Amna on 2026-04-23.
//
import SwiftUI
import CoreLocation

struct SearchResultRow: View {
    let bar: WineBar
    let userLocation: CLLocationCoordinate2D?
    @State private var showDetail = false
    
    var distance: String {
        guard let userLocation = userLocation else { return "" }
        let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let barLoc = CLLocation(latitude: bar.coordinate.latitude, longitude: bar.coordinate.longitude)
        let meters = userLoc.distance(from: barLoc)
        if meters < 1000 {
            return String(format: "%.0fm away", meters)
        } else {
            return String(format: "%.1fkm away", meters / 1000)
        }
    }
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.burgundy.opacity(0.12))
                    .frame(width: 50, height: 50)
                Image(systemName: bar.imageSystemName)
                    .foregroundStyle(AppTheme.wine)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(bar.name)
                    .font(.headline)
                Text(bar.subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.subtleText)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Label("\(bar.rating, specifier: "%.1f")", systemImage: "star.fill")
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.gold)
                    Text("·")
                        .foregroundStyle(AppTheme.subtleText)
                    Text(bar.priceLevelText)
                        .font(.caption)
                        .foregroundStyle(AppTheme.subtleText)
                    if !distance.isEmpty {
                        Text("·")
                            .foregroundStyle(AppTheme.subtleText)
                        Text(distance)
                            .font(.caption)
                            .foregroundStyle(AppTheme.subtleText)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.subtleText)
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            WineBarDetailSheet(bar: bar)
        }
    }
}
