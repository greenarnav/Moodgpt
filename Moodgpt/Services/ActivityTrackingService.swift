import Foundation
import Combine
import CoreMotion
import HealthKit

class ActivityTrackingService {
    static let shared = ActivityTrackingService()
    
    private let pedometer = CMPedometer()
    private let healthStore = HKHealthStore()
    private var cancellables = Set<AnyCancellable>()
    
    // Published properties to observe
    @Published var currentStepCount: Int = 0
    @Published var dailyStepCount: Int = 0
    @Published var dailySleepHours: Double = 0
    @Published var currentActivity: String = "Unknown"
    @Published var activityHistory: [ActivityRecord] = []
    
    private init() {
        // Initialize with some data
        dailyStepCount = Int.random(in: 5000...10000)
        dailySleepHours = Double.random(in: 6.0...9.0)
        currentActivity = "Unknown"
        
        // Add some dummy activity history
        activityHistory = [
            ActivityRecord(
                type: "Walking",
                duration: 0.5,
                startTime: Date().addingTimeInterval(-3600), // 1 hour ago
                endTime: Date(),
                intensity: "Moderate",
                moodImpact: 0.6
            ),
            ActivityRecord(
                type: "Sleep",
                duration: 7.5,
                startTime: Calendar.current.date(byAdding: .hour, value: -8, to: Date()) ?? Date(),
                endTime: Calendar.current.date(byAdding: .minute, value: -30, to: Date()) ?? Date(),
                intensity: "Good",
                moodImpact: 0.8
            )
        ]
        
        // Set up HealthKit if available
        if HKHealthStore.isHealthDataAvailable() {
            setupHealthKit()
        } else {
            // Start simulated activity updates if HealthKit is not available
            startSimulatedActivityUpdates()
        }
    }
    
    // Setup HealthKit permissions
    private func setupHealthKit() {
        // Define the types to read
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.workoutType()
        ]
        
