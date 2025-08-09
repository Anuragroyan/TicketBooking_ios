//
//  TicketCardView.swift
//  TicketBooking
//
//  Created by Dungeon_master on 09/08/25.
//

import SwiftUI

struct TicketCardView: View {
    let ticket: Ticket
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Passengers: \(ticket.passengerCount)")
                .font(.headline)
                .bold()
            
            ForEach(ticket.passengers) { passenger in
                VStack(alignment: .leading, spacing: 2) {
                    Text(passenger.name)
                        .font(.subheadline)
                        .bold()
                    Text("Age: \(passenger.age), Phone: \(passenger.phone)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.vertical, 2)
            }
            
            Divider()
                .background(Color.white.opacity(0.7))
            
            HStack {
                Text("Train No: \(ticket.trainNumber)")
                Spacer()
                Text("\(ticket.origin) → \(ticket.destination)")
            }
            .font(.subheadline)
            
            Text("Date: \(formattedDate(ticket.travelDate))")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(Color(hex: ticket.cardColorHex) ?? Color.green)
        .cornerRadius(12)
        .foregroundColor(.white)
        .shadow(radius: 4)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
