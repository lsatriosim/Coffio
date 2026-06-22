//
//  MyEventRegistrationCardView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/06/26.
//

import SwiftUI

struct MyEventRegistrationCardView: View {
    let registration: EventRegistrationItem
    let isProcessing: Bool
    var onApprove: () -> Void
    var onReject: () -> Void
    var onShowProof: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(registration.userProfile.safeName)
                        .font(.headline).bold()
                    Text(registration.userProfile.safeEmail)
                        .font(.subheadline).foregroundStyle(.gray)
                }
                Spacer()
                
                Text(registration.status.displayName)
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(registration.status.color.opacity(0.1))
                    .foregroundStyle(registration.status.color)
                    .clipShape(Capsule())
            }
            
            if let phone = registration.userProfile.phone, !phone.isEmpty {
                Button {
                    openWhatsAppToParticipant(
                        phone: phone,
                        participantName: registration.userProfile.safeName,
                        eventTitle: registration.eventDetail.title
                    )
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 11))
                        Text(phone)
                            .font(.subheadline)
                            .underline()
                    }
                    .foregroundStyle(Color(hex: "ad6928"))
                    .padding(.top, 2)
                }
                .buttonStyle(.plain)
            }
            
            // Context Notes Block
            if let notes = registration.menuNotes, !notes.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    Label("Menu Selection Notes", systemImage: "fork.knife")
                        .font(.caption2).bold().foregroundStyle(Color(hex: "ad6928"))
                    Text(notes).font(.footnote).foregroundStyle(.primary)
                }
            }
            
            if let referralCode = registration.referralCode {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    Label("Referral Code", systemImage: "person.3")
                        .font(.caption2).bold().foregroundStyle(Color(hex: "ad6928"))
                    Text(referralCode).font(.footnote).foregroundStyle(.primary)
                }
            }
            
            // ACTION BLOCK: Appears when status is paymentSubmitted
            if registration.status == .paymentSubmitted || registration.status == .approved {
                Divider()
                HStack(spacing: 12) {
                    Text(registration.status == .paymentSubmitted ? "Review Payment Action Required" : "Check payment proof")
                        .font(.caption).bold().foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if isProcessing {
                        ProgressView()
                            .tint(Color(hex: "ad6928"))
                            .frame(height: 36)
                    } else {
                        // 1. See Payment Proof Button
                        CircleIconButton(systemImage: "doc.text.viewfinder", color: .blue, action: onShowProof)
                        
                        if registration.status == .paymentSubmitted {
                            // 2. Reject Action Button
                            CircleIconButton(systemImage: "xmark", color: .red, action: onReject)
                            
                            // 3. Approve Action Button
                            CircleIconButton(systemImage: "checkmark", color: .green, action: onApprove)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
    
    private func openWhatsAppToParticipant(phone: String, participantName: String, eventTitle: String) {
        // Build your precise message template structure
        let rawMessage = "Hi \(participantName), I'm the host for \(eventTitle). I would like to "
        
        // Escape spaces and special string blocks for safe URL streaming
        guard let encodedMessage = rawMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        
        // Clean non-digit characters out of the target string format
        let cleanPhone = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        let urlString = "https://wa.me/\(cleanPhone)?text=\(encodedMessage)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

struct CircleIconButton: View {
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.1))
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
