//
//  TicketListView.swift
//  TicketBooking
//
//  Created by Dungeon_master on 09/08/25.
//

import SwiftUI

struct TicketListView: View {
    @ObservedObject var viewModel: TicketViewModel
    @Binding var editingTicket: Ticket?
    
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText)
                .padding(.vertical, 5)
                .onChange(of: searchText) { newValue in
                    viewModel.searchText = newValue
                }
            
            List {
                ForEach(viewModel.filteredTickets) { ticket in
                    TicketCardView(ticket: ticket)
                        .onTapGesture {
                            editingTicket = ticket
                        }
                }
                .onDelete(perform: deleteTicket)
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("Booked Tickets")
    }
    
    func deleteTicket(at offsets: IndexSet) {
        offsets.forEach { index in
            let ticket = viewModel.filteredTickets[index]
            viewModel.deleteTicket(ticket)
        }
    }
}
