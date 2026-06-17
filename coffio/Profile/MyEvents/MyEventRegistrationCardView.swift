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
