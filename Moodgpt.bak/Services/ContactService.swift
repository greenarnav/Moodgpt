import Foundation
import Contacts
import SwiftUI

class ContactService: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let contactStore = CNContactStore()
    
    func requestAccess() {
        isLoading = true
        contactStore.requestAccess(for: .contacts) { [weak self] granted, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if granted {
                    self.fetchContacts()
                } else {
                    self.error = "Access to contacts was denied"
                    self.isLoading = false
                }
            }
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
                self.error = "Failed to fetch contacts: \(error.localizedDescription)"
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