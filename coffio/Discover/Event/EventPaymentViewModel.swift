//
//  EventPaymentViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 01/07/26.
//

import SwiftUI
import PhotosUI

@MainActor
final class EventPaymentViewModel: ObservableObject {
    let registrationId: String
    let event: DiscoverEventItem
    let deadline: Date
    
    @Published var timeRemainingString: String = "--:--"
    @Published var isTimerExpired: Bool = false
    @Published var receiptData: Data? = nil
    
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    
    private let fetcher = EventFetcher()
    private var countdownTimer: Timer?
    private let authService: AuthenticationService = .shared
    
    init(registrationId: String, event: DiscoverEventItem, paymentDeadlineTime: Date) {
        self.registrationId = registrationId
        self.event = event
        self.deadline = paymentDeadlineTime
        
        startTimerSequence()
    }
    
    func startTimerSequence() {
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                let now = Date()
                let diff = self.deadline.timeIntervalSince(now)
                
                if diff <= 0 {
                    self.timeRemainingString = "00:00"
                    self.isTimerExpired = true
                    self.countdownTimer?.invalidate()
                } else {
                    let minutes = Int(diff) / 60
                    let seconds = Int(diff) % 60
                    self.timeRemainingString = String(format: "%02d:%02d", minutes, seconds)
                }
            }
        }
    }
    
    func submitPaymentProof(completion: @escaping () -> Void) {
        guard let receiptData = receiptData, let userId = authService.user?.id else {
            self.errorMessage = "Please upload your valid payment proof receipt."
            self.isError = true
            return
        }
        
        isLoading = true
        Task {
            do {
                let uploadedUrl = try await fetcher.uploadPaymentProof(image: receiptData, eventId: event.id, userId: userId)
                
                let uploadRecordPayload = UploadTransactionRequest(
                    userId: userId,
                    eventId: event.id,
                    registrationId: registrationId,
                    imageUrl: uploadedUrl,
                )
                
                try await fetcher.insertUploadRecord(request: uploadRecordPayload)
                
                try await fetcher.submitPaymentProof(registrationId: registrationId)
                
                self.isLoading = false
                countdownTimer?.invalidate()
                completion()
            } catch {
                self.isLoading = false
                self.isError = true
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    deinit {
        countdownTimer?.invalidate()
    }
}
