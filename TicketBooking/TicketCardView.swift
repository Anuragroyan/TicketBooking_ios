//
//  TicketCardView.swift
//  TicketBooking
//

import SwiftUI

struct TicketCardView: View {
    let ticket: Ticket
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            let _: CGFloat = 16 // or 18 for bigger cut
            // 🔵 HEADER
            VStack(alignment: .leading, spacing: 4) {
                Text("PNR: \(ticket.trainNumber)")
                    .font(.headline)
                    .bold()
                
                Text("\(ticket.origin) → \(ticket.destination)")
                    .font(.subheadline)
                    .opacity(0.9)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(hex: ticket.cardColorHex) ?? Color.green)
            .foregroundColor(.white)
            
            Divider()
                    .padding(.bottom, 8) // 👈 space after divider
            
            // ⚪ BODY
            VStack(spacing: 16) {
                
                // 🚆 ROUTE
                HStack {
                    VStack(alignment: .leading) {
                        Text(ticket.origin)
                            .font(.title2)
                            .bold()
                        Text("From")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.left.and.right")
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(ticket.destination)
                            .font(.title2)
                            .bold()
                        Text("To")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Divider()
                
                // 📅 DATE
                HStack {
                    Text("Date")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(formattedDate(ticket.travelDate))
                        .bold()
                }
                
                Divider()
                
                // 👤 PASSENGERS (Expandable)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Passengers: \(ticket.passengerCount)")
                            .font(.headline)
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            isExpanded.toggle()
                        }
                    }
                    
                    if isExpanded {
                        ForEach(ticket.passengers) { passenger in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(passenger.name)
                                    .font(.subheadline)
                                    .bold()
                                
                                Text("Age: \(passenger.age) • \(passenger.phone)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                
                Divider()
                
                // ✂️ PERFORATION LINE
                ZStack {
                    DottedDivider()
                    PerforationCut()
                }
                .padding(.vertical, 6)
                
                // 🎫 BARCODE STYLE
                VStack(spacing: 6) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    (Color(hex: ticket.cardColorHex) ?? .green),
                                    (Color(hex: ticket.cardColorHex) ?? .green).opacity(0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 36)
                        .cornerRadius(4)
                    
                    Text("Show at boarding")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
          
            .padding()
            .background(
                TicketShape()
                    .fill(Color.white, style: FillStyle(eoFill: true)) // ✂️ REAL CUT
            )
            .clipShape(RoundedRectangle(cornerRadius: 16)) // outer rounding
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
    }
    
    // 📅 FORMATTER
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

 // ✂️ Ticket Shape

struct TicketShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius: CGFloat = 12
        
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: 16, height: 16))
        
        // Left cut
        path.addEllipse(in: CGRect(
            x: -radius,
            y: rect.midY - radius,
            width: radius * 2,
            height: radius * 2
        ))
        
        // Right cut
        path.addEllipse(in: CGRect(
            x: rect.maxX - radius,
            y: rect.midY - radius,
            width: radius * 2,
            height: radius * 2
        ))
        
        return path
    }
}

// 🔲 Dotted Divider

struct DottedDivider: View {
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<30, id: \.self) { _ in
                Circle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 4, height: 4)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// ✂️ Perforation Cut

struct PerforationCut: View {
    var body: some View {
        HStack {
            Circle()
                .fill(Color.white) // match card background
                .frame(width: 20, height: 20)
                .offset(x: -10)
            
            Spacer()
            
            Circle()
                .fill(Color.white) // match card background
                .frame(width: 20, height: 20)
                .offset(x: 10)
        }
    }
}
