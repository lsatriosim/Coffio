//
//  CoffeeCalendarView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/10/26.
//

import CoreLocation
import MapKit
import SwiftUI

struct CoffeeCalendarView: View {
    @StateObject private var viewModel = CoffeeCalendarViewModel()
    @ObservedObject private var locationProvider = LocationProvider.shared

    @State private var showAddCoffeeSheet: Bool = false
    @State private var navigateToMapView: Bool = false

    private let primaryBrown = Color(hex: "ad6928")
    private let backgroundTone = Color(hex: "f2efed")
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: 1. Financial Analytics Summary Card
                    CoffeeAnalyticsCard(
                        viewModel: viewModel,
                        currentWeekDays: extractCurrentWeekDays()
                    )
                    .padding(.horizontal)

                    // MARK: 2. Sneak Preview Map Card with Coffee Log Annotations
                    mapPreviewCard
                        .padding(.horizontal)

                    // MARK: 3. Week Navigation Header
                    weekHeaderView
                        .padding(.horizontal)

                    // MARK: 4. Days of Week Header
                    HStack(spacing: 0) {
                        ForEach(daysOfWeek, id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)

                    // MARK: 5. Compact 7-Day Week Strip
                    let weekDays = extractCurrentWeekDays()
                    HStack(spacing: 8) {
                        ForEach(weekDays, id: \.self) { date in
                            cellView(for: date)
                        }
                    }
                    .padding(.horizontal)

                    // MARK: 6. Selected Day Details
                    selectedDayDetailView
                        .padding(.horizontal)

                    Spacer(minLength: 20)
                }
                .padding(.vertical, 12)
            }
            .background(backgroundTone.ignoresSafeArea())
            .navigationTitle("Coffee Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigateToMapView) {
                CoffeeMapView(logs: viewModel.coffeeLogs)
            }
            .sheet(isPresented: $showAddCoffeeSheet) {
                AddCoffeeView(targetDate: viewModel.selectedDate) {
                    Task { await viewModel.fetchLogs() }
                }
            }
            .task {
                await viewModel.fetchLogs()
            }
        }
    }

    // MARK: - Map Sneak Preview Component with Annotations
    private var mapPreviewCard: some View {
        ZStack {
            if locationProvider.isLocationAuthorized {
                Map(position: .constant(.userLocation(fallback: .automatic))) {
                    UserAnnotation()

                    // Plot coffee log annotations on the preview map
                    ForEach(viewModel.coffeeLogs.filter { $0.coordinate != nil }) { log in
                        if let coordinate = log.coordinate {
                            Annotation(log.coffeeName, coordinate: coordinate) {
                                AsyncImage(url: URL(string: log.imageUrl)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFit()
                                    default:
                                        Image(systemName: "cup.and.saucer.fill")
                                    }
                                }
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(Color.white))
                                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
                                .overlay(Circle().stroke(primaryBrown, lineWidth: 1.5))
                            }
                        }
                    }
                }
                .disabled(true)
                .overlay(Color.black.opacity(0.01))
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "location.slash.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(primaryBrown)

                    Text("Location Permission Required")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text("Enable location access to view your coffee trail on the interactive map.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)

                    Button(action: openAppSettings) {
                        HStack(spacing: 6) {
                            Image(systemName: "gearshape.fill")
                            Text("Open Settings")
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(primaryBrown)
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            }
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        .contentShape(Rectangle())
        .onTapGesture {
            if locationProvider.isLocationAuthorized {
                navigateToMapView = true
            }
        }
    }

    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }

    // MARK: - Week Header Component
    private var weekHeaderView: some View {
        HStack {
            Text(weekRangeString(for: viewModel.currentMonth))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(primaryBrown)

            Spacer()

            HStack(spacing: 16) {
                Button(action: { changeWeek(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(primaryBrown)
                        .font(.subheadline.bold())
                }
                Button(action: { changeWeek(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(primaryBrown)
                        .font(.subheadline.bold())
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Week Day Cell View
    @ViewBuilder
    private func cellView(for date: Date) -> some View {
        let isSelected = Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
        let isToday = Calendar.current.isDateInToday(date)
        let log = viewModel.log(for: date)

        Button(action: { viewModel.selectedDate = date }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? primaryBrown.opacity(0.15) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? primaryBrown : Color.clear, lineWidth: 1.5)
                    )

                VStack(spacing: 4) {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.system(size: 14, weight: isToday ? .bold : .regular))
                        .foregroundColor(isToday ? primaryBrown : .primary)

                    if let log {
                        AsyncImage(url: URL(string: log.imageUrl)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable()
                                    .scaledToFit()
                                    .frame(height: 28)
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            case .failure, .empty:
                                Image(systemName: "cup.and.saucer.fill")
                                    .foregroundColor(primaryBrown)
                                    .frame(height: 28)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Spacer().frame(height: 28)
                    }
                }
                .padding(4)
            }
            .frame(height: 60)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Selected Day Details
    private var selectedDayDetailView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Sip Record — \(formatSelectedDate())")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                Spacer()

                Button(action: { showAddCoffeeSheet = true }) {
                    Label("Add Sip", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(primaryBrown)
                        .cornerRadius(20)
                }
            }

            if viewModel.getAllLog(for: viewModel.selectedDate).isEmpty {
                HStack {
                    Image(systemName: "cup.and.saucer").foregroundColor(.secondary)
                    Text("No coffee logged for this day.").font(.subheadline).foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
                .background(Color.white.opacity(0.6))
                .cornerRadius(16)
            } else {
                ForEach(viewModel.getAllLog(for: viewModel.selectedDate)) { log in
                    HStack(spacing: 16) {
                        AsyncImage(url: URL(string: log.imageUrl)) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable()
                                    .scaledToFit()
                                    .frame(height: 28)
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            case .failure, .empty:
                                Image(systemName: "cup.and.saucer.fill")
                                    .foregroundColor(primaryBrown)
                                    .frame(height: 28)
                            @unknown default:
                                EmptyView()
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(log.coffeeName).font(.headline)
                            Text("Spent: \(formatIDR(log.price))")
                                .font(.subheadline)
                                .foregroundColor(primaryBrown)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
                }
            }
        }
    }

    // MARK: - Helpers
    private func formatIDR(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "Rp \(Int(price))"
    }

    private func formatSelectedDate() -> String {
        let f = DateFormatter(); f.dateStyle = .medium; return f.string(from: viewModel.selectedDate)
    }

    private func changeWeek(by value: Int) {
        if let newWeek = Calendar.current.date(byAdding: .day, value: value * 7, to: viewModel.currentMonth) {
            viewModel.currentMonth = newWeek
        }
    }

    private func extractCurrentWeekDays() -> [Date] {
        let calendar = Calendar.current
        let date = viewModel.currentMonth
        let weekday = calendar.component(.weekday, from: date)
        let daysToSubtract = weekday - 1
        
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: date) else {
            return []
        }

        return (0..<7).compactMap { dayIndex in
            calendar.date(byAdding: .day, value: dayIndex, to: startOfWeek)
        }
    }

    private func weekRangeString(for date: Date) -> String {
        let days = extractCurrentWeekDays()
        guard let start = days.first, let end = days.last else { return "" }

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM d"

        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"

        return "\(monthFormatter.string(from: start)) – \(monthFormatter.string(from: end)), \(yearFormatter.string(from: end))"
    }
}
