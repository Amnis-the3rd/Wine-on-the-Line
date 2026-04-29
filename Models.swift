import Foundation
import CoreLocation
import MapKit

// MARK: - Metro Line

enum MetroLine: String, CaseIterable, Identifiable {
    case green = "Green"
    case red = "Red"
    case blue = "Blue"

    var id: String { rawValue }
}

// MARK: - Metro Station

struct MetroStation: Identifiable {
    let id = UUID()
    let name: String
    let line: MetroLine
    let coordinate: CLLocationCoordinate2D
}

// MARK:
struct ShadowObstruction: Codable {
    let direction: Double    // degrees from North where obstruction is
    let angularHeight: Double // how high the obstruction appears in degrees
    // A 20m building 10m away = ~63 degrees angular height
    // A 20m building 50m away = ~22 degrees angular height
}

// MARK: - Wine Bar

struct WineBar: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let rating: Double
    let priceLevel: Int // 1-3
    let imageSystemName: String
    let nearestStation: String
    let coordinate: CLLocationCoordinate2D
    let tags: [String]
    let hasOutdoorSeating: Bool
    let outdoorFacingDirection: Double?  // degrees: 0=North, 90=East, 180=South, 270=West
    let shadowObstructions: [ShadowObstruction]
    
    var priceLevelText: String {
        switch priceLevel {
        case 1: return "Under 100kr"
        case 2: return "100–200kr"
        case 3: return "200kr+"
        default: return ""
        }
    }
}

// MARK: - Sample Data

enum SampleData {
    static let stations: [MetroStation] = [
        MetroStation(name: "T-Centralen", line: .blue, coordinate: CLLocationCoordinate2D(latitude: 59.3313, longitude: 18.0597)),
        MetroStation(name: "Gamla stan", line: .green, coordinate: CLLocationCoordinate2D(latitude: 59.3233, longitude: 18.0675)),
        MetroStation(name: "Slussen", line: .green, coordinate: CLLocationCoordinate2D(latitude: 59.3193, longitude: 18.0720)),
        MetroStation(name: "Östermalmstorg", line: .red, coordinate: CLLocationCoordinate2D(latitude: 59.3350, longitude: 18.0730)),
        MetroStation(name: "Mariatorget", line: .red, coordinate: CLLocationCoordinate2D(latitude: 59.3170, longitude: 18.0640)),
        MetroStation(name: "Medborgarplatsen", line: .green, coordinate: CLLocationCoordinate2D(latitude: 59.3147, longitude: 18.0735)),
        MetroStation(name: "Hötorget", line: .green, coordinate: CLLocationCoordinate2D(latitude: 59.3355, longitude: 18.0630)),
        MetroStation(name: "Rådmansgatan", line: .green, coordinate: CLLocationCoordinate2D(latitude: 59.3415, longitude: 18.0580)),
        MetroStation(name: "Zinkensdamm", line: .red, coordinate: CLLocationCoordinate2D(latitude: 59.3175, longitude: 18.0500)),
        MetroStation(name: "Hornstull", line: .red, coordinate: CLLocationCoordinate2D(latitude: 59.3160, longitude: 18.0340)),
        MetroStation(name: "Kungsträdgården", line: .blue, coordinate: CLLocationCoordinate2D(latitude: 59.3310, longitude: 18.0720)),

        MetroStation(name: "Skanstull", line: .green, coordinate: CLLocationCoordinate2D(latitude: 59.3075, longitude: 18.0756)),

        // Corrected
        MetroStation(name: "Tekniska högskolan", line: .red, coordinate: CLLocationCoordinate2D(latitude: 59.3457, longitude: 18.0719)),

        MetroStation(name: "Rådhuset", line: .blue, coordinate: CLLocationCoordinate2D(latitude: 59.3318, longitude: 18.0505)),
        MetroStation(name: "Fridhemsplan", line: .blue, coordinate: CLLocationCoordinate2D(latitude: 59.3318, longitude: 18.0390)),
        MetroStation(name: "S:t Eriksplan", line: .green, coordinate: CLLocationCoordinate2D(latitude: 59.3387, longitude: 18.0448)),
        MetroStation(name: "Thorildsplan", line: .blue, coordinate: CLLocationCoordinate2D(latitude: 59.3318, longitude: 18.0217)),

        // Corrected
        MetroStation(name: "Kristineberg", line: .green, coordinate: CLLocationCoordinate2D(latitude: 59.3329, longitude: 18.0047)),

        MetroStation(name: "Stadshagen", line: .blue, coordinate: CLLocationCoordinate2D(latitude: 59.3340, longitude: 18.0290)),
        MetroStation(name: "Odenplan", line: .green, coordinate: CLLocationCoordinate2D(latitude: 59.3427, longitude: 18.0497)),
        MetroStation(name: "Karlaplan", line: .red, coordinate: CLLocationCoordinate2D(latitude: 59.3370, longitude: 18.0890)),
        MetroStation(name: "Gärdet", line: .red, coordinate: CLLocationCoordinate2D(latitude: 59.3370, longitude: 18.1020)),
        MetroStation(name: "Ropsten", line: .red, coordinate: CLLocationCoordinate2D(latitude: 59.3547, longitude: 18.1033)),

        // Corrected
        MetroStation(name: "Stadion", line: .red, coordinate: CLLocationCoordinate2D(latitude: 59.3429, longitude: 18.0817)),
    ]

