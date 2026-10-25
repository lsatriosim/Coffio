//
//  DiscoverInternalGuestCardView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 30/08/26.
//

import SwiftUI

struct DiscoverInternalGuestCardView: View {
    let guest: DiscoverInternalGuestItem
    var onEdit: () -> Void
    var onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(guest.guestName)
                        .font(.headline).bold()
                    if let email = guest.guestEmail, !email.isEmpty {
                        Text(email)
                            .font(.subheadline).foregroundStyle(.gray)
                    }
                }
                Spacer()
                
                // Badge Status / Tipe Internal
                Text("Internal")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color(hex: "ad6928").opacity(0.1))
                    .foregroundStyle(Color(hex: "ad6928"))
                    .clipShape(Capsule())
            }
            
            if let phone = guest.guestPhone, !phone.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 11))
                    Text(phone)
                        .font(.subheadline)
                }
                .foregroundStyle(.secondary)
                .padding(.top, 2)
            }
            
            if let notes = guest.notes, !notes.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    Label("Notes", systemImage: "note.text")
                        .font(.caption2).bold().foregroundStyle(Color(hex: "ad6928"))
                    Text(notes).font(.footnote).foregroundStyle(.primary)
                }
            }
            
            Divider()
            
            // ACTION BLOCK: Edit & Remove
            HStack(spacing: 12) {
                Text("Manage Internal Guest")
                    .font(.caption).bold().foregroundStyle(.secondary)
                
                Spacer()
                
                // Edit Button
                CircleIconButton(systemImage: "pencil", color: Color(hex: "ad6928"), action: onEdit)
                
                // Remove Button
                CircleIconButton(systemImage: "trash", color: .red, action: onRemove)
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}
