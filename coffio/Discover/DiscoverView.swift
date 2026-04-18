//
//  HomeView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/03/26.
//

import SwiftUI

struct HomeView: View {
    @State var selectedCategory: Int = 0
    
    var body: some View {
        VStack(spacing: 0.0) {
            categoriesTab
            .padding(.horizontal, 24.0)
            
            contentView
            
            Spacer()
        }
    }
    
    var categoriesTab: some View {
        HStack(alignment: .top) {
            Spacer()
            createCategoryMenu(label: "Cafe", imageName: "house", isSelected: selectedCategory == 0) {
                withAnimation {
                    selectedCategory = 0
                }
            }
            Spacer()
            Spacer()
            createCategoryMenu(label: "Event", imageName: "calendar", isSelected: selectedCategory == 1) {
                withAnimation {
                    selectedCategory = 1
                }
            }
            Spacer()
        }
        .padding(.vertical, 16.0)
        .background(.white)
    }
    
    var contentView: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 24.0) {
                DiscoverFrontCardListView()
            }
            .padding(.vertical, 20.0)
        }
        .background(Color(hex: "FAFAFA"))
    }
    
    func createCategoryMenu(
        label: String,
        imageName: String,
        isSelected: Bool,
        onClick: @escaping () -> Void
    ) -> some View {
        Button(action: onClick) {
            HStack {
                Spacer()
                Text(label)
                    .font(.headline)
                    .foregroundStyle(isSelected ? .white : .gray)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 12.0)
                    .fill(isSelected ? Color(hex: "ad6928") : Color(hex: "d8cec5"))
            }
        }
    }
}

#Preview {
    HomeView()
}
