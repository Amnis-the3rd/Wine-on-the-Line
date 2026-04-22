import Foundation
import Combine

// MARK: - Favorites Manager

final class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()

    @Published private(set) var favoriteIDs: Set<String> = []

    private let key = "wine_on_the_line_favorites"

    private init() {
        load()
    }

    func isFavorite(_ bar: WineBar) -> Bool {
        favoriteIDs.contains(bar.id.uuidString)
    }

    func toggle(_ bar: WineBar) {
        let idStr = bar.id.uuidString
        if favoriteIDs.contains(idStr) {
            favoriteIDs.remove(idStr)
        } else {
            favoriteIDs.insert(idStr)
        }
        save()
    }

    func favorites(from bars: [WineBar]) -> [WineBar] {
        bars.filter { favoriteIDs.contains($0.id.uuidString) }
    }

    private func save() {
        UserDefaults.standard.set(Array(favoriteIDs), forKey: key)
    }

    private func load() {
        if let saved = UserDefaults.standard.array(forKey: key) as? [String] {
            favoriteIDs = Set(saved)
        }
    }
}
