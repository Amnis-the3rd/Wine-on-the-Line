
import SwiftUI
import MapKit


struct HomeView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    
    var filteredBars: [WineBar] {
        if searchText.isEmpty { return [] }
        return SampleData.wineBars.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    @StateObject private var locationManager = LocationManager()
    @State private var selectedBar: WineBar? = nil
    @State private var region = MKCoordinateRegion(
        center: LocationManager.stockholmCenter,
        span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
    )
    
    @ViewBuilder
    private var searchResultsSection: some View {
        if !filteredBars.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Results")
                    .font(.headline)
                    .padding(.leading)
                ForEach(filteredBars) { bar in
                    SearchResultRow(bar: bar, userLocation: locationManager.userLocation)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom, 16)
        } else if !searchText.isEmpty {
            Text("No bars found")
                .font(.subheadline)
                .foregroundStyle(AppTheme.subtleText)
                .padding()
        }
    }
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection
                if !searchText.isEmpty {
                    searchResultsSection
                } else {
                    mapSection
                    nearestStationBanner
                    nearbyBarsSection
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear { locationManager.requestPermission() }
    }
    
    // MARK: - Header
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Wine on the Line")
                        .font(.largeTitle.bold())
                        .foregroundStyle(AppTheme.burgundy)
                    Text("Wine bars along the T-bana")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.subtleText)
                }
                Spacer()
                Image(systemName: "wineglass.fill")
                    .font(.title)
                    .foregroundStyle(AppTheme.wine)
            }
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppTheme.subtleText)
                TextField("Search wine bars...", text: $searchText)
                    .onTapGesture { isSearching = true }
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        isSearching = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.subtleText)
                    }
                }
            }
            .padding(10)
            .background(AppTheme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
    
    
    // MARK: - Map

    @ViewBuilder
    private var mapSection: some View {
        let stationItems = SampleData.stations.map { MapItem(from: $0) }
        let barItems = SampleData.wineBars.map { MapItem(from: $0) }
        let allItems = stationItems + barItems

        Map(coordinateRegion: $region, annotationItems: allItems) { item in
            MapAnnotation(coordinate: item.coordinate) {
                if item.isWineBar {
                    WineBarAnnotation()
                        .onTapGesture {
                            selectedBar = SampleData.wineBars.first { $0.name == item.name }
                        }
                } else {
                    StationAnnotation(line: item.line ?? .green)
                }
            }
        }
        .frame(height: 140)//tidigare 280
        .clipShape(RoundedRectangle(cornerRadius: 20))//tidigare 20
        .padding(.horizontal)
        .sheet(item: $selectedBar) { bar in
            WineBarDetailSheet(bar: bar)
        }
    }
    
    // MARK: - Nearest Station
    
    @ViewBuilder
    private var nearestStationBanner: some View {
        let station = locationManager.nearestStation()
        HStack(spacing: 12) {
            lineIndicator(for: station.line)
            VStack(alignment: .leading, spacing: 2) {
                Text("Nearest Station")
                    .font(.caption)
                    .foregroundStyle(AppTheme.subtleText)
                Text(station.name)
                    .font(.headline)
            }
            Spacer()
            Image(systemName: "location.fill")
                .foregroundStyle(AppTheme.wine)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        .padding(.horizontal)
        .padding(.top, 16)
    }
    
    // MARK: - Nearby Bars
    
    @ViewBuilder
    private var nearbyBarsSection: some View {
        let bars = locationManager.nearbyBars()
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Nearby Wine Bars")
                    .font(.title3.bold())
                Spacer()
                Text("\(bars.count) spots")
                    .font(.caption)
                    .foregroundStyle(AppTheme.subtleText)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(bars) { bar in
                        WineBarCard(bar: bar)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 20) //tidigare 20
        .padding(.bottom, 32) //tidigare 32
    }
    
    // MARK: - Helpers
   
    @ViewBuilder
    private func lineIndicator(for line: MetroLine) -> some View {
        let color: Color = {
            switch line {
            case .green: return AppTheme.metroGreen
            case .red: return AppTheme.metroRed
            case .blue: return AppTheme.metroBlue
            }
        }()
        Circle()
            .fill(color)
            .frame(width: 36, height: 36) //tidigare 36&36
            .overlay(Text("T").font(.caption.bold()).foregroundStyle(.white))
    }
    
    
    // MARK: - Map Item Helper
    
    struct MapItem: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
        let isWineBar: Bool
        let line: MetroLine?
        let name: String
        
        init(from station: MetroStation) {
            self.coordinate = station.coordinate
            self.isWineBar = false
            self.line = station.line
            self.name = station.name
        }
        
        init(from bar: WineBar) {
            self.coordinate = bar.coordinate
            self.isWineBar = true
            self.line = nil
            self.name = bar.name
        }
    }
    
    // MARK: - Annotation Views
    
    struct StationAnnotation: View {
        let line: MetroLine
        var body: some View {
            let color: Color = {
                switch line {
                case .green: return AppTheme.metroGreen
                case .red: return AppTheme.metroRed
                case .blue: return AppTheme.metroBlue
                }
            }()
            Circle()
                .fill(color)
                .frame(width: 10, height: 10) //tidigare 14 & 14
                .overlay(Circle().stroke(.white, lineWidth: 2))
        }
    }
    
    struct WineBarAnnotation: View {
        var body: some View {
            Image(systemName: "wineglass.fill")
                .font(.system(size: 8))
                .foregroundStyle(.white)
                .padding(4)
                .background(AppTheme.burgundy)
                .clipShape(Circle())
                .overlay(Circle().stroke(.white, lineWidth: 1))
        }
    }
    
}

