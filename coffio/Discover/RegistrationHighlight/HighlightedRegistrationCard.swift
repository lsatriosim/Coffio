//
//  HighlightedRegistrationCard.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 09/08/26.
//

import SwiftUI

struct HighlightedRegistrationCard: View {
    let registration: EventRegistrationItem
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Top Header Badge + Status
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.badge.exclamationmark.fill")
                            .font(.caption)
                        Text(registration.status.displayName)
                            .font(.caption)
                            .bold()
                    }
                    .foregroundStyle(Color(hex: "642e13"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(hex: "fcede1"))
                    .clipShape(Capsule())

                    Spacer()

                    // Action prompt
                    HStack(spacing: 4) {
                        Text("Complete Payment")
                            .font(.caption)
                            .bold()
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .bold()
                    }
                    .foregroundStyle(Color(hex: "ad6928"))
                }

                // Event Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(registration.eventDetail.title)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(Color(hex: "642e13"))
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption2)
                        Text(registration.eventDetail.location)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    .foregroundStyle(Color(hex: "ad6928"))
                }

                Divider()
                    .background(Color(hex: "ad6928").opacity(0.2))

                // Live Timer Bar
                if let deadline = registration.paymentDeadlineAt {
                    TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
                        HStack {
                            Text("Payment Expires In")
                                .font(.caption)
                                .foregroundStyle(Color(hex: "642e13").opacity(0.8))

                            Spacer()

                            Text(timeRemainingString(until: deadline, relativeTo: timeline.date))
                                .font(.callout)
                                .fontDesign(.monospaced)
                                .bold()
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "ad6928").opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func timeRemainingString(until deadline: Date, relativeTo currentDate: Date) -> String {
        let remaining = deadline.timeIntervalSince(currentDate)
        guard remaining > 0 else { return "00:00:00" }

        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        let seconds = Int(remaining) % 60

        if hours > 0 {
            return String(format: "%02dh %02dm %02ds", hours, minutes, seconds)
        } else {
            return String(format: "%02dm %02ds", minutes, seconds)
        }
    }
}
