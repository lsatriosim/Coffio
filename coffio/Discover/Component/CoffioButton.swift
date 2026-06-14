//
//  CoffioButtonStyle.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 14/06/26.
//

import SwiftUI

// MARK: - Coffio Button Style Enum
enum CoffioButtonStyle {
    case primary
    case secondary
}

// MARK: - Reusable Component
struct CoffioButton: View {
    let title: String
    var icon: String? = nil
    var style: CoffioButtonStyle = .primary
    var isDisabled: Bool = false // 💡 New parameter for tracking state
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.headline)
                }
                
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(textColor)
            .background {
                buttonBackground
            }
        }
        .buttonStyle(CoffioScaleButtonStyle(isDisabled: isDisabled)) // Prevent shrink effects when disabled
        .disabled(isDisabled) // 💡 Native SwiftUI modifier to drop touch interaction
    }
    
    // MARK: - Dynamic State Evaluators
    private var textColor: Color {
        if isDisabled {
            return .gray.opacity(0.6) // Muted gray text for both styles when disabled
        }
        
        switch style {
        case .primary:
            return .white
        case .secondary:
            return Color(hex: "ad6928")
        }
    }
    
    @ViewBuilder
    private var buttonBackground: some View {
        if isDisabled {
            switch style {
            case .primary:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5)) // Flat light-gray background block
            case .secondary:
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.gray.opacity(0.3), lineWidth: 1.5) // Faded gray border line
            }
        } else {
            switch style {
            case .primary:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "ad6928"))
            case .secondary:
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "ad6928"), lineWidth: 1.5)
            }
        }
    }
}

// MARK: - Responsive Interaction Modifier
struct CoffioScaleButtonStyle: ButtonStyle {
    let isDisabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // 💡 Only apply scale and fade animations if the button is active
            .scaleEffect(!isDisabled && configuration.isPressed ? 0.97 : 1.0)
            .opacity(!isDisabled && configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
