//
//  DiscoverReviewSheet.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 26/04/26.
//


import SwiftUI

struct DiscoverReviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    let cafeName: String
    let cafeId: String
    
    @State private var rating: Int
    @State private var comment: String
    
    @ObservedObject var viewModel: DiscoverReviewViewModel
    
    init(detailViewModel: DiscoverDetailCafeViewModel) {
        self.cafeName = detailViewModel.coffeeShop.name
        self.cafeId = detailViewModel.coffeeShop.id
        self.rating = 0
        self.comment = ""
        self.viewModel = DiscoverReviewViewModel()
        viewModel.delegate = detailViewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24.0) {
                // Handle indicator
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 6)
                    .padding(.top, 12)
                
                // Header
                VStack(spacing: 8.0) {
                    Text("Submit Review")
                        .font(.title2)
                        .bold()
                    
                    Text("How was your experience at \(cafeName)?")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 8)

                VStack(alignment: .leading, spacing: 24.0) {
                    // Star Rating Selector
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text("Rating")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .padding(.leading, 4)
                        
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundStyle(star <= rating ? Color(hex: "ad6928") : .gray.opacity(0.4))
                                    .onTapGesture {
                                        rating = star
                                    }
                            }
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(fieldBackground)
                    }
                    
                    // Optional Comment Field
                    inputField(
                        label: "Comment (Optional)",
                        placeholder: "Tell us about the coffee, ambiance, or service...",
                        text: $comment
                    )
                }
                .padding(.horizontal, 24)

                // Submit Button
                Button(action: {
                    Task {
                        await viewModel.submitReview(
                            cafeId: cafeId,
                            stars: rating,
                            comment: comment
                        ) {
                            dismiss()
                        }
                    }
                }) {
                    HStack {
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text("Submit Review")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .bold()
                        }
                        Spacer()
                    }
                    .padding(.vertical, 16.0)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "ad6928"))
                            .shadow(color: .black.opacity(0.1), radius: 10)
                    }
                }
                .padding(.horizontal, 24)
                .disabled(rating == 0 || viewModel.isLoading)
                .opacity(rating == 0 ? 0.6 : 1.0)

                Spacer()
            }
        }
        .background(Color(hex: "f2efed"))
        // Error Handling Popup
        .coffioPopup(isPresented: $viewModel.isError) {
            VStack {
                Text(viewModel.errorMessage)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .bold()
                
                Button(action: { viewModel.isError = false }) {
                    Text("Close")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.vertical, 12.0)
                        .padding(.horizontal, 16.0)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "ad6928"))
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func inputField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.leading, 4)
            
            // Using Axis: .vertical allows the textfield to grow for longer comments
            TextField(placeholder, text: text, axis: .vertical)
                .lineLimit(4...8)
                .textFieldStyle(.plain)
                .padding(12.0)
                .background(fieldBackground)
        }
    }
    
    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 5)
    }
}
