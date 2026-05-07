//
//  EventRegistrationCardView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 02/05/26.
//

import SwiftUI

struct EventRegistrationCardView: View {
    let registration: EventRegistrationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(registration.eventDetail.title)
                        .font(.headline)
                        .bold()
                        .lineLimit(2)
                    Spacer()
                                        
                    Text(registration.status.displayName)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(registration.status.color.opacity(0.1))
                        .foregroundStyle(registration.status.color)
                        .clipShape(Capsule())
                }
                
                Label(registration.eventDetail.location, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Event Date")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    Text(registration.eventDetail.eventDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.footnote)
                        .bold()
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Registered On")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    Text(registration.registeredAt.formatted(date: .numeric, time: .omitted))
                        .font(.footnote)
                }
            }
            
            if let reason = registration.cancelReason {
                Text("Note: \(reason)")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    NavigationStack {
        EventRegistrationListView(registrations: [
            EventRegistrationItem(
                id: "1",
                eventDetail: .init(id: "e1", title: "Latte Art Workshop", location: "Coffio Central", eventDate: Date(), endDate: Date()),
                registeredAt: Date(),
                status: .approved,
                cancelReason: nil,
                menuNotes: nil
            ),
            EventRegistrationItem(
                id: "2",
                eventDetail: .init(id: "e2", title: "Coffee Cupping Session", location: "Beanery Lab", eventDate: Date().addingTimeInterval(86400), endDate: Date()),
                registeredAt: Date(),
                status: .pending,
                cancelReason: nil,
                menuNotes: nil
            ),
            EventRegistrationItem(
                id: "3",
                eventDetail: .init(id: "e3", title: "Barista Championship", location: "Grand Hall", eventDate: Date(), endDate: Date()),
                registeredAt: Date(),
                status: .paymentSubmitted,
                cancelReason: "Waiting for verification",
                menuNotes: nil
            )
        ])
    }
}
