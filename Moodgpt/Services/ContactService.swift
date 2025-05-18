import Foundation
import Contacts
import SwiftUI
import Combine

class ContactService: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var hasAccessPermission = false
    
    private let contactStore = CNContactStore()
    
    init() {
        // Initialize with placeholder contacts
        self.contacts = [
            Contact(name: "John Smith", phoneNumber: "+1 555-123-4567", city: "San Francisco", emotion: .happy),
            Contact(name: "Amy Lee", phoneNumber: "+1 555-987-6543", city: "New York", emotion: .surprised),
            Contact(name: "Mike Taylor", phoneNumber: "+1 555-456-7890", city: "Chicago", emotion: .neutral),
            Contact(name: "Sarah Johnson", phoneNumber: "+1 555-234-5678", city: "New York", emotion: .happy),
            Contact(name: "David Brown", phoneNumber: "+1 555-876-5432", city: "San Francisco", emotion: .sad),
            Contact(name: "Emily Wilson", phoneNumber: "+1 555-345-6789", city: "Boston", emotion: .fearful),
            Contact(name: "Michael Chen", phoneNumber: "+1 555-654-3210", city: "New York", emotion: .angry),
            Contact(name: "Jessica Martinez", phoneNumber: "+1 555-789-0123", city: "Los Angeles", emotion: .happy)
        ]
        
        // Check initial permission status
        checkPermission()
    }
    
    func checkPermission() {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authorizationStatus {
        case .authorized:
            self.hasAccessPermission = true
        case .denied, .restricted, .notDetermined:
            self.hasAccessPermission = false
        case .limited:
            self.hasAccessPermission = true
        @unknown default:
            self.hasAccessPermission = false
        }
    }
    
    func requestAccess() {
        isLoading = true
        
        contactStore.requestAccess(for: .contacts) { [weak self] granted, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.error = error
                    return
                }
                
                self.hasAccessPermission = granted
                
                if granted {
                    // Access granted, but we'll wait for user to initiate sync
                    print("Contact access granted")
                }
            }
        }
    }
    
    // Method to update contacts with synced contacts from device
    func updateContacts(_ newContacts: [Contact]) {
        // If we receive new contacts, update our list
        // In a real app, you might want to merge with existing contacts rather than replace
        if !newContacts.isEmpty {
            self.contacts = newContacts
        }
    }
    
    private func fetchContacts() {
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        do {
            var fetchedContacts: [Contact] = []
            
            try contactStore.enumerateContacts(with: request) { cnContact, _ in
                let phoneNumbers = cnContact.phoneNumbers.compactMap { $0.value.stringValue }
                
                if let phoneNumber = phoneNumbers.first {
                    let fullName = "\(cnContact.givenName) \(cnContact.familyName)".trimmingCharacters(in: .whitespacesAndNewlines)
                    let contact = Contact(
                        name: fullName,
                        phoneNumber: phoneNumber,
                        emotion: self.randomEmotion() // For demo purposes, assign random emotions
                    )
                    
                    if let areaCode = contact.areaCode, let city = CityMood.getCityFromAreaCode(areaCode) {
                        var updatedContact = contact
                        updatedContact.city = city
                        fetchedContacts.append(updatedContact)
                    } else {
                        fetchedContacts.append(contact)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.contacts = fetchedContacts
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    // For demo purposes
    private func randomEmotion() -> Emotion {
        let emotions = Emotion.allCases
        return emotions.randomElement()!
    }
    
    func updateContactEmotion(for contactId: UUID, with emotion: Emotion) {
        if let index = contacts.firstIndex(where: { $0.id == contactId }) {
            contacts[index].emotion = emotion
        }
    }
    
    func randomizeContactOrder() {
        contacts.shuffle()
    }
}

// Extension for more sophisticated contacts functionality
extension ContactService {
    func getContactsInCity(_ city: String) -> [Contact] {
        return contacts.filter { $0.city == city }
    }
    
    func getDominantEmotionInCity(_ city: String) -> Emotion? {
        let cityContacts = getContactsInCity(city)
        var emotionCount: [Emotion: Int] = [:]
        
        // Count occurrences of each emotion
        for contact in cityContacts {
            emotionCount[contact.emotion, default: 0] += 1
        }
        
        // Return the most common emotion
        return emotionCount.max(by: { $0.value < $1.value })?.key
    }
    
    func getTopCities(limit: Int = 5) -> [(city: String, count: Int)] {
        var cityCount: [String: Int] = [:]
        
        // Count contacts in each city
        for contact in contacts where contact.city != nil {
            cityCount[contact.city!, default: 0] += 1
        }
        
        // Convert to array and sort
        let sortedCities = cityCount.map { (city: $0.key, count: $0.value) }
            .sorted(by: { $0.count > $1.count })
        
        // Return top N cities
        return sortedCities.prefix(limit).map { $0 }
    }
} 