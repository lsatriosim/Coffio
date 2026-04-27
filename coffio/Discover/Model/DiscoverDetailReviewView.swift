//
//  DiscoverDetailReviewView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 12/04/26.
//

import SwiftUI

struct DiscoverDetailReviewView: View {
    private var reviewsShown: [DiscoverCoffeeShopReview] {
        detailViewModel.coffeeShop.reviews.filter { $0.comment != nil }
    }
    let authService: AuthenticationService = .shared
    @State private var showReviewSheet: Bool = false
    @EnvironmentObject private var detailViewModel: DiscoverDetailCafeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            Text("Reviews")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color(hex: "563122"))
            
            if reviewsShown.isEmpty {
                DiscoverDetailReviewEmptyStateView()
            }
            else {
                ForEach(reviewsShown, id: \.id) { review in
                    DiscoverDetailReviewCardView(dataModel: review)
                }
            }
            Button(action: {
                guard authService.user != nil else {
                    authService.showLoginPage()
                    return
                }
                showReviewSheet = true
            }) {
                HStack {
                    Spacer()
                    Text("Add Review")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Image(systemName: "star.bubble")
                        .foregroundStyle(.white)
                    Spacer()
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "ad6928"))
            }
        }
        .sheet(isPresented: $showReviewSheet) {
            DiscoverReviewSheet(detailViewModel: detailViewModel)
        }
    }
}

private struct DiscoverDetailReviewCardView: View {
    let dataModel: DiscoverCoffeeShopReview
    var body: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            HStack(alignment: .center) {
                if let imageUrl = dataModel.user.avatarUrl,
                   let url = URL(string: imageUrl) {
                    
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                            
                        case .failure(_), .empty:
                            placeholderView
                            
                        @unknown default:
                            placeholderView
                        }
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    
                } else {
                    placeholderView
                }
                
                Text(dataModel.user.fullName)
                    .foregroundStyle(Color(hex: "642e13"))
                    .font(.callout)
                Spacer()
                Text("\(dataModel.rating)★")
                    .foregroundStyle(Color(hex: "642e13"))
                    .font(.callout)
            }
            
            if let comment = dataModel.comment {
                Text(comment)
            }
            Text("\(DateFormatterUtil.formatDate(dataModel.createdAt))")
                .font(.caption)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background {
            RoundedRectangle(cornerRadius: 12.0)
                .fill(.white)
                .stroke(Color(hex: "f2efed", alpha: 1.0), lineWidth: 1.0)
        }
    }
    
    private var placeholderView: some View {
        Circle()
            .fill(Color(hex: "f2efed"))
            .frame(width: 48, height: 48)
            .overlay(
                Text(dataModel.user.fullName.prefix(1))
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color(hex: "b17e54"))
            )
    }
}
