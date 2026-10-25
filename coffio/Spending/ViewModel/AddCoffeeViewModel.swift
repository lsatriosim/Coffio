//
//  AddCoffeeViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/10/26.
//


import CoreLocation
import PhotosUI
import SwiftUI
import UIKit

@MainActor
class AddCoffeeViewModel: ObservableObject {
    @Published var coffeeName: String = ""
    @Published var priceString: String = ""
    @Published var originalImage: UIImage? = nil
    @Published var cutoutImage: UIImage? = nil
    @Published var isLoading: Bool = false
    @Published var isExtractionLoading: Bool = false
    
    // Error handling state for popup
    @Published var showErrorPopup: Bool = false
    @Published var errorPopupTitle: String = ""
    @Published var errorPopupSubtitle: String = ""
    @Published var errorPopupCTAButtonLabel: String = ""

    @Published var selectedLibraryItem: PhotosPickerItem? = nil {
        didSet { handleLibrarySelection() }
    }
    @Published var cameraImage: UIImage? = nil {
        didSet { if let image = cameraImage { processImage(image) } }
    }

    private let coffeeFetcher = CoffeeLogFetcher()

    func processImage(_ image: UIImage) {
        originalImage = image
        cutoutImage = nil
        isExtractionLoading = true

        Task {
            let result = await CoffeeCutoutService.removeBackground(from: image)
            self.isExtractionLoading = false
            
            if let result {
                self.cutoutImage = result
            } else {
                // Trigger the error popup if background extraction fails
                self.showErrorPopup = true
                self.errorPopupTitle = "Extraction Failed"
                self.errorPopupSubtitle = "We couldn't cleanly isolate the coffee cup from this photo. Please try another image with a clearer background."
                self.errorPopupCTAButtonLabel = "Got it"
            }
        }
    }

    private func handleLibrarySelection() {
        guard let item = selectedLibraryItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                processImage(uiImage)
            }
        }
    }
    
    func saveCoffeeLog(for targetDate: Date, completion: @escaping () -> Void) async {
        guard let cutout = cutoutImage,
              let imageData = cutout.pngData() else { return }
        
        let price = Double(priceString.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: "")) ?? 0.0
        let currentLocation = LocationProvider.shared.currentLocation
        let lat = currentLocation?.coordinate.latitude
        let lon = currentLocation?.coordinate.longitude
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateString = isoFormatter.string(from: targetDate)

        let fileName = "\(UUID().uuidString).png"
        let filePath = "cutouts/\(fileName)"

        isLoading = true

        do {
            // 1. Upload to Supabase Storage
            let publicImageUrl = try await coffeeFetcher.uploadCoffeeCutout(
                image: imageData,
                filePath: filePath
            )

            // 2. Insert record into database table
            let dto = CoffeeLogDTO(
                id: nil,
                userId: nil,
                coffeeName: coffeeName,
                price: price,
                consumedAt: dateString,
                imageUrl: publicImageUrl,
                latitude: lat,
                longitude: lon
            )

            try await coffeeFetcher.insertCoffeeLog(dto)
            
            isLoading = false
            completion() // Trigger refetch in parent view
        } catch {
            self.showErrorPopup = true
            self.errorPopupTitle = "Save Log Failed"
            self.errorPopupSubtitle = "We couldn't save your log. Please try again!"
            self.errorPopupCTAButtonLabel = "Close"
            isLoading = false
            print("Failed to save coffee log: \(error.localizedDescription)")
        }
    }
}
