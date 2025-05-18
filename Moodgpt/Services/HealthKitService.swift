import Foundation
import HealthKit
import SwiftUI

class HealthKitService: ObservableObject {
    static let shared = HealthKitService()
    
    let healthStore: HKHealthStore?
    
    @Published var isHealthKitAuthorized = false
    @Published var isHealthKitAvailable = false
    @Published var isLoading = false
    @Published var error: Error?
    @Published var lastSyncDate: Date?
    @Published var healthData: [String: Double] = [:]
    
    // Types of health data we want to read
    let typesToRead: [HKObjectType] = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!
    ]
    
    init() {
        // Check if HealthKit is available on this device
        isHealthKitAvailable = HKHealthStore.isHealthDataAvailable()
        
        if isHealthKitAvailable {
            healthStore = HKHealthStore()
            checkAuthorizationStatus()
        } else {
            healthStore = nil
            isHealthKitAuthorized = false
        }
    }
    
    func checkAuthorizationStatus() {
        guard let healthStore = healthStore, isHealthKitAvailable else {
            isHealthKitAuthorized = false
            return
        }
        
        // Check authorization for all types
        let authStatus = typesToRead.map { type in
            healthStore.authorizationStatus(for: type)
        }
        
        // If all types are authorized, we consider HealthKit authorized
        isHealthKitAuthorized = !authStatus.contains(.notDetermined) && 
                                !authStatus.contains(.sharingDenied)
    }
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard isHealthKitAvailable, let healthStore = healthStore else {
            // If HealthKit is not available, fail with appropriate error
            let error = NSError(domain: "HealthKit", 
                                code: 2, 
                                userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"])
            completion(false, error)
            return
        }
        
        isLoading = true
        
        // Create a set of types to read
        let typesToShare: Set<HKSampleType> = []
        let typesToReadSet: Set<HKObjectType> = Set(typesToRead)
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToReadSet) { success, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if success {
                    self.isHealthKitAuthorized = true
                } else {
                    self.error = error
                }
                
                completion(success, error)
            }
        }
    }
    
    // Open Health app
    func openHealthApp() {
        if let url = URL(string: "x-apple-health://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                // Health app is not available, fall back to Settings app
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        }
    }
    
    // Check if Health app is installed
    func isHealthAppInstalled() -> Bool {
        if let url = URL(string: "x-apple-health://") {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    // Get guidance message based on HealthKit status
    func getHealthKitStatusMessage() -> String {
        if !isHealthKitAvailable {
            return "HealthKit is not supported on this device."
        } else if !isHealthAppInstalled() {
            return "The Health app is not available. Please reinstall it to use health features."
        } else if !isHealthKitAuthorized {
            return "Please authorize access to your health data in the Health app or Settings."
        }
        return "Health data access is authorized."
    }
    
    // Fetch health data
    func fetchHealthData(completion: @escaping (Bool) -> Void) {
        guard let healthStore = healthStore, isHealthKitAuthorized else {
            completion(false)
            return
        }
        
        isLoading = true
        
        // Get step count for today
        fetchStepCount { [weak self] success in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.lastSyncDate = Date()
                completion(success)
            }
        }
    }
    
    // Fetch step count for today
    private func fetchStepCount(completion: @escaping (Bool) -> Void) {
        guard let healthStore = healthStore,
              let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(false)
            return
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.error = error
                completion(false)
                return
            }
            
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    self.healthData["steps"] = 0
                }
                completion(true)
                return
            }
            
            let steps = sum.doubleValue(for: HKUnit.count())
            
            DispatchQueue.main.async {
                self.healthData["steps"] = steps
            }
            
            // Once steps are fetched, fetch heart rate
            self.fetchHeartRate {
                completion(true)
            }
        }
        
        healthStore.execute(query)
    }
    
    // Fetch average heart rate for today
    private func fetchHeartRate(completion: @escaping () -> Void) {
        guard let healthStore = healthStore,
              let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion()
            return
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: heartRateType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { [weak self] _, result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching heart rate: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let result = result, let average = result.averageQuantity() else {
                DispatchQueue.main.async {
                    self.healthData["heartRate"] = 0
                }
                completion()
                return
            }
            
            let heartRate = average.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
            
            DispatchQueue.main.async {
                self.healthData["heartRate"] = heartRate
            }
            
            // Fetch active energy next
            self.fetchActiveEnergy {
                completion()
            }
        }
        
        healthStore.execute(query)
    }
    
    // Fetch active energy burned for today
    private func fetchActiveEnergy(completion: @escaping () -> Void) {
        guard let healthStore = healthStore,
              let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion()
            return
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: activeEnergyType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching active energy: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    self.healthData["activeEnergy"] = 0
                }
                completion()
                return
            }
            
            let calories = sum.doubleValue(for: HKUnit.kilocalorie())
            
            DispatchQueue.main.async {
                self.healthData["activeEnergy"] = calories
            }
            
            completion()
        }
        
        healthStore.execute(query)
    }
} 