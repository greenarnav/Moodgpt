import Foundation
import CoreLocation
import Combine
import MapKit

class LocationTrackingService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationTrackingService()
    
    private let locationManager = CLLocationManager()
    private var geocoder = CLGeocoder()
    private var cancellables = Set<AnyCancellable>()
    
    // Published properties
    @Published var currentLocation: CLLocation?
    @Published var currentCity: String = "Unknown"
    @Published var currentLocality: String = "Unknown"
    @Published var isAuthorized: Bool = false
    @Published var locationHistory: [LocationRecord] = []
    @Published var significantLocations: [String: Int] = [:]
    
    // Private initialization
    private override init() {
        super.init()
        setupLocationManager()
        loadLocationHistory()
    }
    
    // Setup location manager
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // Balance between accuracy and battery
        locationManager.allowsBackgroundLocationUpdates = false // Set to true if tracking in background
        locationManager.pausesLocationUpdatesAutomatically = true
        
        // Check current authorization status
        checkAuthorizationStatus()
    }
    
    // Check authorization status
    private func checkAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            startLocationUpdates()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }
    
    // Start location updates
    func startLocationUpdates() {
        if isAuthorized {
            locationManager.startUpdatingLocation()
        } else {
            // Request authorization if not authorized yet
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // Stop location updates
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    // Location manager delegate methods
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Only update if significant time or distance change (to save battery and processing)
        if shouldUpdateLocation(with: location) {
            currentLocation = location
            reverseGeocode(location)
            recordLocation(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    // Determine if the location update is significant enough
    private func shouldUpdateLocation(with newLocation: CLLocation) -> Bool {
        guard let lastLocation = currentLocation else { return true }
        
        // Update if more than 200 meters distance or 10 minutes since last update
        let distanceThreshold: CLLocationDistance = 200
        let timeThreshold: TimeInterval = 10 * 60
        
        let distance = newLocation.distance(from: lastLocation)
        let timeSinceLastUpdate = newLocation.timestamp.timeIntervalSince(lastLocation.timestamp)
        
        return distance > distanceThreshold || timeSinceLastUpdate > timeThreshold
    }
    
    // Reverse geocode location to get address information
    private func reverseGeocode(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    self.currentCity = placemark.locality ?? placemark.administrativeArea ?? "Unknown"
                    self.currentLocality = placemark.subLocality ?? placemark.locality ?? "Unknown"
                    
                    // Update significant locations
                    if let city = placemark.locality {
                        self.updateSignificantLocation(city)
                    }
                }
            }
        }
    }
    
    // Record a location
    private func recordLocation(_ location: CLLocation) {
        let record = LocationRecord(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: location.timestamp,
            city: currentCity,
            locality: currentLocality
        )
        
        locationHistory.append(record)
        saveLocationHistory()
    }
    
    // Load location history from UserDefaults
    private func loadLocationHistory() {
        if let data = UserDefaults.standard.data(forKey: "locationHistory") {
            do {
                let decoder = JSONDecoder()
                locationHistory = try decoder.decode([LocationRecord].self, from: data)
                
                // Rebuild significant locations
                updateSignificantLocationsFromHistory()
            } catch {
                print("Error loading location history: \(error.localizedDescription)")
            }
        }
    }
    
    // Save location history to UserDefaults
    private func saveLocationHistory() {
        // Limit history to 100 records to save space
        if locationHistory.count > 100 {
            locationHistory = Array(locationHistory.suffix(100))
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(locationHistory)
            UserDefaults.standard.set(data, forKey: "locationHistory")
        } catch {
            print("Error saving location history: \(error.localizedDescription)")
        }
    }
    
    // Update significant locations counter
    private func updateSignificantLocation(_ city: String) {
        if let count = significantLocations[city] {
            significantLocations[city] = count + 1
        } else {
            significantLocations[city] = 1
        }
    }
    
    // Rebuild significant locations from history
    private func updateSignificantLocationsFromHistory() {
        var locations: [String: Int] = [:]
        
        for record in locationHistory {
            if record.city != "Unknown" {
                if let count = locations[record.city] {
                    locations[record.city] = count + 1
                } else {
                    locations[record.city] = 1
                }
            }
        }
        
        self.significantLocations = locations
    }
    
    // Get the most frequent cities
    func getMostFrequentCities(limit: Int = 5) -> [(city: String, count: Int)] {
        return significantLocations
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { ($0.key, $0.value) }
    }
    
    // Get a region encompassing the user's recent locations
    func getRecentLocationsRegion() -> MKCoordinateRegion {
        let recentLocations = locationHistory.suffix(20)
        
        if recentLocations.isEmpty, let currentLocation = currentLocation {
            // Default to current location with medium zoom
            return MKCoordinateRegion(
                center: currentLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        } else if recentLocations.isEmpty {
            // Default to San Francisco
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        }
        
        // Calculate bounds of recent locations
        var minLat = Double.greatestFiniteMagnitude
        var maxLat = -Double.greatestFiniteMagnitude
        var minLon = Double.greatestFiniteMagnitude
        var maxLon = -Double.greatestFiniteMagnitude
        
        for location in recentLocations {
            minLat = min(minLat, location.latitude)
            maxLat = max(maxLat, location.latitude)
            minLon = min(minLon, location.longitude)
            maxLon = max(maxLon, location.longitude)
        }
        
        // Add padding
        let latPadding = max(0.02, (maxLat - minLat) * 0.3)
        let lonPadding = max(0.02, (maxLon - minLon) * 0.3)
        
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        let latDelta = (maxLat - minLat) + latPadding * 2
        let lonDelta = (maxLon - minLon) + lonPadding * 2
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        )
    }
    
    // Correlate location with mood
    func correlateLocationWithMood() -> [String: Double] {
        // This would normally fetch mood data for each location from a mood tracking service
        // For now we'll return mock data
        
        return [
            "San Francisco": 0.8,
            "New York": 0.6,
            "Los Angeles": 0.75,
            "Chicago": 0.5,
            "Miami": 0.9
        ]
    }
    
    // Get current location as CLLocationCoordinate2D
    var currentCoordinate: CLLocationCoordinate2D {
        currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    }
}

// Model for location records
struct LocationRecord: Identifiable, Codable {
    var id = UUID()
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let city: String
    let locality: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
} 