import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    // Default to T-Centralen area when no location
    static let stockholmCenter = CLLocationCoordinate2D(latitude: 59.3313, longitude: 18.0597)

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        userLocation = loc.coordinate
        manager.stopUpdatingLocation()
    }

    func nearestStation() -> MetroStation {
        let anchor = userLocation ?? Self.stockholmCenter
        let anchorLoc = CLLocation(latitude: anchor.latitude, longitude: anchor.longitude)
        return SampleData.stations.min { a, b in
            let distA = CLLocation(latitude: a.coordinate.latitude, longitude: a.coordinate.longitude).distance(from: anchorLoc)
            let distB = CLLocation(latitude: b.coordinate.latitude, longitude: b.coordinate.longitude).distance(from: anchorLoc)
            return distA < distB
        } ?? SampleData.stations[0]
    }

    func nearbyBars(limit: Int = 5) -> [WineBar] {
        let anchor = userLocation ?? Self.stockholmCenter
        let anchorLoc = CLLocation(latitude: anchor.latitude, longitude: anchor.longitude)
        return SampleData.wineBars
            .sorted { a, b in
                let distA = CLLocation(latitude: a.coordinate.latitude, longitude: a.coordinate.longitude).distance(from: anchorLoc)
                let distB = CLLocation(latitude: b.coordinate.latitude, longitude: b.coordinate.longitude).distance(from: anchorLoc)
                return distA < distB
            }
            .prefix(limit)
            .map { $0 }
    }
}
