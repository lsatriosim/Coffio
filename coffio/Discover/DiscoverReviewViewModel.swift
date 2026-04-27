//
//  DiscoverReviewViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 26/04/26.
//

import Foundation

protocol DiscoverReviewViewModelDelegate: AnyObject {
    func onReviewSubmitted()
}

@MainActor
final class DiscoverReviewViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    
    weak var delegate: DiscoverReviewViewModelDelegate?
    
    let fetcher: CoffeeShopFetcher = .init()
    let authService: AuthenticationService = .shared
    
    func submitReview(cafeId: String, stars: Int, comment: String?, completion: @escaping () -> Void) async {
        updateIsLoading(isLoading: true)
        
        do {
            guard let user = authService.user else { return }
            let id: String = UUID().uuidString
            print("[Submit Review]: \(id)")
            let request: DiscoverCoffeeShopReviewRequest = DiscoverCoffeeShopReviewRequest(
                id: UUID().uuidString,
                coffeeShopId: cafeId,
                userId: user.id,
                rating: stars,
                comment: comment
            )
            try await fetcher.postCoffeeShopReview(request: request)
            updateIsLoading(isLoading: false)
            delegate?.onReviewSubmitted()
            completion()
        }
        catch {
            updateIsLoading(isLoading: false)
            updateError(isError: true, errorMessage: "Failed to post review. Please try again!")
        }
    }
    
    func updateIsLoading(isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    func updateError(isError: Bool, errorMessage: String) {
        self.isError = isError
        self.errorMessage = errorMessage
    }
}