    static let wineBars: [WineBar] = [
        WineBar(
            name: "Folii",
            subtitle: "Natural wine & small plates on Södermalm",
            rating: 4.6,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Skanstull",
            coordinate: CLLocationCoordinate2D(latitude: 59.3140, longitude: 18.0904),
            tags: ["Natural", "Cozy"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Babette",
            subtitle: "Relaxed neighbourhood wine & food spot",
            rating: 4.3,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Tekniska högskolan",
            coordinate: CLLocationCoordinate2D(latitude: 59.3449, longitude: 18.0616),
            tags: ["Casual", "Local"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Tyge & Sessil",
            subtitle: "Natural wines & small bites on Östermalm",
            rating: 4.5,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Östermalmstorg",
            coordinate: CLLocationCoordinate2D(latitude: 59.3371, longitude: 18.0758),
            tags: ["Natural", "Curated"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Corvina Enoteca",
            subtitle: "Italian wines & antipasti in Gamla stan",
            rating: 4.6,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Gamla stan",
            coordinate: CLLocationCoordinate2D(latitude: 59.3231, longitude: 18.0712),
            tags: ["Italian", "Classic"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Hornstulls Bodega",
            subtitle: "Rustic natural wine bar at Hornstull",
            rating: 4.5,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Hornstull",
            coordinate: CLLocationCoordinate2D(latitude: 59.3162, longitude: 18.0348),
            tags: ["Natural", "Rustic"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Himlen",
            subtitle: "Skyline views & premium pours",
            rating: 4.0,
            priceLevel: 3,
            imageSystemName: "wineglass.fill",
            nearestStation: "Medborgarplatsen",
            coordinate: CLLocationCoordinate2D(latitude: 59.3119, longitude: 18.0740),
            tags: ["Views", "Premium"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Ring Katarina",
            subtitle: "Natural wine & small plates on Södermalm",
            rating: 4.8,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Skanstull",
            coordinate: CLLocationCoordinate2D(latitude: 59.3099, longitude: 18.0850),
            tags: ["Natural", "Cozy"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Alba",
            subtitle: "Natural wine bar in SoFo",
            rating: 4.1,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Medborgarplatsen",
            coordinate: CLLocationCoordinate2D(latitude: 59.3124, longitude: 18.0814),
            tags: ["Natural", "SoFo"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Hommage",
            subtitle: "French-inspired wine & food in Södermalm",
            rating: 4.3,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Zinkensdamm",
            coordinate: CLLocationCoordinate2D(latitude: 59.3174, longitude: 18.0560),
            tags: ["French", "Cozy"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Ambar",
            subtitle: "Japanese & biodynamic wines on Kungsholmen",
            rating: 4.7,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Stadshagen",
            coordinate: CLLocationCoordinate2D(latitude: 59.3416, longitude: 18.0322),
            tags: ["Biodynamic", "Japanese"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),
        WineBar(
            name: "Bar Ingrid",
            subtitle: "Cozy wine bar near Hötorget",
            rating: 4.7,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Hötorget",
            coordinate: CLLocationCoordinate2D(latitude: 59.3363, longitude: 18.0614),
            tags: ["Cozy", "Natural"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Bar Arsenalen",
            subtitle: "Wine-inspired tasting menu near Kungsträdgården",
            rating: 4.8,
            priceLevel: 3,
            imageSystemName: "wineglass.fill",
            nearestStation: "Kungsträdgården",
            coordinate: CLLocationCoordinate2D(latitude: 59.3316, longitude: 18.0751),
            tags: ["Tasting", "Upscale"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Nofo Vinbar",
            subtitle: "Hotel wine bar in SoFo",
            rating: 4.5,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Medborgarplatsen",
            coordinate: CLLocationCoordinate2D(latitude: 59.3158, longitude: 18.0787),
            tags: ["Cozy", "Hotel"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Bar à Vins",
            subtitle: "Authentic French wine bar on Östermalm",
            rating: 4.6,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Karlaplan",
            coordinate: CLLocationCoordinate2D(latitude: 59.3368, longitude: 18.0910),
            tags: ["French", "Classic"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Bar Ninja",
            subtitle: "Natural wine bar on Södermalm",
            rating: 4.6,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Skanstull",
            coordinate: CLLocationCoordinate2D(latitude: 59.3116, longitude: 18.0798),
            tags: ["Natural", "Casual"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Combo Vinbaren",
            subtitle: "Fine wine by the glass on Odenplan",
            rating: 4.4,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Odenplan",
            coordinate: CLLocationCoordinate2D(latitude: 59.3439, longitude: 18.0545),
            tags: ["Fine Wine", "By the glass"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Café Nizza",
            subtitle: "Italian wine & food on Södermalm",
            rating: 4.1,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Skanstull",
            coordinate: CLLocationCoordinate2D(latitude: 59.3147, longitude: 18.0867),
            tags: ["Italian", "Food"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Cork Vinbar",
            subtitle: "Portuguese wine bar in Gamla stan",
            rating: 4.9,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Gamla stan",
            coordinate: CLLocationCoordinate2D(latitude: 59.3244, longitude: 18.0687),
            tags: ["Portuguese", "Intimate"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Dryck Vinbar",
            subtitle: "Natural wine bar on Södermalm",
            rating: 4.3,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Mariatorget",
            coordinate: CLLocationCoordinate2D(latitude: 59.3174, longitude: 18.0635),
            tags: ["Natural", "Local"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "E&G",
            subtitle: "German-focused wine bistro on Östermalm",
            rating: 4.6,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Tekniska högskolan",
            coordinate: CLLocationCoordinate2D(latitude: 59.3479, longitude: 18.0607),
            tags: ["German", "Bistro"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Grus Grus",
            subtitle: "Wine bar & kitchen on Kungsholmen",
            rating: 4.0,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "S:t Eriksplan",
            coordinate: CLLocationCoordinate2D(latitude: 59.3432, longitude: 18.0492),
            tags: ["Natural", "Kitchen"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Kungsholmens Vinbar",
            subtitle: "Neighbourhood wine bar on Kungsholmen",
            rating: 4.4,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Fridhemsplan",
            coordinate: CLLocationCoordinate2D(latitude: 59.3351, longitude: 18.0290),
            tags: ["Local", "Cozy"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Kasten",
            subtitle: "Bistro & wine bar on Östermalm",
            rating: 4.5,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Karlaplan",
            coordinate: CLLocationCoordinate2D(latitude: 59.3327, longitude: 18.0939),
            tags: ["Bistro", "Swedish"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Nektar",
            subtitle: "Wine & food bar on Kungsholmen",
            rating: 4.1,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Fridhemsplan",
            coordinate: CLLocationCoordinate2D(latitude: 59.3402, longitude: 18.0338),
            tags: ["French", "Tapas"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Savant",
            subtitle: "Natural wine & tapas near Odenplan",
            rating: 4.6,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Rådmansgatan",
            coordinate: CLLocationCoordinate2D(latitude: 59.3406, longitude: 18.0633),
            tags: ["Natural", "Tapas"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Schmaltz",
            subtitle: "Deli & wine bar on Östermalm",
            rating: 4.4,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Östermalmstorg",
            coordinate: CLLocationCoordinate2D(latitude: 59.3351, longitude: 18.0774),
            tags: ["Deli", "Casual"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "The Sparrow",
            subtitle: "French wine bar on Birger Jarlsgatan",
            rating: 4.6,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Östermalmstorg",
            coordinate: CLLocationCoordinate2D(latitude: 59.3370, longitude: 18.0717),
            tags: ["French", "Cozy"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Vina",
            subtitle: "Wine & tapas bar on Södermalm",
            rating: 4.4,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Skanstull",
            coordinate: CLLocationCoordinate2D(latitude: 59.3116, longitude: 18.0821),
            tags: ["Tapas", "Local"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),

        WineBar(
            name: "Vinverket",
            subtitle: "Wine bar & kitchen near Odenplan",
            rating: 4.6,
            priceLevel: 2,
            imageSystemName: "wineglass.fill",
            nearestStation: "Odenplan",
            coordinate: CLLocationCoordinate2D(latitude: 59.3480, longitude: 18.0461),
            tags: ["Natural", "Kitchen"],
            hasOutdoorSeating: false,
            outdoorFacingDirection: nil,
            shadowObstructions: []
        ),
    ]
}
