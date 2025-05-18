import SwiftUI
// import HealthKit

struct SettingsView: View {
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("userCity") private var userCity: String = ""
    @AppStorage("userUsername") private var userUsername: String = ""
    @AppStorage("syncHealthData") private var syncHealthData: Bool = false
    @AppStorage("syncSteps") private var syncSteps: Bool = false
    @AppStorage("syncSleep") private var syncSleep: Bool = false
    @AppStorage("syncMindfulness") private var syncMindfulness: Bool = false
    @AppStorage("syncHeartRate") private var syncHeartRate: Bool = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    @State private var showingAbout = false
    @State private var apiKey: String = ""
    @State private var apiEndpoint: String = "https://api.moodgpt.com/v1"
    @State private var useCustomAPI: Bool = false
    // @State private var healthStore: HKHealthStore?
    @State private var isHealthKitAuthorized = false
    @State private var showHealthPermissionAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    TextField("Your Name", text: $userName)
                        .autocorrectionDisabled()
                    TextField("Username", text: $userUsername)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    TextField("Your City", text: $userCity)
                        .autocorrectionDisabled()
                }
                
                Section(header: Text("Apple Health"), footer: Text("Sync health metrics to enhance mood analysis. Your data remains private and is only used to improve your experience.")) {
                    Toggle("Sync Health Data", isOn: $syncHealthData)
                        .onChange(of: syncHealthData) { newValue in
                            if newValue {
                                // requestHealthAccess()
                                // Temporarily disabled
                            }
                        }
                    
                    if syncHealthData {
                        Toggle("Steps", isOn: $syncSteps)
                            .disabled(true) // Always disabled for now
                        
                        Toggle("Sleep", isOn: $syncSleep)
                            .disabled(true) // Always disabled for now
                        
                        Toggle("Mindfulness", isOn: $syncMindfulness)
                            .disabled(true) // Always disabled for now
                        
                        Toggle("Heart Rate", isOn: $syncHeartRate)
                            .disabled(true) // Always disabled for now
                        
                        Button("Sync Now") {
                            // syncHealthData()
                            // Temporarily disabled
                        }
                        .disabled(true) // Always disabled for now
                    }
                }
                
                Section(header: Text("API Settings"), footer: Text("API integration will be available soon. Enter your credentials here when available.")) {
                    Toggle("Use Custom API", isOn: $useCustomAPI)
                    
                    if useCustomAPI {
                        SecureField("API Key", text: $apiKey)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        
                        TextField("API Endpoint", text: $apiEndpoint)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                        
                        Button("Test Connection") {
                            // This will be implemented when the API is available
                            // For now, just a placeholder
                        }
                        .disabled(true)
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: .constant(true))
                    Toggle("Friend Mood Updates", isOn: .constant(true))
                    Toggle("City Mood Changes", isOn: .constant(true))
                }
                
                Section(header: Text("Privacy")) {
                    Toggle("Share My Mood", isOn: .constant(true))
                    Toggle("Show My Location", isOn: .constant(true))
                }
                
                Section(header: Text("About")) {
                    Button("Privacy Policy") {
                        showingPrivacyPolicy = true
                    }
                    
                    Button("Terms of Service") {
                        showingTermsOfService = true
                    }
                    
                    Button("About MoodGPT") {
                        showingAbout = true
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPrivacyPolicy) {
                LegalView(title: "Privacy Policy", content: privacyPolicyText)
            }
            .sheet(isPresented: $showingTermsOfService) {
                LegalView(title: "Terms of Service", content: termsOfServiceText)
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .alert("Health Permissions Required", isPresented: $showHealthPermissionAlert) {
                Button("Settings", role: .none) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {
                    syncHealthData = false
                }
            } message: {
                Text("Please allow MoodGPT to access health data in your device settings to use this feature.")
            }
            .onAppear {
                // setupHealthKit()
                // Temporarily disabled
            }
        }
    }
    
    // Commented out HealthKit-related functions until the configuration is fixed
    /*
    private func setupHealthKit() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            checkHealthAuthorization()
        }
    }
    
    private func checkHealthAuthorization() {
        guard let healthStore = healthStore else { return }
        
        let typeSet = getHealthDataTypes()
        
        // Check if we already have authorization
        let status = healthStore.authorizationStatus(for: HKObjectType.workoutType())
        if status == .sharingAuthorized {
            isHealthKitAuthorized = true
        }
    }
    
    private func requestHealthAccess() {
        guard let healthStore = healthStore else {
            syncHealthData = false
            return
        }
        
        let typeSet = getHealthDataTypes()
        
        healthStore.requestAuthorization(toShare: [], read: typeSet) { success, error in
            DispatchQueue.main.async {
                if success {
                    isHealthKitAuthorized = true
                } else {
                    isHealthKitAuthorized = false
                    syncHealthData = false
                    showHealthPermissionAlert = true
                }
            }
        }
    }
    
    private func getHealthDataTypes() -> Set<HKObjectType> {
        var typeSet = Set<HKObjectType>()
        
        // Add the health data types we want to access
        if let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount) {
            typeSet.insert(stepsType)
        }
        
        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            typeSet.insert(sleepType)
        }
        
        if let mindfulnessType = HKObjectType.categoryType(forIdentifier: .mindfulSession) {
            typeSet.insert(mindfulnessType)
        }
        
        if let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) {
            typeSet.insert(heartRateType)
        }
        
        return typeSet
    }
    
    private func syncHealthData() {
        guard let healthStore = healthStore, isHealthKitAuthorized else { return }
        
        // Here you would implement the actual syncing logic
        // This is a placeholder for the actual implementation
        
        if syncSteps {
            // Fetch and sync steps data
            fetchStepCount()
        }
        
        if syncSleep {
            // Fetch and sync sleep data
            fetchSleepData()
        }
        
        if syncMindfulness {
            // Fetch and sync mindfulness data
            fetchMindfulnessData()
        }
        
        if syncHeartRate {
            // Fetch and sync heart rate data
            fetchHeartRateData()
        }
    }
    
    // Sample implementations of health data fetching functions
    
    private func fetchStepCount() {
        guard let healthStore = healthStore,
              let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else { return }
            
            let steps = sum.doubleValue(for: HKUnit.count())
            print("Steps today: \(Int(steps))")
            // Here you would send this data to your app's model or API
        }
        
        healthStore.execute(query)
    }
    
    private func fetchSleepData() {
        // Implementation would go here
        print("Fetching sleep data...")
    }
    
    private func fetchMindfulnessData() {
        // Implementation would go here
        print("Fetching mindfulness data...")
    }
    
    private func fetchHeartRateData() {
        // Implementation would go here
        print("Fetching heart rate data...")
    }
    */
}

struct LegalView: View {
    let title: String
    let content: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(content)
                    .padding()
            }
            .navigationTitle(title)
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "face.smiling")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding()
                
                Text("MoodGPT")
                    .font(.largeTitle)
                    .bold()
                
                Text("Feel the pulse of your contacts")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                Text("MoodGPT helps you stay connected with your friends and family by understanding their emotions based on their location. Track moods across cities and reach out when someone needs support.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

// Sample text for privacy policy and terms - in a real app these would be more comprehensive
let privacyPolicyText = """
Privacy Policy

MoodGPT respects your privacy and is committed to protecting your personal data.

We collect information about your contacts and location to provide our service. We use this information to:
- Show the emotional state of cities
- Connect you with your contacts
- Provide personalized experiences

Your data is stored securely and is not shared with third parties without your consent.

You can control what data is shared in the Settings.
"""

let termsOfServiceText = """
Terms of Service

By using MoodGPT, you agree to these terms.

1. You must be at least 13 years old to use MoodGPT.
2. You are responsible for maintaining the confidentiality of your account.
3. You agree not to use MoodGPT for any illegal or unauthorized purpose.
4. We reserve the right to modify or terminate the service for any reason.
5. You are solely responsible for your conduct and content while using MoodGPT.
""" 