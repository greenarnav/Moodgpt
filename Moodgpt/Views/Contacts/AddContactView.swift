import SwiftUI
import Combine

struct AddContactView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var contactService: ContactService
    
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var city: String = ""
    @State private var notes: String = ""
    @State private var selectedCountryCode: String = "1" // Default to US
    @State private var nationalNumber: String = ""
    @State private var showingCountryPicker = false
    
    @State private var formattedPhonePreview: String = ""
    @State private var isValidPhone: Bool = true
    
    private var isValidForm: Bool {
        return !name.isEmpty && !phoneNumber.isEmpty && isValidPhone
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Contact Information")) {
                    TextField("Name", text: $name)
                        .autocapitalization(.words)
                    
                    // Phone number with country code
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phone Number")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            // Country code selector
                            Button(action: {
                                showingCountryPicker = true
                            }) {
                                HStack {
                                    if let countryInfo = getCountryInfo(for: selectedCountryCode) {
                                        Text(countryInfo.flag)
                                            .font(.title2)
                                    }
                                    
                                    Text("+\(selectedCountryCode)")
                                        .foregroundColor(.primary)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                            
                            TextField("Phone number", text: $nationalNumber)
                                .keyboardType(.phonePad)
                                .onChange(of: nationalNumber) { _ in
                                    updatePhoneNumber()
                                }
                        }
                        
                        // Preview of formatted number
                        if !phoneNumber.isEmpty {
                            Text(formattedPhonePreview)
                                .font(.footnote)
                                .foregroundColor(isValidPhone ? .green : .red)
                                .padding(.top, 4)
                        }
                    }
                    
                    TextField("City", text: $city)
                    
                    TextField("Notes", text: $notes)
                        .lineLimit(3)
                }
                
                if !isValidPhone && !phoneNumber.isEmpty {
                    Section {
                        Text("Please enter a valid phone number")
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Add Contact")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveContact()
                    }
                    .disabled(!isValidForm)
                    .font(.headline)
                }
            }
            .sheet(isPresented: $showingCountryPicker) {
                CountryCodePickerView(selectedCountryCode: $selectedCountryCode, onDismiss: {
                    showingCountryPicker = false
                    updatePhoneNumber()
                })
            }
            .onAppear {
                // Update phone preview on appear
                updatePhoneNumber()
            }
        }
    }
    
    private func updatePhoneNumber() {
        // Construct the phone number with country code
        phoneNumber = "+\(selectedCountryCode)\(nationalNumber)"
        
        // Update the formatted preview
        formattedPhonePreview = PhoneNumberHelper.formatPhoneNumber(phoneNumber)
        
        // Validate the phone number
        isValidPhone = PhoneNumberHelper.isValidPhoneNumber(phoneNumber)
    }
    
    private func getCountryInfo(for code: String) -> (flag: String, pattern: String)? {
        return PhoneNumberHelper.countryCodes[code]
    }
    
    private func saveContact() {
        let newContact = Contact(
            name: name,
            phoneNumber: phoneNumber,
            city: city.isEmpty ? nil : city,
            emotion: .neutral,
            notes: notes.isEmpty ? nil : notes
        )
        
        contactService.contacts.append(newContact)
        dismiss()
    }
}

struct CountryCodePickerView: View {
    @Binding var selectedCountryCode: String
    var onDismiss: () -> Void
    
    @State private var searchText = ""
    
    // Filter country codes based on search
    private var filteredCountryCodes: [(code: String, flag: String, name: String)] {
        let countryData = PhoneNumberHelper.countryCodes.map { (code, info) in
            (code: code, flag: info.flag, name: getCountryName(for: code))
        }
        
        if searchText.isEmpty {
            return countryData.sorted { $0.name < $1.name }
        } else {
            return countryData.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.code.contains(searchText)
            }.sorted { $0.name < $1.name }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredCountryCodes, id: \.code) { countryInfo in
                    Button(action: {
                        selectedCountryCode = countryInfo.code
                        onDismiss()
                    }) {
                        HStack {
                            Text(countryInfo.flag)
                                .font(.title2)
                            
                            Text(countryInfo.name)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("+\(countryInfo.code)")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                            
                            if selectedCountryCode == countryInfo.code {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search countries")
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
    
    // Map country code to country name
    private func getCountryName(for countryCode: String) -> String {
        switch countryCode {
        case "1": return "United States/Canada"
        case "44": return "United Kingdom"
        case "91": return "India"
        case "86": return "China"
        case "49": return "Germany"
        case "33": return "France"
        case "61": return "Australia"
        case "81": return "Japan"
        case "7": return "Russia"
        case "55": return "Brazil"
        case "82": return "South Korea"
        case "39": return "Italy"
        case "34": return "Spain"
        case "52": return "Mexico"
        case "31": return "Netherlands"
        case "90": return "Turkey"
        case "966": return "Saudi Arabia"
        case "65": return "Singapore"
        case "971": return "United Arab Emirates"
        case "27": return "South Africa"
        default: return "Country +\(countryCode)"
        }
    }
} 