//
//  SpendingViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 06/06/26.
//

import Foundation
import UIKit

@MainActor
final class SpendingViewModel: ObservableObject {
    @Published var historyItems: [SpendingItemDataModel] = []
    @Published var coffeeShops: [CoffeeShopLookupItem] = []
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    
    private let spendingFetcher = SpendingFetcher()
    private let shopFetcher = CoffeeShopFetcher()
    
    let authService: AuthenticationService = .shared
    private var currentUserId: String { authService.user?.id ?? "" }
    
    var monthlyAggregates: [(month: String, total: Int)] {
        let grouped = Dictionary(grouping: historyItems) { $0.monthYearString }
        return grouped.map { (month: $0.key, total: $0.value.reduce(0) { $0 + ($1.amount * $1.quantity) }) }
            .sorted { (pair1, pair2) -> Bool in
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                guard let date1 = formatter.date(from: pair1.month),
                      let date2 = formatter.date(from: pair2.month) else { return false }
                return date1 > date2
            }
    }
    
    /// Loads both user historical transaction lists and available shops for selection dropdowns
    func loadInitialData() {
        guard currentUserId != "" else {
            authService.showLoginPage()
            return
        }
        isLoading = true
        Task {
            do {
                async let spendings = spendingFetcher.fetchUserSpendings(userId: currentUserId)
                async let shops = shopFetcher.fetchCoffeeShopLookup()
                
                self.historyItems = try await spendings
                self.coffeeShops = try await shops
                self.isLoading = false
            } catch {
                print("❌ [Supabase CoffeeShop Fetch Error]: \(error)")
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.isError = true
            }
        }
    }
    
    func saveSpending(itemName: String, amount: Int, quantity: Int, date: Date, coffeeShopId: String?, notes: String?, receiptImage: UIImage?, onSuccess: @escaping () -> Void) {
        isLoading = true
        let generatedSpendingId = UUID().uuidString
        
        Task {
            do {
                var finalReceiptUrl: String? = nil
                
                // 1. Process receipt image asset uploading logic step if present
                if let imageToUpload = receiptImage {
                    finalReceiptUrl = try await spendingFetcher.uploadReceipt(
                        uiImage: imageToUpload,
                        userId: currentUserId,
                        spendingId: generatedSpendingId
                    )
                }
                
                // 2. Generate and post data payload record maps
                let request = SpendingLogRequest(
                    userId: currentUserId,
                    coffeeShopId: coffeeShopId,
                    itemName: itemName,
                    amount: amount,
                    quantity: quantity,
                    purchaseDate: date,
                    notes: notes,
                    receiptUrl: finalReceiptUrl
                )
                
                try await spendingFetcher.insertSpending(request: request)
                
                // 3. Hot reload presentation items state layer arrays
                self.historyItems = try await spendingFetcher.fetchUserSpendings(userId: currentUserId)
                self.isLoading = false
                onSuccess()
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.isError = true
            }
        }
    }
}
