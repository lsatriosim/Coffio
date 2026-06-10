//
//  SpendingView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 06/06/26.
//

import SwiftUI

struct SpendingTrackerView: View {
    @StateObject private var viewModel = SpendingViewModel()
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.authService.user == nil {
                    notLoggedInView
                }
                else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24.0) {
                            
                            Text("Spending Dashboard")
                                .font(.headline)
                                .padding(.horizontal, 24)
                                .padding(.top, 16)
                            
                            if viewModel.isLoading {
                                HStack(spacing: 16.0) {
                                    SpendingAggregateCardSkeletonView()
                                    SpendingAggregateCardSkeletonView()
                                    SpendingAggregateCardSkeletonView()
                                }
                                .padding(.horizontal, 24)
                            }
                            else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 14.0) {
                                        
                                        // Card 1: Dynamic Current Month Filter Summary
                                        metricCard(
                                            title: "IDR \(viewModel.currentMonthSpending.formatted())",
                                            subtitle: "THIS MONTH (\(viewModel.currentMonthLabel))",
                                            icon: "chart.line.uptrend.xyaxis",
                                            accentColor: Color(hex: "ad6928")
                                        )
                                        
                                        // Card 2: Avg Per Visit
                                        metricCard(
                                            title: "IDR \(viewModel.averagePerVisit.formatted())",
                                            subtitle: "AVG PER VISIT",
                                            icon: "cup.and.saucer.fill",
                                            accentColor: Color(hex: "563122")
                                        )
                                        
                                        // Card 3: Combined Aggregate Account Totals
                                        metricCard(
                                            title: "IDR \(viewModel.totalSpending.formatted())",
                                            subtitle: "TOTAL SPENDING",
                                            icon: "creditcard.fill",
                                            accentColor: .black
                                        )
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }
                            
                            // History Feed Layout Component
                            HStack {
                                Text("Spending History")
                                    .font(.headline)
                                Spacer()
                                Button(action: { showAddSheet = true }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add New")
                                    }
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundStyle(Color(hex: "ad6928"))
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            VStack(spacing: 12.0) {
                                if viewModel.isLoading {
                                    SpendingHistoryRowSkeletonView()
                                    SpendingHistoryRowSkeletonView()
                                    SpendingHistoryRowSkeletonView()
                                }
                                else {
                                    ForEach(viewModel.historyItems) { item in
                                        SpendingHistoryRow(item: item)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            Spacer()
                        }
                    }
                }
            }
            .background(Color(hex: "f2efed"))
            .navigationTitle("Coffio Spending")
            .task {
                viewModel.loadInitialData()
            }
            .sheet(isPresented: $showAddSheet) {
                AddSpendingSheet(viewModel: viewModel)
            }
        }
    }
    
    @ViewBuilder
    private func metricCard(title: String, subtitle: String, icon: String, accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 12.0) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(accentColor)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4.0) {
                Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Color(hex: "563122"))
                    .minimumScaleFactor(0.85)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16.0)
        .frame(width: 160, height: 110, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 5)
    }
    
    private var notLoggedInView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 80))
                .foregroundStyle(Color(hex: "ad6928").opacity(0.8))
            
            VStack(spacing: 12) {
                Text("Join the Community")
                    .font(.title2)
                    .bold()
                
                Text("Log in to manage your profile, track your events, and enjoy the full Coffio experience.")
                    .font(.body)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        
            Button(action: {
                viewModel.authService.showLoginPage()
            }) {
                HStack {
                    Spacer()
                    Text("Login or Sign Up")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .bold()
                    Spacer()
                }
                .padding(.vertical, 16.0)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "ad6928"))
                        .shadow(color: .black.opacity(0.1), radius: 10)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}

// Custom internal row container styled explicitly like Coffio's PaymentInfoCardView style
private struct SpendingHistoryRow: View {
    let item: SpendingItemDataModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 12.0) {
            Image(systemName: "cup.and.saucer.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 22.0, height: 22.0)
                .foregroundStyle(Color(hex: "ad6928"))
                .padding(10)
                .background(Color(hex: "f2efed"))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4.0) {
                Text(item.itemName)
                    .font(.body)
                    .bold()
                    .foregroundStyle(.primary)
                
                Text(item.coffeeShopName)
                    .font(.caption)
                    .foregroundStyle(.primary)
                
                Text(DateFormatterUtil.getDateOnly(item.purchaseDate))
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Text("Rp \(Int(item.amount))")
                .font(.body)
                .bold()
                .foregroundStyle(Color(hex: "563122"))
        }
        .padding(16.0)
        .background {
            RoundedRectangle(cornerRadius: 16.0)
                .fill(.white)
        }
    }
}

struct SpendingHistoryRowSkeletonView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12.0) {
            Circle()
                .fill(Color.gray.opacity(0.25))
                .frame(width: 42.0, height: 42.0)
                .shimmering()
            
            VStack(alignment: .leading, spacing: 6.0) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 140, height: 14)
                    .shimmering()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 11)
                    .shimmering()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 75, height: 11)
                    .shimmering()
            }
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 70, height: 16)
                .shimmering()
        }
        .padding(16.0)
        .background {
            RoundedRectangle(cornerRadius: 16.0)
                .fill(.white)
        }
    }
}

struct SpendingAggregateCardSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 50, height: 11)
                .shimmering()
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 95, height: 18)
                .shimmering()
        }
        .padding(16.0)
        .frame(width: 150, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 5)
    }
}
