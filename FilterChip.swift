//
//  FilterChip.swift
//  want-space
//
//  Created by Amna on 2026-04-28.
//

import SwiftUI

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.bold())
                Text(title)
                    .font(.caption.bold())
            }
            .foregroundStyle(isSelected ? .white : AppTheme.burgundy)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? AppTheme.burgundy : AppTheme.champagne)
            .clipShape(Capsule())
        }
    }
}
