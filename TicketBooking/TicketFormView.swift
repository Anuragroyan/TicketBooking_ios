//
//  TicketFormView.swift
//  TicketBooking
//
//  Created by Dungeon_master on 09/08/25.
//

import SwiftUI

struct TicketFormView: View {
    @ObservedObject var viewModel: TicketViewModel
    
    // For editing existing or adding new ticket
    @Binding var editingTicket: Ticket?
    
    // Passenger inputs - dynamic list
    @State private var passengers: [PassengerInput] = [PassengerInput()]
    
    // Train details
    @State private var trainNumber = ""
    @State private var origin = ""
    @State private var destination = ""
    @State private var travelDate = Date()
    
    // Card color (default hex color)
    @State private var cardColorHex = "#4CAF50"  // Green
    
    // Alert for validation
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("Passenger Details")) {
                ForEach(passengers.indices, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text("Passenger \(index + 1)")
                            .font(.headline)
                        
                        TextField("Name", text: $passengers[index].name)
                        TextField("Age", text: $passengers[index].age)
                            .keyboardType(.numberPad)
                        TextField("Phone", text: $passengers[index].phone)
                            .keyboardType(.phonePad)
                        
                        if passengers.count > 1 {
                            Button(role: .destructive) {
                                passengers.remove(at: index)
                            } label: {
                                Text("Remove Passenger")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .padding(.top, 2)
                        }
                    }
                    .padding(.vertical, 5)
                }
                
                Button(action: {
                    passengers.append(PassengerInput())
                }) {
                    Label("Add Another Passenger", systemImage: "plus.circle")
                }
            }
            
            Section(header: Text("Train Details")) {
                TextField("Train Number", text: $trainNumber)
                TextField("Origin", text: $origin)
                TextField("Destination", text: $destination)
                DatePicker("Travel Date", selection: $travelDate, displayedComponents: .date)
                TextField("Card Color Hex", text: $cardColorHex)
            }
            
            Section {
                if editingTicket != nil {
                    HStack {
                        Button("Update Ticket") {
                            saveEdits()
                        }
                        .disabled(!validateInputs())
                        .buttonStyle(.borderedProminent)
                        
                        Button("Cancel") {
                            cancelEditing()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                } else {
                    Button("Book Ticket") {
                        if validateInputs() {
                            bookTicket()
                        }
                    }
                    .disabled(!validateInputs())
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .onAppear(perform: loadData)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Validation Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func loadData() {
        if let ticket = editingTicket {
            passengers = ticket.passengers.map { PassengerInput(name: $0.name, age: $0.age, phone: $0.phone) }
            trainNumber = ticket.trainNumber
            origin = ticket.origin
            destination = ticket.destination
            travelDate = ticket.travelDate
            cardColorHex = ticket.cardColorHex
        } else {
            clearForm()
        }
    }
    
    func bookTicket() {
        let passengersData = passengers.map {
            Passenger(name: $0.name, age: $0.age, phone: $0.phone)
        }
        
        let newTicket = Ticket(
            passengers: passengersData,
            passengerCount: passengersData.count,
            trainNumber: trainNumber,
            origin: origin,
            destination: destination,
            travelDate: travelDate,
            cardColorHex: cardColorHex
        )
        
        viewModel.addTicket(newTicket)
        clearForm()
    }
    
    func saveEdits() {
        guard let ticket = editingTicket else { return }
        
        if !validateInputs() { return }
        
        let passengersData = passengers.map {
            Passenger(name: $0.name, age: $0.age, phone: $0.phone)
        }
        
        let updatedTicket = Ticket(
            id: ticket.id,
            passengers: passengersData,
            passengerCount: passengersData.count,
            trainNumber: trainNumber,
            origin: origin,
            destination: destination,
            travelDate: travelDate,
            cardColorHex: cardColorHex
        )
        
        viewModel.updateTicket(updatedTicket)
        clearForm()
        editingTicket = nil
    }
    
    func cancelEditing() {
        clearForm()
        editingTicket = nil
    }
    
    func clearForm() {
        passengers = [PassengerInput()]
        trainNumber = ""
        origin = ""
        destination = ""
        travelDate = Date()
        cardColorHex = "#4CAF50"
    }
    
    func validateInputs() -> Bool {
        for (index, p) in passengers.enumerated() {
            if p.name.trimmingCharacters(in: .whitespaces).isEmpty {
                alertMessage = "Passenger \(index + 1) name cannot be empty."
                showAlert = true
                return false
            }
            if p.age.trimmingCharacters(in: .whitespaces).isEmpty || Int(p.age) == nil {
                alertMessage = "Passenger \(index + 1) age must be a valid number."
                showAlert = true
                return false
            }
            if p.phone.trimmingCharacters(in: .whitespaces).isEmpty || !isValidPhone(p.phone) {
                alertMessage = "Passenger \(index + 1) phone number is invalid."
                showAlert = true
                return false
            }
        }
        
        if trainNumber.trimmingCharacters(in: .whitespaces).isEmpty {
            alertMessage = "Train number cannot be empty."
            showAlert = true
            return false
        }
        if origin.trimmingCharacters(in: .whitespaces).isEmpty {
            alertMessage = "Origin cannot be empty."
            showAlert = true
            return false
        }
        if destination.trimmingCharacters(in: .whitespaces).isEmpty {
            alertMessage = "Destination cannot be empty."
            showAlert = true
            return false
        }
        
        if Color(hex: cardColorHex) == nil {
            alertMessage = "Card color hex is invalid. Use format #RRGGBB."
            showAlert = true
            return false
        }
        
        return true
    }
    
    func isValidPhone(_ phone: String) -> Bool {
        let digits = phone.filter { $0.isNumber }
        return digits.count >= 7 && digits.count <= 15
    }
}

struct PassengerInput {
    var name: String = ""
    var age: String = ""
    var phone: String = ""
}
