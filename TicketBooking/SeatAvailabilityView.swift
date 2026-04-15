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
        VStack(spacing: 24) {
            
            // 🧾 HEADER
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "chair.fill") // 🪑 seat icon
                                .font(.title3)
                                .foregroundColor(.blue)
                            
                    Text("Check Seat Availability")
                        .font(.title2)
                        .bold()
                }
                Text("Find available seats for your journey")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // 📦 INPUT CARD
            VStack(spacing: 16) {
                
                // 🚆 Train Number
                VStack(alignment: .leading, spacing: 6) {
                    Text("Train Number")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("Enter train number", text: $trainNumber)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .autocapitalization(.allCharacters)
                }
                
                // 📅 Date Picker
                VStack(alignment: .leading, spacing: 6) {
                    Text("Travel Date")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    DatePicker("", selection: $travelDate, displayedComponents: .date)
                        .labelsHidden()
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                
                // 🔍 BUTTON
                Button(action: {
                    checkSeats()
                }) {
                    HStack {
                        Image(systemName: "chair.fill")
                        
                        Text("Check Availability")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        trainNumber.isEmpty
                        ? AnyShapeStyle(Color.gray.opacity(0.5))
                        : AnyShapeStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(trainNumber.isEmpty)
                
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 10)
            
            // 📊 RESULT CARD
            VStack(spacing: 16) {
                
                if isLoading {
                    ProgressView("Checking seats...")
                }
                
                else if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                }
                
                else {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text("Booked")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Text("\(bookedSeats)")
                                .font(.title2)
                                .bold()
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 6) {
                            HStack {
                                Image(systemName: "chair.fill")
                                Text("Available")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Text("\(max(totalSeats - bookedSeats, 0))")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 10)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
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
