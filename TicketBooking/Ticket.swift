//
//  Ticket.swift
//  TicketBooking
//
//  Created by Dungeon_master on 09/08/25.
//

import Foundation
import FirebaseFirestoreSwift

struct Passenger: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var age: String
    var phone: String
}

struct Ticket: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var passengers: [Passenger]
    var passengerCount: Int
    
    var trainNumber: String
    var origin: String
    var destination: String
    var travelDate: Date
    
    var cardColorHex: String
}


