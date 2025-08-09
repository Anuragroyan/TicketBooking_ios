//
//  TicketViewModel.swift
//  TicketBooking
//
//  Created by Dungeon_master on 09/08/25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class TicketViewModel: ObservableObject {
    @Published var tickets = [Ticket]()
    @Published var searchText = ""
    
    private var db = Firestore.firestore()
    
    init() {
        fetchTickets()
    }
    
    func fetchTickets() {
        db.collection("tickets")
            .order(by: "travelDate", descending: false)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting tickets: \(error.localizedDescription)")
                    return
                }
                
                self.tickets = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Ticket.self)
                } ?? []
            }
    }
    
    func addTicket(_ ticket: Ticket) {
        do {
            _ = try db.collection("tickets").addDocument(from: ticket)
        } catch {
            print("Error adding ticket: \(error.localizedDescription)")
        }
    }
    
    func updateTicket(_ ticket: Ticket) {
        guard let id = ticket.id else { return }
        do {
            try db.collection("tickets").document(id).setData(from: ticket)
        } catch {
            print("Error updating ticket: \(error.localizedDescription)")
        }
    }
    
    func deleteTicket(_ ticket: Ticket) {
        guard let id = ticket.id else { return }
        db.collection("tickets").document(id).delete { error in
            if let error = error {
                print("Error deleting ticket: \(error.localizedDescription)")
            }
        }
    }
    
    var filteredTickets: [Ticket] {
        if searchText.isEmpty {
            return tickets
        } else {
            return tickets.filter {
                $0.passengers.contains(where: { $0.name.localizedCaseInsensitiveContains(searchText) }) ||
                $0.trainNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}
