//
//  CoffeeCalendarViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/10/26.
//

import Foundation
import SwiftUI

@MainActor
class CoffeeCalendarViewModel: ObservableObject {
    @Published var currentMonth: Date = Date()
    @Published var selectedDate: Date = Date()
    @Published var coffeeLogs: [CoffeeLogEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let coffeeFetcher = CoffeeLogFetcher()

    func fetchLogs() async {
        isLoading = true
        errorMessage = nil
        do {
            let dtos = try await coffeeFetcher.fetchCoffeeLogs()
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            let fallbackFormatter = ISO8601DateFormatter()
            fallbackFormatter.formatOptions = [.withInternetDateTime]

            self.coffeeLogs = dtos.map { dto in
                // Safely parse the incoming string date
                let parsedDate = isoFormatter.date(from: dto.consumedAt) ??
                                 fallbackFormatter.date(from: dto.consumedAt) ??
                                 Date()

                return CoffeeLogEntry(
                    id: dto.id ?? UUID(),
                    date: parsedDate,
                    coffeeName: dto.coffeeName,
                    price: dto.price,
                    imageUrl: dto.imageUrl,
                    latitude: dto.latitude,
                    longitude: dto.longitude
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func log(for date: Date) -> CoffeeLogEntry? {
        return coffeeLogs.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func getAllLog(for date: Date) -> [CoffeeLogEntry] {
        return coffeeLogs.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func changeMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}
