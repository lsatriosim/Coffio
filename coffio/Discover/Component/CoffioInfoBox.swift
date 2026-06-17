//
//  CoffioInfoBox.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 17/06/26.
//

import SwiftUI

struct CoffioInfoBox: View {
    enum BoxType {
        case success
        case failed
        case warning
        
        var iconName: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .failed:  return "exclamationmark.octagon.fill"
            case .warning: return "exclamationmark.triangle.fill"
            }
        }
        
        var themeColor: Color {
            switch self {
            case .success: return .green
            case .failed:  return .red
            case .warning: return Color(hex: "ad6928") // Your brand coffee/amber tone
            }
        }
        
        var backgroundColor: Color {
            // Soft background tint matching the theme color
            switch self {
            case .success: return Color(.systemGreen).opacity(0.06)
            case .failed:  return Color(.systemRed).opacity(0.06)
            case .warning: return Color(hex: "ad6928").opacity(0.06)
            }
        }
    }
    
    let type: BoxType
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: type.iconName)
                .font(.body)
                .foregroundStyle(type.themeColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.footnote)
                    .bold()
                    .foregroundStyle(type.themeColor)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(type.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(type.themeColor.opacity(0.15), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        CoffioInfoBox(
            type: .failed,
            title: "Submission Rejected",
            description: "Please edit and review your event verification details, location description, or ticket pricing format before submitting again."
        )
        
        CoffioInfoBox(
            type: .warning,
            title: "Action Required",
            description: "You have unconfirmed participant registrations that require immediate validation."
        )
        
        CoffioInfoBox(
            type: .success,
            title: "Verification Complete",
            description: "Your coffee community event has been reviewed, approved, and is now live on the public discovery timeline."
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
