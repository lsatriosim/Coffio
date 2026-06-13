//
//  CreateEventViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 13/06/26.
//


//
//  CreateEventViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 13/06/26.
//

import SwiftUI

@MainActor
final class CreateEventViewModel: ObservableObject {
    // Form Binding Targets
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var capacity: String = ""
    @Published var cafeName: String = ""
    @Published var fullAddress: String = ""
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date().addingTimeInterval(7200)
    @Published var registrationMethod: RegistrationType = .internal
    @Published var ticketType: TicketType = .free
    @Published var coffeeShops: [CoffeeShopLookupItem] = []
    @Published var selectedCoffeeShopId: String? = nil
    
    // Financial Targets
    @Published var ticketPrice: String = ""
    @Published var bankName: String = ""
    @Published var accountNumber: String = ""
    @Published var accountHolderName: String = ""
    
    // Infrastructure Pipeline Variables
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    
    private let fetcher = EventFetcher()
    private let shopFetcher = CoffeeShopFetcher()
    private let authService: AuthenticationService = .shared
    
    // Validation Engine
    var isFormValid: Bool {
        guard !title.isEmpty, !description.isEmpty, !cafeName.isEmpty, !fullAddress.isEmpty, !capacity.isEmpty else { return false }
        if ticketType == .paid {
            return !ticketPrice.isEmpty && !bankName.isEmpty && !accountNumber.isEmpty && !accountHolderName.isEmpty
        }
        return true
    }
    
    func publishEvent(posterImage: Image?, menuImage: Image?, completion: @escaping () -> Void) {
        guard isFormValid else {
            self.errorMessage = "Please complete all mandatory field configurations."
            self.isError = true
            return
        }
        
        guard let user = authService.user else {
            authService.showLoginPage()
            return
        }
        
        isLoading = true
        
        Task {
            do {
                var calculatedPosterUrl: String? = nil
                var calculatedMenuUrl: String? = nil
                
                // 1. Process concurrent multi-file storage transactions cleanly
                if let posterImage {
                    calculatedPosterUrl = try await fetcher.uploadEventAsset(image: posterImage, fileName: "poster")
                }
                if let menuImage {
                    calculatedMenuUrl = try await fetcher.uploadEventAsset(image: menuImage, fileName: "menu")
                }
                
                // 2. Format ISO8601 Timestamps
                let isoFormatter = ISO8601DateFormatter()
                let eventDateString = isoFormatter.string(from: startTime)
                let endDateString = isoFormatter.string(from: endTime)
                
                // 3. Cast values safely to numeric configurations
                let parsedCapacity = Int(capacity) ?? 0
                let parsedPrice = ticketType == .paid ? (Int(ticketPrice) ?? 0) : nil
                
                // 4. Construct structural payload
                let requestPayload = CreateEventRequest(
                    title: title,
                    description: description,
                    imageUrl: calculatedPosterUrl,
                    menuImageUrl: calculatedMenuUrl,
                    eventDate: eventDateString,
                    endDate: endDateString,
                    cafeName: cafeName,
                    location: fullAddress,
                    capacity: parsedCapacity,
                    registrationType: registrationMethod.rawValue,
                    price: parsedPrice,
                    bankName: ticketType == .paid ? bankName : nil,
                    bankAccount: ticketType == .paid ? accountNumber : nil,
                    bankHolder: ticketType == .paid ? accountHolderName : nil,
                    createdBy: user.id
                )
                
                // 5. Fire insertion transactional block pipelines
                try await fetcher.createEvent(request: requestPayload)
                
                isLoading = false
                completion()
            } catch {
                print("Database execution context failed: \(error)")
                self.isLoading = false
                self.isError = true
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func loadCoffeeShopLookupData() async {
        do {
            self.coffeeShops = try await shopFetcher.fetchCoffeeShopLookup()
            print("Pull coffee succes")
        } catch {
            
            print("Failed to pull coffee shop options: \(error)")
        }
    }
}
