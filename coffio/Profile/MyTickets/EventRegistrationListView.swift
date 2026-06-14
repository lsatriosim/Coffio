//
//  EventRegistrationListView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 02/05/26.
//

import SwiftUI

struct EventRegistrationListView: View {
    let registrations: [EventRegistrationItem]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(registrations, id: \.id) { item in
                    NavigationLink {
                        // Destination to Detail or Status Tracking
                        Text("Registration Detail for \(item.id)")
                    } label: {
                        EventRegistrationCardView(registration: item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .navigationTitle("My Registrations")
        .background(Color(hex: "f2efed")) // Matching your sheet background
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
