import Foundation
import CoreLocation
import SwiftUI

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocation?
    @Published var currentCity: String?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var cityMood: CityMood?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        if manager.authorizationStatus == .authorizedWhenInUse {
            startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        fetchCityForLocation(location)
    }
    
    private func fetchCityForLocation(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                guard let self = self, let placemark = placemarks?.first else { return }
                
                if let city = placemark.locality {
                    self.currentCity = city
                    self.generateCityMood(for: city)
                }
            }
        }
    }
    
    // For demo purposes
    private func generateCityMood(for city: String) {
        // In a real app, you would fetch this data from an API
        let emotions = Emotion.allCases
        let dominantEmotion = emotions.randomElement()!
        
        var percentages: [String: Double] = [:]
        var total = 0.0
        
        // Generate random percentages for each emotion
        for emotion in emotions {
            let value = Double.random(in: 0...1)
            percentages[emotion.rawValue] = value
            total += value
        }
        
        // Normalize to ensure sum is 1.0
        for emotion in emotions {
            percentages[emotion.rawValue] = (percentages[emotion.rawValue] ?? 0) / total
        }
        
        cityMood = CityMood(
            city: city,
            dominantEmotion: dominantEmotion,
            emotionPercentages: percentages,
            lastUpdated: Date()
        )
    }
} 