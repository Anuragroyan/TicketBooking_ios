//
//  SeatAvailabilityView.swift
//  TicketBooking
//
//  Created by Dungeon_master on 09/08/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct SeatAvailabilityView: View {
    @State private var trainNumber = ""
    @State private var travelDate = Date()
    @State private var bookedSeats = 0
    @State private var totalSeats = 100 // Example capacity
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Check Seat Availability")
                .font(.title2)
                .bold()
            
            TextField("Train Number", text: $trainNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.allCharacters) // Use this instead of .textInputAutocapitalization(.allCharacters) for older iOS
            
            DatePicker("Travel Date", selection: $travelDate, displayedComponents: .date)
                .padding(.horizontal)
            
            Button("Check Availability") {
                checkSeats()
            }
            .buttonStyle(.borderedProminent)
            .disabled(trainNumber.isEmpty)
            
            if isLoading {
                ProgressView()
            } else if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                Text("Booked Seats: \(bookedSeats)")
                Text("Available Seats: \(max(totalSeats - bookedSeats, 0))")
                    .bold()
                    .foregroundColor(.green)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func checkSeats() {
        isLoading = true
        errorMessage = ""
        bookedSeats = 0
        
        let db = Firestore.firestore()
        
        db.collection("tickets")
            .whereField("trainNumber", isEqualTo: trainNumber.uppercased())
            .getDocuments { snapshot, error in
                isLoading = false
                
                if let error = error {
                    errorMessage = "Error fetching data: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    errorMessage = "No bookings found."
                    return
                }
                
                // Filter tickets by travel date (ignoring time)
                let calendar = Calendar.current
                let filteredTickets = documents.compactMap { doc -> Ticket? in
                    try? doc.data(as: Ticket.self)
                }.filter { ticket in
                    calendar.isDate(ticket.travelDate, inSameDayAs: travelDate)
                }
                
                bookedSeats = filteredTickets.reduce(0) { $0 + $1.passengerCount }
            }
    }
}
