import Foundation
import Combine

// Models for city sentiment data
struct CitySentimentResponse: Codable {
    let cities: [CityMoodData]
    let timestamp: Date
}

struct CityMoodData: Codable, Identifiable {
    let id = UUID()
    let city: String
    let currentMoodScore: Double
    let timestamp: Date
    let themes: [MoodTheme]
    let moodTimeline: [MoodTimelinePoint]
    
    // For JSON decoding - custom keys
    enum CodingKeys: String, CodingKey {
        case city, currentMoodScore, timestamp, themes, moodTimeline
    }
}

struct MoodTheme: Codable, Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let impact: Double
    
    // For JSON decoding - custom keys
    enum CodingKeys: String, CodingKey {
        case name, description, impact
    }
}

struct MoodTimelinePoint: Codable, Identifiable {
    let id = UUID()
    let timestamp: Date
    let score: Double
    
    // For JSON decoding - custom keys
    enum CodingKeys: String, CodingKey {
        case timestamp, score
    }
}

// Renamed to avoid duplicate declaration conflict
struct CityMoodTimelineEntry: Identifiable {
    let id = UUID()
    let timeLabel: String
    let emotion: Emotion
    let isNow: Bool
}

class CitySentimentService: ObservableObject {
    static let shared = CitySentimentService()
    
    private let baseURL = "https://mainoverallapi.vercel.app"
    private var cancellables = Set<AnyCancellable>()
    
    // Published properties
    @Published var allCityData: [CityMoodData] = []
    
    // Cache for city sentiment data
    private var cityDataCache: [String: CityMoodData] = [:]
    private var lastFetchTime: Date?
    private let cacheLifetime: TimeInterval = 300 // 5 minutes
    
    private init() {
        // Load mock data initially
        self.allCityData = Self.getMockCitySentimentData()
    }
    
    // Get sentiment data for all cities
    func getAllCitySentiments() -> AnyPublisher<[CityMoodData], APIError> {
        // Check if cache is valid
        if let lastFetch = lastFetchTime, Date().timeIntervalSince(lastFetch) < cacheLifetime, !cityDataCache.isEmpty {
            return Just(Array(cityDataCache.values))
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }
        
        // In a real app, we would fetch from the API
        // For now, return mock data
        let mockData = Self.getMockCitySentimentData()
        self.allCityData = mockData
        self.updateCache(with: mockData)
        self.lastFetchTime = Date()
        
        return Just(mockData)
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }
    
    // Get sentiment data for a specific city
    func getCitySentiment(for cityName: String) -> AnyPublisher<CityMoodData, APIError> {
        // Check if city data is in cache
        if let lastFetch = lastFetchTime, 
           Date().timeIntervalSince(lastFetch) < cacheLifetime,
           let cityData = cityDataCache[cityName.lowercased()] {
            return Just(cityData)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }
        
        // If not in cache or cache expired, fetch all cities and filter
        return getAllCitySentiments()
            .tryMap { cities -> CityMoodData in
                if let city = cities.first(where: { $0.city.lowercased() == cityName.lowercased() }) {
                    return city
                }
                throw APIError.invalidResponse
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.networkError(error)
            }
            .eraseToAnyPublisher()
    }
    
    // Non-Combine version
    func fetchAllCitySentiments(completion: @escaping (Result<[CityMoodData], APIError>) -> Void) {
        // Check if cache is valid
        if let lastFetch = lastFetchTime, Date().timeIntervalSince(lastFetch) < cacheLifetime, !cityDataCache.isEmpty {
            completion(.success(Array(cityDataCache.values)))
            return
        }
        
        // In a real app, we would fetch from the API
        // For now, return mock data
        let mockData = Self.getMockCitySentimentData()
        self.allCityData = mockData
        self.updateCache(with: mockData)
        self.lastFetchTime = Date()
        
        completion(.success(mockData))
    }
    
    // Update local cache
    private func updateCache(with cities: [CityMoodData]) {
        for city in cities {
            cityDataCache[city.city.lowercased()] = city
        }
    }
    
    // Force refresh data
    func refreshData() -> AnyPublisher<[CityMoodData], APIError> {
        // Clear last fetch time to force a new fetch
        lastFetchTime = nil
        return getAllCitySentiments()
    }
    
    // MARK: - Mock Data for Preview and Testing
    
    static func getMockCitySentimentData() -> [CityMoodData] {
        let themes: [MoodTheme] = [
            MoodTheme(name: "Transport Safety & Transit", description: "Public transportation and traffic safety issues", impact: 0.3),
            MoodTheme(name: "Local Politics / Policy", description: "Public opinion on local government decisions", impact: 0.4),
            MoodTheme(name: "Crime & Policing", description: "Safety concerns and police activity", impact: 0.2),
            MoodTheme(name: "Weather", description: "Current weather conditions and forecasts", impact: 0.8)
        ]
        
        // Create timeline points - 24 hours of data
        let now = Date()
        let calendar = Calendar.current
        var timelinePoints: [MoodTimelinePoint] = []
        
        for i in 0..<24 {
            if let time = calendar.date(byAdding: .hour, value: -i, to: now) {
                // Generate synthetic mood data with some variability
                var score = 0.5
                
                switch i % 6 {
                case 0: score = 0.8
                case 1: score = 0.6
                case 2: score = 0.5
                case 3: score = 0.4
                case 4: score = 0.3
                case 5: score = 0.7
                default: score = 0.5
                }
                
                // Add some randomness
                score += Double.random(in: -0.1...0.1)
                score = min(max(score, 0.0), 1.0) // Clamp between 0 and 1
                
                timelinePoints.append(MoodTimelinePoint(timestamp: time, score: score))
            }
        }
        
        return [
            CityMoodData(
                city: "San Francisco",
                currentMoodScore: 0.8,
                timestamp: Date(),
                themes: themes,
                moodTimeline: timelinePoints
            ),
            CityMoodData(
                city: "New York",
                currentMoodScore: 0.4,
                timestamp: Date(),
                themes: themes,
                moodTimeline: timelinePoints
            ),
            CityMoodData(
                city: "Chicago",
                currentMoodScore: 0.6,
                timestamp: Date(),
                themes: themes,
                moodTimeline: timelinePoints
            )
        ]
    }
} 