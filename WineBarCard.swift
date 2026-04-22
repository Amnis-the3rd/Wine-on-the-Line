
import SwiftUI

struct WineBarCard: View {
    let bar: WineBar
    @ObservedObject private var favorites = FavoritesManager.shared
    @State private var showDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerRow
            Text(bar.subtitle)
                .font(.caption)
                .foregroundStyle(AppTheme.subtleText)
                .lineLimit(2)
            tagsRow
            bottomRow
        }
        .padding(14)
        .frame(width: 200)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            WineBarDetailSheet(bar: bar)

                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)

        }
    }

    @ViewBuilder
    private var headerRow: some View {
        HStack(spacing: 8) {
            Image(systemName: bar.imageSystemName)
                .foregroundStyle(AppTheme.wine)
                .font(.title3)
            Text(bar.name)
                .font(.subheadline.bold())
                .lineLimit(1)
            Spacer()
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    favorites.toggle(bar)
                }
            } label: {
                Image(systemName: favorites.isFavorite(bar) ? "heart.fill" : "heart")
                    .foregroundStyle(favorites.isFavorite(bar) ? AppTheme.rosé : AppTheme.subtleText)
                    .font(.subheadline)
                    .scaleEffect(favorites.isFavorite(bar) ? 1.15 : 1.0)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var tagsRow: some View {
        HStack(spacing: 6) {
            ForEach(bar.tags.prefix(2), id: \.self) { tag in
                Text(tag)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.champagne)
                    .foregroundStyle(AppTheme.burgundy)
                    .clipShape(Capsule())
            }
        }
    }

    @ViewBuilder
    private var bottomRow: some View {
        HStack {
            Label("\(bar.rating, specifier: "%.1f")", systemImage: "star.fill")
                .font(.caption.bold())
                .foregroundStyle(AppTheme.gold)
            Spacer()
            Text(bar.priceLevelText)
                .font(.caption)
                .foregroundStyle(AppTheme.subtleText)
        }
    }
}

#Preview {
    WineBarCard(bar: SampleData.wineBars[0])
        .padding()
}
