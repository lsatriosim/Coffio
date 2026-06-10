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
    
    // MARK: - Web-Aligned Aggregated Metrics
    
    /// Returns total cost accumulated ONLY within the current calendar month
    var currentMonthSpending: Int {
        let calendar = Calendar.current
        let now = Date()
        
        let filteredItems = historyItems.filter { item in
            calendar.isDate(item.purchaseDate, equalTo: now, toGranularity: .month) &&
            calendar.isDate(item.purchaseDate, equalTo: now, toGranularity: .year)
        }
        
        return filteredItems.reduce(0) { $0 + (Int($1.amount) * $1.quantity) }
    }
    
    /// Computes total global spending over the user's entire account lifecycle
    var totalSpending: Int {
        historyItems.reduce(0) { $0 + (Int($1.amount) * $1.quantity) }
    }
    
    /// Computes average price per individual log transaction visit entry
    var averagePerVisit: Int {
        guard !historyItems.isEmpty else { return 0 }
        return totalSpending / historyItems.count
    }
    
    /// Helper identifier for current month display string matching web layout format (e.g., "THIS MONTH")
    var currentMonthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: Date()).uppercased()
    }
    
    func loadInitialData() {
        guard currentUserId != "" else { return }
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
                if let imageToUpload = receiptImage {
                    finalReceiptUrl = try await spendingFetcher.uploadReceipt(
                        uiImage: imageToUpload,
                        userId: currentUserId,
                        spendingId: generatedSpendingId
                    )
                }
                
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
                self.historyItems = try await spendingFetcher.fetchUserSpendings(userId: currentUserId)
                self.isLoading = false
                onSuccess()
            } catch {
                print("❌ [save spending]: \(error)")
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.isError = true
            }
        }
    }
}
