import SwiftUI
import HealthKit
import GoogleSignIn

struct SettingsView: View {
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("userCity") private var userCity: String = ""
    @AppStorage("userUsername") private var userUsername: String = ""
    @AppStorage("userEmail") private var userEmail: String = ""
    @AppStorage("isGoogleSignIn") private var isGoogleSignIn: Bool = false
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
    @State private var showHealthPermissionAlert = false
    @State private var showHealthDataModal = false
    @State private var isSyncing = false
    @State private var showGoogleSignInAlert = false
    @State private var googleAlertMessage = ""
    @State private var isShowingGoogleActions = false
    
    // Services
    @StateObject private var healthService = HealthKitService.shared
    @StateObject private var googleAuthService = GoogleAuthService.shared
    
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
                    
                    if !userEmail.isEmpty {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(userEmail)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Google Account Section
                    accountSection
                }
                
                Section(header: Text("Apple Health"), footer: healthDataFooter) {
                    Toggle("Sync Health Data", isOn: $syncHealthData)
                        .onChange(of: syncHealthData) { newValue in
                            if newValue {
                                requestHealthAccess()
                            }
                        }
                    
                    if syncHealthData {
                        Toggle("Steps", isOn: $syncSteps)
                            .disabled(!healthService.isHealthKitAuthorized)
                        
                        Toggle("Sleep", isOn: $syncSleep)
                            .disabled(!healthService.isHealthKitAuthorized)
                        
                        Toggle("Mindfulness", isOn: $syncMindfulness)
                            .disabled(!healthService.isHealthKitAuthorized)
                        
                        Toggle("Heart Rate", isOn: $syncHeartRate)
                            .disabled(!healthService.isHealthKitAuthorized)
                        
                        // Button to sync data
                        Button(action: syncHealthDataNow) {
                            HStack {
                                Text("Sync Health Data Now")
                                Spacer()
                                if isSyncing {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(!healthService.isHealthKitAuthorized || isSyncing)
                        
                        // Button to open Health app directly
                        Button(action: {
                            healthService.openHealthApp()
                        }) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("Open Apple Health App")
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                            }
                        }
                        
                        // Button to view synced data
                        Button(action: {
                            showHealthDataModal = true
                        }) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                Text("View Synced Health Data")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                        }
                        .disabled(healthService.healthData.isEmpty)
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
            .sheet(isPresented: $showHealthDataModal) {
                HealthDataView(healthService: healthService)
            }
            .alert("Health Permissions Required", isPresented: $showHealthPermissionAlert) {
                Button("Open Health App", role: .none) {
                    healthService.openHealthApp()
                }
                Button("Open Settings", role: .none) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {
                    syncHealthData = false
                }
            } message: {
                Text("Please allow MoodGPT to access health data in the Health app or device settings to use this feature.")
            }
            .alert(isPresented: $showGoogleSignInAlert) {
                Alert(
                    title: Text(isGoogleSignIn ? "Google Account" : "Google Sign In"),
                    message: Text(googleAlertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .actionSheet(isPresented: $isShowingGoogleActions) {
                ActionSheet(
                    title: Text("Google Account"),
                    message: Text("You are signed in with Google as \(userEmail)"),
                    buttons: [
                        .destructive(Text("Sign Out")) {
                            signOutFromGoogle()
                        },
                        .cancel()
                    ]
                )
            }
            .onAppear {
                // Check if we have health authorization on view appear
                if syncHealthData && !healthService.isHealthKitAuthorized {
                    healthService.checkAuthorizationStatus()
                }
                
                // Check Google Sign In status
                if isGoogleSignIn {
                    googleAuthService.restorePreviousSignIn()
                }
            }
        }
    }
    
    // Google account section
    private var accountSection: some View {
        Group {
            if isGoogleSignIn {
                Button(action: {
                    isShowingGoogleActions = true
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .foregroundColor(.blue)
                        Text("Google Account")
                        Spacer()
                        Text("Connected")
                            .foregroundColor(.green)
                    }
                }
            } else {
                Button(action: signInWithGoogle) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .foregroundColor(.gray)
                        Text("Connect Google Account")
                        Spacer()
                        Image(systemName: "arrow.right.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    
    private var healthDataFooter: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Sync health metrics to enhance mood analysis. Your data remains private and is only used to improve your experience.")
            
            if syncHealthData {
                Text(healthService.getHealthKitStatusMessage())
                    .foregroundColor(healthService.isHealthKitAuthorized ? .green : .orange)
                    .padding(.top, 3)
            }
            
            if let lastSync = healthService.lastSyncDate {
                Text("Last sync: \(lastSync, formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 3)
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    private func requestHealthAccess() {
        healthService.requestAuthorization { success, error in
            if !success {
                DispatchQueue.main.async {
                    syncHealthData = false
                    showHealthPermissionAlert = true
                }
            }
        }
    }
    
    private func syncHealthDataNow() {
        isSyncing = true
        healthService.fetchHealthData { success in
            DispatchQueue.main.async {
                isSyncing = false
                if !success {
                    showHealthPermissionAlert = true
                }
            }
        }
    }
    
    // MARK: - Google Sign In Methods
    
    private func signInWithGoogle() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            googleAlertMessage = "Cannot access root view controller"
            showGoogleSignInAlert = true
            return
        }
        
        googleAuthService.signIn(presentingViewController: rootViewController) { success in
            if success {
                if let email = googleAuthService.currentUser?.profile?.email {
                    userEmail = email
                }
                if let name = googleAuthService.currentUser?.profile?.name, userName.isEmpty {
                    userName = name
                }
                isGoogleSignIn = true
            } else {
                if let error = googleAuthService.error {
                    googleAlertMessage = "Sign-in failed: \(error.localizedDescription)"
                } else {
                    googleAlertMessage = "Sign-in was cancelled or failed"
                }
                showGoogleSignInAlert = true
            }
        }
    }
    
    private func signOutFromGoogle() {
        googleAuthService.signOut { success in
            if success {
                isGoogleSignIn = false
                googleAlertMessage = "Successfully signed out from Google"
                showGoogleSignInAlert = true
            } else {
                googleAlertMessage = "Failed to sign out from Google"
                showGoogleSignInAlert = true
            }
        }
    }
}

// View to display the synced health data
struct HealthDataView: View {
    @ObservedObject var healthService: HealthKitService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                if healthService.healthData.isEmpty {
                    Text("No health data has been synced yet.")
                        .foregroundColor(.secondary)
                } else {
                    healthDataSection
                }
            }
            .navigationTitle("Health Data")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        healthService.fetchHealthData { _ in }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(healthService.isLoading)
                }
            }
        }
    }
    
    private var healthDataSection: some View {
        Group {
            if let steps = healthService.healthData["steps"] {
                HealthDataRow(
                    icon: "figure.walk",
                    title: "Steps",
                    value: "\(Int(steps))",
                    color: .green
                )
            }
            
            if let heartRate = healthService.healthData["heartRate"] {
                HealthDataRow(
                    icon: "heart.fill",
                    title: "Heart Rate",
                    value: "\(Int(heartRate)) BPM",
                    color: .red
                )
            }
            
            if let energy = healthService.healthData["activeEnergy"] {
                HealthDataRow(
                    icon: "flame.fill",
                    title: "Active Energy",
                    value: "\(Int(energy)) kcal",
                    color: .orange
                )
            }
            
            Section(header: Text("Last Updated")) {
                if let lastSync = healthService.lastSyncDate {
                    Text(lastSync, style: .date)
                    Text(lastSync, style: .time)
                }
            }
        }
    }
}

struct HealthDataRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 24))
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                
                Text(value)
                    .font(.title2)
                    .bold()
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
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