        // Request authorization
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                print("HealthKit authorization granted in ActivityTrackingService")
                DispatchQueue.main.async {
                    self.fetchDailyStepCount()
                    self.fetchSleepData()
                    self.startPedometerUpdates()
                }
            } else if let error = error {
                print("HealthKit authorization failed in ActivityTrackingService: \(error.localizedDescription)")
                // Fall back to simulated data
                self.startSimulatedActivityUpdates()
            }
        }
    }
    
    // Start pedometer updates for real-time step tracking
    func startPedometerUpdates() {
        /* Comment out actual pedometer updates
        pedometer.startUpdates(from: Date()) { [weak self] data, error in
            guard let self = self, let data = data else {
                if let error = error {
                    print("Pedometer error: \(error.localizedDescription)")
                }
                return
            }
            
            DispatchQueue.main.async {
                // Update step count
                let steps = data.numberOfSteps.intValue
                self.dailyStepCount = steps
                
                // Potentially detect an activity based on step count
                // This is a simplified example
                if steps > 0 && steps % 1000 == 0 {  // Every 1000 steps
                    let walkRecord = ActivityRecord(
                        type: "Walking",
                        duration: 0.5, // Assumption: ~30 min to walk 1000 steps
                        startTime: Date().addingTimeInterval(-1800), // 30 min ago
                        endTime: Date(),
                        intensity: "Moderate",
                        moodImpact: 0.6
                    )
                    self.recordActivity(walkRecord)
                }
            }
        }
        */
        
        // Instead, set up a timer to simulate pedometer updates with dummy data
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Increment step count by a random amount every minute
            DispatchQueue.main.async {
                let additionalSteps = Int.random(in: 50...150)
                self.dailyStepCount += additionalSteps
                
                // Occasionally record a walking activity
                if Int.random(in: 1...20) == 1 {  // ~5% chance each minute
                    let walkRecord = ActivityRecord(
                        type: "Walking",
                        duration: 0.5,
                        startTime: Date().addingTimeInterval(-1800),
                        endTime: Date(),
                        intensity: "Moderate",
                        moodImpact: 0.6
                    )
                    self.recordActivity(walkRecord)
                }
            }
        }
    }
    
    // Fetch today's step count from HealthKit
    func fetchDailyStepCount() {
        /* Comment out actual HealthKit query
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: HKQuantityType.quantityType(forIdentifier: .stepCount)!,
                                     quantitySamplePredicate: predicate,
                                     options: .cumulativeSum) { [weak self] _, result, error in
            guard let self = self else { return }
            
            if let result = result, let sum = result.sumQuantity() {
                let steps = Int(sum.doubleValue(for: HKUnit.count()))
                DispatchQueue.main.async {
                    self.dailyStepCount = steps
                }
            } else if let error = error {
                print("Error fetching daily step count: \(error.localizedDescription)")
            }
        }
        
        healthStore.execute(query)
        */
        
        // Provide dummy data instead
        DispatchQueue.main.async {
            self.dailyStepCount = Int.random(in: 5000...12000) // Random step count between 5000-12000
        }
    }
    
    // Fetch sleep data from HealthKit
    func fetchSleepData() {
        /* Comment out actual HealthKit query
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: HKQuantityType.quantityType(forIdentifier: .appleStandTime)!,
                                     quantitySamplePredicate: predicate,
                                     options: .cumulativeSum) { [weak self] _, result, error in
            guard let self = self else { return }
            
            if let result = result, let sum = result.sumQuantity() {
                let sleepHours = sum.doubleValue(for: HKUnit.hour())
                DispatchQueue.main.async {
                    self.dailySleepHours = sleepHours
                }
            } else if let error = error {
                print("Error fetching sleep data: \(error.localizedDescription)")
            }
        }
        
        healthStore.execute(query)
        */
        
        // Provide dummy data instead
        DispatchQueue.main.async {
            self.dailySleepHours = Double.random(in: 6.5...8.5) // Random sleep hours between 6.5-8.5
        }
    }
    
    // Record a user activity
    func recordActivity(_ activity: ActivityRecord) {
        activityHistory.append(activity)
        saveActivityHistory()
        
        // Notify if activity might impact mood
        if activity.moodImpact < 0.4 && activity.duration > 1.0 {
            NotificationService.shared.scheduleSignificantMoodChangeNotification(
                oldMood: .neutral, 
                newMood: .sad
            )
        } else if activity.moodImpact > 0.7 {
            NotificationService.shared.scheduleSignificantMoodChangeNotification(
                oldMood: .neutral, 
                newMood: .happy
            )
        }
    }
    
    // Save activity history to UserDefaults
    private func saveActivityHistory() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(activityHistory)
            UserDefaults.standard.set(data, forKey: "activityHistory")
        } catch {
            print("Error saving activity history: \(error.localizedDescription)")
        }
    }
    
    // Load activity history from UserDefaults
    private func loadActivityHistory() {
        if let data = UserDefaults.standard.data(forKey: "activityHistory") {
            do {
                let decoder = JSONDecoder()
                activityHistory = try decoder.decode([ActivityRecord].self, from: data)
            } catch {
                print("Error loading activity history: \(error.localizedDescription)")
            }
        }
    }
    
    // Get activity records for a specific date
    func getActivities(for date: Date) -> [ActivityRecord] {
        let calendar = Calendar.current
        return activityHistory.filter { activity in
            calendar.isDate(activity.startTime, inSameDayAs: date)
        }
    }
    
    // Get the most impactful activities on mood for the last week
    func getMostImpactfulActivities(limit: Int = 5) -> [ActivityRecord] {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return activityHistory
            .filter { $0.startTime >= oneWeekAgo }
            .sorted { abs($0.moodImpact - 0.5) > abs($1.moodImpact - 0.5) }
            .prefix(limit)
            .map { $0 }
    }
    
    // Calculate the average mood impact of a specific activity type
    func calculateAverageMoodImpact(for activityType: String) -> Double {
        let matchingActivities = activityHistory.filter { $0.type == activityType }
        guard !matchingActivities.isEmpty else { return 0.5 }
        
        let totalImpact = matchingActivities.reduce(0.0) { $0 + $1.moodImpact }
        return totalImpact / Double(matchingActivities.count)
    }
    
    // Predict mood based on today's activities
    func predictMoodBasedOnActivities() -> Emotion {
        let today = Calendar.current.startOfDay(for: Date())
        let todayActivities = getActivities(for: today)
        
        if todayActivities.isEmpty {
            return .neutral
        }
        
        let weightedTotal = todayActivities.reduce(0.0) { $0 + ($1.moodImpact * $1.duration) }
        let totalDuration = todayActivities.reduce(0.0) { $0 + $1.duration }
        
        let averageMoodScore = totalDuration > 0 ? weightedTotal / totalDuration : 0.5
        return Emotion.fromMoodScore(averageMoodScore)
    }
    
    // A helper method to simulate activity updates
    private func startSimulatedActivityUpdates() {
        // Set up a timer to periodically update activity data
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Occasionally add a new activity
            if Int.random(in: 1...4) == 1 {  // 25% chance every 5 minutes
                let activities = ["Walking", "Running", "Resting", "Working", "Reading"]
                let intensities = ["Light", "Moderate", "Intense"]
                
                let randomActivity = activities.randomElement() ?? "Walking"
                let randomIntensity = intensities.randomElement() ?? "Moderate"
                let randomDuration = Double.random(in: 0.25...1.5)  // 15-90 minutes
                
                let newActivity = ActivityRecord(
                    type: randomActivity,
                    duration: randomDuration,
                    startTime: Date().addingTimeInterval(-randomDuration * 3600),
                    endTime: Date(),
                    intensity: randomIntensity,
                    moodImpact: Double.random(in: 0.3...0.9)
                )
                
                self.recordActivity(newActivity)
            }
        }
    }
}

// Model for activity records
struct ActivityRecord: Identifiable, Codable {
    var id = UUID()
    var type: String // Exercise, Sleep, Work, Social, etc.
    var duration: Double // In hours
    var startTime: Date
    var endTime: Date
    var intensity: String // Low, Medium, High, etc.
    var moodImpact: Double // 0.0 (very negative) to 1.0 (very positive)
    var notes: String?
    
    // For manual activities
    static func createManualActivity(type: String, duration: Double, intensity: String, notes: String? = nil) -> ActivityRecord {
        let endTime = Date()
        let startTime = Calendar.current.date(byAdding: .minute, value: -Int(duration * 60), to: endTime) ?? endTime
        
        // Calculate likely mood impact based on activity type and intensity
        var moodImpact = 0.5 // neutral
        
        switch type.lowercased() {
        case "exercise", "workout", "run", "jog", "walk", "hike", "swim", "bike", "cycling":
            moodImpact = intensity.lowercased() == "high" ? 0.85 : 0.7
        case "work", "meeting", "studying":
            moodImpact = intensity.lowercased() == "high" ? 0.3 : 0.5
        case "social", "party", "gathering", "date", "dinner":
            moodImpact = 0.8
        case "meditation", "relaxation", "yoga":
            moodImpact = 0.75
        case "sleep":
            moodImpact = duration >= 7 ? 0.8 : 0.4
        default:
            moodImpact = 0.5
        }
        
        return ActivityRecord(
            type: type,
            duration: duration,
            startTime: startTime,
            endTime: endTime,
            intensity: intensity,
            moodImpact: moodImpact,
            notes: notes
        )
    }
} 