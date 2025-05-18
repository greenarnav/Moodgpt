import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationService = LocationService()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Data for locations with emotions - would come from API in production
    @State private var locations: [LocationWithEmotion] = []
    @State private var selectedLocation: LocationWithEmotion?
    @State private var isLoadingFromAPI: Bool = true
    @State private var apiError: Bool = false
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: locations) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    Button(action: {
                        withAnimation {
                            selectedLocation = item
                        }
                    }) {
                        VStack(spacing: 0) {
                            Text(getEmojiForEmotion(item.emotion))
                                .font(.system(size: 40))
                                .shadow(color: .black.opacity(0.2), radius: 5)
                                .scaleEffect(selectedLocation?.id == item.id ? 1.3 : 1.0)
                                .frame(width: 50, height: 50)
                                .background(Circle().fill(.white).opacity(0.7))
                            
                            if selectedLocation?.id != item.id {
                                Text(item.name)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(.white.opacity(0.9))
                                            .shadow(color: .black.opacity(0.1), radius: 2)
                                    )
                            }
                        }
                        .animation(.spring(), value: selectedLocation?.id)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    // API status indicator
                    if isLoadingFromAPI {
                        HStack(spacing: 4) {
                            ProgressView()
                                .scaleEffect(0.7)
                            Text("Loading data...")
                                .font(.caption)
                        }
                        .padding(8)
                        .background(
                            Capsule()
                                .fill(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.1), radius: 2)
                        )
                        .padding(.leading)
                    } else if apiError {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Using cached data")
                                .font(.caption)
                        }
                        .padding(8)
                        .background(
                            Capsule()
                                .fill(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.1), radius: 2)
                        )
                        .padding(.leading)
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button("All Locations", action: { /* Filter logic */ })
                        Button("Cities", action: { /* Filter logic */ })
                        Button("Points of Interest", action: { /* Filter logic */ })
                        Button("Refresh Data", action: fetchLocationEmotions)
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                }
                
                Spacer()
                
                if let selected = selectedLocation {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(selected.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text(getEmojiForEmotion(selected.emotion))
                                .font(.system(size: 44))
                        }
                        
                        HStack {
                            Text("Type: ")
                                .foregroundColor(.secondary)
                                .fontWeight(.medium)
                            Text(selected.type.capitalized)
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                            Spacer()
                            
                            Text("Mood: \(selected.emotion.description)")
                                .foregroundColor(selected.emotion.color)
                                .fontWeight(.semibold)
                        }
                        
                        Text("Coordinates: \(String(format: "%.4f", selected.coordinate.latitude)), \(String(format: "%.4f", selected.coordinate.longitude))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                        
                        Button(action: {
                            // Action to find nearby contacts
                        }) {
                            Label("Find contacts near \(selected.name)", systemImage: "person.2.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.2), radius: 10)
                    )
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        if let location = locationService.currentLocation {
                            withAnimation {
                                region = MKCoordinateRegion(
                                    center: location.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                )
                                selectedLocation = nil
                            }
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Map")
        .onAppear {
            locationService.requestAuthorization()
            
            // Center map on user's location when available
            if let location = locationService.currentLocation {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
            
            // Attempt to fetch from API, with fallback to pre-defined data
            fetchLocationEmotions()
        }
    }
    
    // This would call the actual API in production
    private func fetchLocationEmotions() {
        isLoadingFromAPI = true
        apiError = false
        
        // Simulate API call with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Simulate API failure 50% of the time for testing
            let simulateFailure = false
            
            if simulateFailure {
                apiError = true
                // Fall back to hardcoded data
                initializeLocationsWithMockedEmotions()
            } else {
                // Simulate successful API response
                initializeLocationsWithConsistentEmotions()
            }
            
            isLoadingFromAPI = false
        }
    }
    
    // Consistent emotion data - simulating a successful API response
    private func initializeLocationsWithConsistentEmotions() {
        let baseLocations = getBaseLocations()
        
        // Predefined emotions for major cities
        let cityEmotions: [String: Emotion] = [
            "San Francisco": .happy,
            "New York": .neutral,
            "Los Angeles": .surprised,
            "Chicago": .sad,
            "Houston": .angry,
            "Pier 39": .happy,
            "Alcatraz Island": .fearful,
            "Fisherman's Wharf": .happy,
            "Lower Village": .neutral,
            "North Gardens": .neutral
        ]
        
        // Assign emotions consistently to all locations
        var locationsWithEmotions = baseLocations.map { location in
            let emotion = cityEmotions[location.name] ?? 
                          (location.type == "city" ? .neutral : 
                          (location.type == "attraction" ? .happy : .neutral))
            
            return LocationWithEmotion(
                coordinate: location.coordinate,
                name: location.name,
                type: location.type,
                emotion: emotion
            )
        }
        
        // Double the number of locations with random variations
        locationsWithEmotions = doubleLocationsWithEmotions(locationsWithEmotions)
        
        locations = locationsWithEmotions
    }
    
    // Fallback for when the API fails - uses random emotions
    private func initializeLocationsWithMockedEmotions() {
        let baseLocations = getBaseLocations()
        var locationsWithEmotions = refreshLocationsWithRandomEmotions(baseLocations)
        
        // Double the number of locations with random variations
        locationsWithEmotions = doubleLocationsWithEmotions(locationsWithEmotions)
        
        locations = locationsWithEmotions
    }
    
    // Double the number of locations by creating variations around existing ones
    private func doubleLocationsWithEmotions(_ originalLocations: [LocationWithEmotion]) -> [LocationWithEmotion] {
        var result = originalLocations
        let emotions = Emotion.allCases
        
        for location in originalLocations {
            // Create a random variation of the location's coordinates
            let latOffset = Double.random(in: -0.006...0.006)
            let lngOffset = Double.random(in: -0.006...0.006)
            
            let newCoordinate = CLLocationCoordinate2D(
                latitude: location.coordinate.latitude + latOffset,
                longitude: location.coordinate.longitude + lngOffset
            )
            
            // Generate a random emotion for the new location
            let newEmotion = emotions.randomElement() ?? .neutral
            
            let newLocation = LocationWithEmotion(
                coordinate: newCoordinate,
                name: location.name,
                type: location.type,
                emotion: newEmotion
            )
            
            result.append(newLocation)
        }
        
        return result
    }
    
    // Base locations data
    private func getBaseLocations() -> [LocationBasicInfo] {
        return [
            LocationBasicInfo(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), name: "San Francisco", type: "city"),
            LocationBasicInfo(coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), name: "New York", type: "city"),
            LocationBasicInfo(coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), name: "Los Angeles", type: "city"),
            LocationBasicInfo(coordinate: CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298), name: "Chicago", type: "city"),
            LocationBasicInfo(coordinate: CLLocationCoordinate2D(latitude: 29.7604, longitude: -95.3698), name: "Houston", type: "city"),
            LocationBasicInfo(coordinate: CLLocationCoordinate2D(latitude: 37.8085, longitude: -122.4241), name: "Pier 39", type: "attraction"),
            LocationBasicInfo(coordinate: CLLocationCoordinate2D(latitude: 37.7955, longitude: -122.3937), name: "Fisherman's Wharf", type: "attraction"),
            LocationBasicInfo(coordinate: CLLocationCoordinate2D(latitude: 37.7925, longitude: -122.4382), name: "Lower Village", type: "district"),
            LocationBasicInfo(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), name: "West Square", type: "district"),
            LocationBasicInfo(coordinate: CLLocationCoordinate2D(latitude: 37.7694, longitude: -122.4862), name: "North Village", type: "district"),
            LocationBasicInfo(coordinate: CLLocationCoordinate2D(latitude: 37.7792, longitude: -122.4651), name: "Upper Square", type: "district"),
            LocationBasicInfo(coordinate: CLLocationCoordinate2D(latitude: 37.7694, longitude: -122.4292), name: "North Gardens", type: "park"),
            LocationBasicInfo(coordinate: CLLocationCoordinate2D(latitude: 37.7647, longitude: -122.4730), name: "Lower Gardens", type: "park"),
            LocationBasicInfo(coordinate: CLLocationCoordinate2D(latitude: 37.7579, longitude: -122.4367), name: "South Square", type: "district"),
            LocationBasicInfo(coordinate: CLLocationCoordinate2D(latitude: 37.7525, longitude: -122.4438), name: "Upper Hill", type: "district"),
            LocationBasicInfo(coordinate: CLLocationCoordinate2D(latitude: 37.8101, longitude: -122.4101), name: "Alcatraz Island", type: "attraction")
        ]
    }
    
    private func refreshRandomEmotions() {
        let currentLocationInfos = locations.map { 
            LocationBasicInfo(coordinate: $0.coordinate, name: $0.name, type: $0.type)
        }
        let locationsWithEmotions = refreshLocationsWithRandomEmotions(currentLocationInfos)
        locations = doubleLocationsWithEmotions(locationsWithEmotions)
    }
    
    private func refreshLocationsWithRandomEmotions(_ baseLocations: [LocationBasicInfo]) -> [LocationWithEmotion] {
        let emotions = Emotion.allCases
        
        return baseLocations.map { location in
            // All locations should have emotions
            let randomEmotion = emotions.randomElement() ?? .neutral
            
            return LocationWithEmotion(
                coordinate: location.coordinate,
                name: location.name,
                type: location.type,
                emotion: randomEmotion
            )
        }
    }
    
    // Return emoji based on emotion
    private func getEmojiForEmotion(_ emotion: Emotion) -> String {
        switch emotion {
        case .happy: return "😄"
        case .sad: return "😢" 
        case .angry: return "😠"
        case .surprised: return "😲"
        case .fearful: return "😨"
        case .disgusted: return "🤢"
        case .neutral: return "😐"
        }
    }
}

// Helper struct for the basic location info
struct LocationBasicInfo {
    let coordinate: CLLocationCoordinate2D
    let name: String
    let type: String
}

// For demo purposes - in a real app this would come from an API
struct LocationWithEmotion: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let name: String
    let type: String
    let emotion: Emotion
}