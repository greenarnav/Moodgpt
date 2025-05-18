//
//  MoodgptApp.swift
//  Moodgpt
//
//  Created by Test on 5/17/25.
//

import SwiftUI
import HealthKit
import CoreLocation
import Contacts
import EventKit
import UserNotifications
import GoogleSignIn

// Class to handle permission management
class PermissionsManager: NSObject {
    static let shared = PermissionsManager()
    
    private let healthStore = HKHealthStore()
    
    override init() {
        super.init()
        
        // Register usage description keys from GeneratedInfo.swift
        AppInfo.initialize()
        
        // Set up notification observer for permission requests
        NotificationCenter.default.addObserver(forName: NSNotification.Name("RequestPermissions"), 
                                              object: nil, 
                                              queue: .main) { [weak self] _ in
            self?.requestAllPermissions()
        }
    }
    
    func requestAllPermissions() {
        // 0. Request Notification permissions first
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification access granted")
                    // Schedule a test notification
                    self.scheduleWelcomeNotification()
                } else if let error = error {
                    print("Notification access failed: \(error.localizedDescription)")
                }
                
                // 1. Then request Location permissions (will trigger UI prompt)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let locationManager = CLLocationManager()
                    locationManager.requestAlwaysAuthorization()
                    
                    // 2. After location, request Contacts permissions (will trigger UI prompt)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        let contactStore = CNContactStore()
                        contactStore.requestAccess(for: .contacts) { granted, error in
                            DispatchQueue.main.async {
                                if granted {
                                    print("Contacts access granted")
                                } else if let error = error {
                                    print("Contacts access failed: \(error.localizedDescription)")
                                }
                                
                                // 3. After contacts, request Calendar permissions (will trigger UI prompt)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    if #available(iOS 17.0, *) {
                                        let eventStore = EKEventStore()
                                        eventStore.requestFullAccessToEvents { granted, error in
                                            DispatchQueue.main.async {
                                                if granted {
                                                    print("Calendar access granted")
                                                } else if let error = error {
                                                    print("Calendar access failed: \(error.localizedDescription)")
                                                }
                                                
                                                // 4. Finally request HealthKit permissions (will trigger UI prompt)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                    self.requestHealthKitAccess()
                                                }
                                            }
                                        }
                                    } else {
                                        let eventStore = EKEventStore()
                                        eventStore.requestAccess(to: .event) { granted, error in
                                            DispatchQueue.main.async {
                                                if granted {
                                                    print("Calendar access granted")
                                                } else if let error = error {
                                                    print("Calendar access failed: \(error.localizedDescription)")
                                                }
                                                
                                                // 4. Finally request HealthKit permissions (will trigger UI prompt)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                    self.requestHealthKitAccess()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func requestHealthKitAccess() {
        // Use our centralized service
        HealthKitService.shared.requestAuthorization { success, error in
            if success {
                print("HealthKit authorization granted")
            } else if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleWelcomeNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Welcome to MoodGPT!"
        content.body = "Thanks for allowing notifications. We'll keep you updated on your mood insights."
        content.sound = .default
        
        // Deliver after 5 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "welcome", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Welcome notification scheduled")
            }
        }
    }
}

@main
struct MoodgptApp: App {
    @StateObject private var navigationState = NavigationState()
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "onboardingCompleted")
    
    init() {
        // Delay permission requests by 2 seconds to ensure UI is loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            PermissionsManager.shared.requestAllPermissions()
        }
        
        // Configure Google Sign In
        configureGoogleSignIn()
    }
    
    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                OnboardingView(
                    hasCompletedOnboarding: $hasCompletedOnboarding
                )
                .environmentObject(navigationState)
                .onChange(of: hasCompletedOnboarding) { oldValue, newValue in
                    if newValue {
                        // Make sure onboarding completion is saved
                        navigationState.completeOnboarding()
                        
                        // Force update the UI
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }
                }
                // Handle Google Sign In callback URLs
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
            } else {
                MainTabView()
                    .environmentObject(navigationState)
                    .onAppear {
                        setupServices()
                    }
                    // Handle Google Sign In callback URLs
                    .onOpenURL { url in
                        GIDSignIn.sharedInstance.handle(url)
                    }
            }
        }
    }
    
    private func configureGoogleSignIn() {
        // Uncomment and replace with your actual client ID from Google Cloud Console
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: "YOUR_CLIENT_ID")
    }
    
    private func setupServices() {
        // Initialize services safely
        let _ = APIService.shared
        let _ = CitySentimentService.shared
        let _ = NotificationService.shared
        let _ = LocationTrackingService.shared
        let _ = ActivityTrackingService.shared
        let _ = ContactsService.shared
        let _ = CalendarService.shared
        let _ = HealthKitService.shared  // Add our HealthKit service
        let _ = GoogleAuthService.shared // Add our Google Auth service
        
        // Safely set up notification categories without requesting permissions
        NotificationService.shared.setupNotificationCategories()
        
        // Mock notification setup instead of actually scheduling it
        if !UserDefaults.standard.bool(forKey: "initialNotificationSent") {
            print("Would schedule a notification in a real app")
            UserDefaults.standard.set(true, forKey: "initialNotificationSent")
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var navigationState: NavigationState
    @StateObject private var contactService = ContactService()
    @StateObject private var locationService = LocationService()
    
    var body: some View {
        TabView(selection: $navigationState.selectedTab) {
            // Home tab
            NavigationStack(path: $navigationState.path) {
                HomeView(contactService: contactService, locationService: locationService)
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(AppTab.home)
            
            // Maps tab
            NavigationStack(path: $navigationState.path) {
                MapView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label("Maps", systemImage: "map.fill")
            }
            .tag(AppTab.maps)
            
            // Contacts tab
            NavigationStack(path: $navigationState.path) {
                ContactsView(contactService: contactService)
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label("Contacts", systemImage: "person.2.fill")
            }
            .tag(AppTab.contacts)
            
            // Settings tab
            NavigationStack(path: $navigationState.path) {
                SettingsView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(AppTab.settings)
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .cityMood:
            CityMoodView()
        case .activityDetail(let activityId):
            Text("Activity Detail for \(activityId)")
        case .moodTracking:
            Text("Mood Tracking")
        case .settings:
            SettingsView()
        case .contacts:
            ContactsView(contactService: contactService)
        case .notifications:
            Text("Notifications")
        case .help:
            Text("Help")
        case .about:
            Text("About")
        }
    }
}

// These are placeholder views to be implemented later
struct MoodView: View {
    var body: some View {
        Text("Mood View")
            .font(.largeTitle)
    }
}

struct ActivitiesView: View {
    var body: some View {
        Text("Activities View")
            .font(.largeTitle)
    }
}

struct CitiesView: View {
    @EnvironmentObject private var navigationState: NavigationState
    
    var body: some View {
        VStack {
            Text("Cities View")
                .font(.largeTitle)
            
            Button("Go to City Mood") {
                navigationState.navigateTo(.cityMood)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile View")
            .font(.largeTitle)
    }
}
