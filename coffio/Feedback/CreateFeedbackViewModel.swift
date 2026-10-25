//
//  FeedbackViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 12/09/26.
//

import SwiftUI
import PhotosUI

enum FeedbackType: String, CaseIterable, Identifiable {
    case bugReport = "BUG_REPORT"
    case suggestionIdea = "SUGGESTION_IDEA"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .bugReport: return "Bug Report"
        case .suggestionIdea: return "Suggestion & Idea"
        }
    }
}

@MainActor
final class CreateFeedbackViewModel: ObservableObject {
    @Published var reportType: FeedbackType = .bugReport
    @Published var description: String = ""
    
    // Multiple image support (max 3)
    @Published var selectedPhotoItems: [PhotosPickerItem] = []
    @Published var selectedImages: [UIImage] = []
    @Published var imageDatas: [Data] = []
    @Published var fileNames: [String] = []
    
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showNotificationPopUp: Bool = false
    
    private let feedbackFetcher = FeedbackFetcher()
    private let authService: AuthenticationService = .shared
    
    func addImages(from items: [PhotosPickerItem]) {
        Task {
            var newImages: [UIImage] = []
            var newData: [Data] = []
            var newNames: [String] = []
            
            for item in items.prefix(3 - selectedImages.count) {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    newData.append(data)
                    newImages.append(uiImage)
                    newNames.append("feedback_image_\(UUID().uuidString).jpg")
                }
            }
            
            self.selectedImages.append(contentsOf: newImages)
            self.imageDatas.append(contentsOf: newData)
            self.fileNames.append(contentsOf: newNames)
            
            // Keep picker items in sync or clear selection to allow picking more
            self.selectedPhotoItems.removeAll()
        }
    }
    
    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
        imageDatas.remove(at: index)
        fileNames.remove(at: index)
    }
    
    func submitFeedback() {
        guard let userId = authService.user?.id else {
            self.errorMessage = "User session not found. Please log in again."
            self.isError = true
            return
        }
        
        guard !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.errorMessage = "Please enter a description for your feedback."
            self.isError = true
            return
        }
        
        isLoading = true
        Task {
            do {
                try await feedbackFetcher.submitFeedback(
                    reporterId: userId,
                    reportType: reportType.rawValue,
                    description: description,
                    images: imageDatas,
                    imageNames: fileNames
                )
                
                self.isLoading = false
                showNotificationPopUp = true
            } catch {
                self.isLoading = false
                self.isError = true
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
