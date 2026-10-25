//
//  CoffeeAnalyticsCard.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 25/10/26.
//

import Foundation
import SwiftUI
import Charts

struct CoffeeAnalyticsCard: View {
    @ObservedObject var viewModel: CoffeeCalendarViewModel
    let currentWeekDays: [Date]

    private let primaryBrown = Color(hex: "ad6928")

    struct DailySpendModel: Identifiable {
        let id = UUID()
        let dayLabel: String
        let amount: Double
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Label("Spending Insights", systemImage: "chart.pie.fill")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(primaryBrown)
                Spacer()
            }

            // KPI Side-by-Side Metrics Cards
            HStack(spacing: 12) {
                kpiBox(title: "This Week", amount: totalSpendingThisWeek, icon: "calendar.badge.clock")
                kpiBox(title: "This Month", amount: totalSpendingThisMonth, icon: "calendar")
            }

            Divider()
                .background(Color.gray.opacity(0.15))

            // Weekly Spending Trend Chart
            VStack(alignment: .leading, spacing: 8) {
                Text("Weekly Trend")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                Chart(chartData) { item in
                    BarMark(
                        x: .value("Day", item.dayLabel),
                        y: .value("Spent", item.amount)
                    )
                    .foregroundStyle(primaryBrown.gradient)
                    .cornerRadius(6)
                }
                .frame(height: 110)
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let val = value.as(Double.self) {
                                Text(formatCompactIDR(val))
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    // MARK: - KPI Subview Builder
    @ViewBuilder
    private func kpiBox(title: String, amount: Double, icon: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(primaryBrown.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .foregroundColor(primaryBrown)
                    .font(.system(size: 15))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(formatIDR(amount))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(Color(.systemGray6).opacity(0.6))
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Analytics Calculations
    private var totalSpendingThisWeek: Double {
        guard let start = currentWeekDays.first, let end = currentWeekDays.last else { return 0 }
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: end) ?? end
        return viewModel.coffeeLogs.filter { log in
            log.date >= start && log.date <= endOfDay
        }.reduce(0) { $0 + $1.price }
    }

    private var totalSpendingThisMonth: Double {
        let calendar = Calendar.current
        let currentMonth = viewModel.currentMonth
        return viewModel.coffeeLogs.filter { log in
            calendar.isDate(log.date, equalTo: currentMonth, toGranularity: .month)
        }.reduce(0) { $0 + $1.price }
    }

    private var chartData: [DailySpendModel] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Sun, Mon, etc.

        return currentWeekDays.map { date in
            let dayTotal = viewModel.coffeeLogs.filter { log in
                calendar.isDate(log.date, inSameDayAs: date)
            }.reduce(0) { $0 + $1.price }

            return DailySpendModel(dayLabel: formatter.string(from: date), amount: dayTotal)
        }
    }

    private func formatIDR(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "Rp \(Int(price))"
    }

    private func formatCompactIDR(_ price: Double) -> String {
        if price >= 1_000_000 {
            return String(format: "Rp %.1fjt", price / 1_000_000)
        } else if price >= 1_000 {
            return String(format: "Rp %.0fK", price / 1_000)
        }
        return "\(Int(price))"
    }
}
