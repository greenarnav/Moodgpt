import SwiftUI
import Combine

struct ContactsView: View {
    @ObservedObject var contactService: ContactService
    @State private var searchText = ""
    @State private var selectedFilter: Emotion? = nil
    @State private var isShowingContactDetail = false
    @State private var selectedContact: Contact? = nil
    
    private var filteredContacts: [Contact] {
        var filtered = contactService.contacts
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.city?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        if let filter = selectedFilter {
            filtered = filtered.filter { $0.emotion == filter }
        }
        
        return filtered
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            searchBar
            
            // Emotion filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation {
                            selectedFilter = nil
                        }
                    }) {
                        Text("All")
                            .font(.subheadline)
                            .fontWeight(selectedFilter == nil ? .bold : .medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedFilter == nil ? Color.blue : Color.gray.opacity(0.1))
                            )
                            .foregroundColor(selectedFilter == nil ? .white : .primary)
                    }
                    
                    ForEach(Emotion.allCases, id: \.self) { emotion in
                        Button(action: {
                            withAnimation {
                                selectedFilter = emotion
                            }
                        }) {
                            HStack {
                                StaticEmojiView(emotion: emotion, size: 24)
                                
                                Text(emotion.description)
                                    .font(.subheadline)
                                    .fontWeight(selectedFilter == emotion ? .bold : .medium)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedFilter == emotion ? emotion.color.opacity(0.8) : Color.gray.opacity(0.1))
                            )
                            .foregroundColor(selectedFilter == emotion ? .white : .primary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
            
            // Content
            if contactService.contacts.isEmpty {
                VStack(spacing: 24) {
                    Image(systemName: "person.crop.circle.badge.xmark")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Contacts Found")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Your contacts will appear here once you add them.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: {
                        // Add contact action
                    }) {
                        Text("Add Contact")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue)
                            )
                    }
                    .padding(.top, 8)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                
            } else if filteredContacts.isEmpty {
                VStack(spacing: 24) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Results")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Try adjusting your search or filters to find what you're looking for.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: {
                        withAnimation {
                            searchText = ""
                            selectedFilter = nil
                        }
                    }) {
                        Text("Clear Filters")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue)
                            )
                    }
                    .padding(.top, 8)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
                
            } else {
                List {
                    ForEach(filteredContacts) { contact in
                        ContactListItem(contact: contact, onSelect: {
                            selectedContact = contact
                            isShowingContactDetail = true
                        })
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Contacts")
        .navigationBarItems(trailing:
            Button(action: {
                // Add contact action
            }) {
                Image(systemName: "plus")
                    .font(.title3)
            }
        )
        .sheet(isPresented: $isShowingContactDetail) {
            if let contact = selectedContact {
                DetailedContactView(contact: contact)
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search contacts", text: $searchText)
                .foregroundColor(.primary)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct ContactListItem: View {
    let contact: Contact
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(contact.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let city = contact.city {
                        Text(city)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Text("Mood:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(contact.emotion.description)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(contact.emotion.color)
                    }
                }
                
                Spacer()
                
                StaticEmojiView(emotion: contact.emotion, size: 40)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
} 