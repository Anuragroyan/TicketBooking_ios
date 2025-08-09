import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = TicketViewModel()
    @State private var editingTicket: Ticket? = nil
    @State private var showingForm = false
    
    var body: some View {
        NavigationView {
            VStack {
                if showingForm {
                    TicketFormView(viewModel: viewModel, editingTicket: $editingTicket)
                } else {
                    TicketListView(viewModel: viewModel, editingTicket: $editingTicket)
                }
            }
            .navigationBarTitle(showingForm ? (editingTicket == nil ? "Book Ticket" : "Edit Ticket") : "Booked Tickets", displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if showingForm {
                        Button("Cancel") {
                            editingTicket = nil
                            showingForm = false
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if !showingForm {
                        HStack(spacing: 16) {
                            NavigationLink(destination: SeatAvailabilityView()) {
                                Image(systemName: "chair")
                                    .imageScale(.large)
                                    .accessibilityLabel("Check Seat Availability")
                            }
                            
                            Button {
                                editingTicket = nil
                                showingForm = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }

            .onChange(of: editingTicket) { oldValue, newValue in
                if newValue != nil {
                    showingForm = true
                }
            }
        }
    }
}
