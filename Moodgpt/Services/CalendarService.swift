import Foundation
import EventKit
import Combine

class CalendarService: ObservableObject {
    static let shared = CalendarService()
    
    private let eventStore = EKEventStore()
    @Published var accessGranted = false
    @Published var events: [EKEvent] = []
    
    private init() {
        checkCalendarAuthorization()
    }
    
    func checkCalendarAuthorization() {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized:
            self.accessGranted = true
            self.fetchEvents()
        case .notDetermined:
            requestAccess()
        case .denied, .restricted:
            self.accessGranted = false
        case .fullAccess:
            self.accessGranted = true
            self.fetchEvents()
        case .writeOnly:
            // We need read access, so this isn't enough
            self.accessGranted = false
        @unknown default:
            self.accessGranted = false
        }
    }
    
    func requestAccess() {
        if #available(iOS 17.0, *) {
            // Use the new API on iOS 17+
            eventStore.requestFullAccessToEvents { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.accessGranted = granted
                    if granted {
                        self?.fetchEvents()
                    }
                }
            }
        } else {
            // Use the deprecated API on older versions
            eventStore.requestAccess(to: .event) { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.accessGranted = granted
                    if granted {
                        self?.fetchEvents()
                    }
                }
            }
        }
    }
    
    func fetchEvents() {
        guard accessGranted else { return }
        
        // Get the calendar for events
        let calendars = eventStore.calendars(for: .event)
        
        // Create a predicate for events from now to one week from now
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate)!
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        
        // Fetch events using the predicate
        let ekEvents = eventStore.events(matching: predicate)
        
        DispatchQueue.main.async {
            self.events = ekEvents
        }
    }
    
    // Get events for today
    func getEventsForToday() -> [EKEvent] {
        guard accessGranted else { return [] }
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let calendars = eventStore.calendars(for: .event)
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: calendars)
        
        return eventStore.events(matching: predicate)
    }
    
    // Helper method to correlate events with mood
    func correlateEventsWithMood() -> String {
        let todayEvents = getEventsForToday()
        
        // In a real app, you would analyze events and moods
        // Here, we'll return a simulated insight
        if todayEvents.isEmpty {
            return "No events today - how does a clear schedule affect your mood?"
        } else if todayEvents.count > 3 {
            return "You have a busy day with \(todayEvents.count) events. This might impact your stress levels."
        } else {
            return "You have a balanced schedule today with \(todayEvents.count) events."
        }
    }
} 