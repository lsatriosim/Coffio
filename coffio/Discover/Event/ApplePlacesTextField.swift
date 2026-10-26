//
//  ApplePlacesTextField.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 26/10/26.
//

import SwiftUI
import MapKit

struct ApplePlacesTextField: View {
    @Binding var cafeName: String
    @Binding var fullAddress: String
    var placeholder: String
    
    @StateObject private var viewModel = ApplePlacesAutocompleteViewModel()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main Text Field Input (Bound to Cafe Name)
            HStack {
                TextField(placeholder, text: $cafeName)
                    .focused($isFocused)
                    .onChange(of: cafeName) { newValue in
                        if viewModel.searchQuery != newValue {
                            viewModel.searchQuery = newValue
                        }
                    }
                
                if !cafeName.isEmpty || !fullAddress.isEmpty {
                    Button(action: {
                        cafeName = ""
                        fullAddress = ""
                        viewModel.searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            }
            .padding(14.0)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "ad6928").opacity(0.4), lineWidth: 1.5)
            )
            
            // Floating Suggestions Dropdown
            if isFocused && !viewModel.searchResults.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.searchResults, id: \.self) { result in
                        Button(action: {
                            // Automatically fetch and populate both name and full address
                            viewModel.resolveCompletion(result) { resolvedName, resolvedAddress in
                                cafeName = resolvedName
                                fullAddress = resolvedAddress
                            }
                            viewModel.searchResults = []
                            isFocused = false
                        }) {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundStyle(Color(hex: "ad6928"))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(result.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                    
                                    if !result.subtitle.isEmpty {
                                        Text(result.subtitle)
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                    }
                                }
                                .lineLimit(1)
                                
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.white)
                        }
                        .buttonStyle(.plain)
                        
                        Divider()
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                .padding(.top, 4)
                .zIndex(10)
            }
        }
    }
}
