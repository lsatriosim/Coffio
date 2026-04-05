//
//  SpendingOverviewView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 29/03/26.
//

import SwiftUI

struct SpendingOverviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            VStack(alignment: .leading, spacing: 4.0) {
                Text("Spending Tracker")
                    .font(.title)
                    .bold()
                Text("Monitor your coffee expenses")
                    .font(.body)
            }
            HStack(alignment: .center) {
                SpendingOverviewCard()
                SpendingOverviewCard()
            }
            Text("Recent Spending")
                .font(.title2)
            VStack(alignment: .leading, spacing: 12.0) {
                SpendingRecentItemView()
                SpendingRecentItemView()
                SpendingRecentItemView()
                SpendingRecentItemView()
            }
            Spacer()
        }
    }
}

private struct SpendingOverviewCard: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("Total Spending")
                .font(.body)
                .foregroundStyle(.black)
            Text("Rp250.000")
                .font(.title2)
                .foregroundStyle(.black)
                .bold()
        }
        .padding(24.0)
        .background {
            RoundedRectangle(cornerRadius: 16.0)
                .fill(.white)
                .shadow(color: .black, radius: 0.5)
        }
    }
}

private struct SpendingRecentItemView: View {
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4.0) {
                Text("The Brew House")
                    .font(.headline)
                
                Text("Latte")
                    .font(.caption)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4.0) {
                Text("Rp23.000")
                    .font(.body)
                
                Text("2/18/2/2026")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 18.0)
        .padding(.vertical, 12.0)
        .background {
            RoundedRectangle(cornerRadius: 16.0)
                .fill(.white)
                .shadow(color: .black, radius: 0.5)
        }
    }
}

#Preview {
    SpendingOverviewView()
}
