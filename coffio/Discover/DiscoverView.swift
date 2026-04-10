//
//  HomeView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/03/26.
//

import SwiftUI

struct HomeView: View {
    @State var searchInput: String = ""
    @State var selectedCategory: Int = 0
    
    var body: some View {
        VStack(spacing: 0.0) {
            searchBar
            .padding(.horizontal, 24.0)
            
            categoriesTab
            .padding(.horizontal, 24.0)
            
            Rectangle()
                .fill(.gray)
                .frame(width: .infinity, height: 1.0)
                .opacity(0.25)
            
            contentView
            
            Spacer()
        }
    }
    
    var searchBar: some View {
        HStack {
            Spacer()
            TextField(text: $searchInput) {
                HStack(alignment: .bottom, spacing: 4.0) {
                    Label("Start your Search", systemImage: "magnifyingglass")
                }
            }
            Spacer()
        }
        .padding(.horizontal, 12.0)
        .padding(.vertical, 8.0)
        .overlay {
            RoundedRectangle(cornerRadius: 16.0)
                .fill(.clear)
                .stroke(.black, lineWidth: 0.5)
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
        .padding(.top, 16.0)
    }
    
    var contentView: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 24.0) {
                DiscoverFrontCardListView()
            }
            .padding(.vertical, 20.0)
        }
    }
    
    func createCategoryMenu(
        label: String,
        imageName: String,
        isSelected: Bool,
        onClick: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .center, spacing: 4.0) {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36.0, height: 36.0)
                .foregroundStyle(isSelected ? .orange : .black)
            Text(label)
                .font(.callout)
                .foregroundStyle(isSelected ? .orange : .black)
            
            if isSelected {
                RoundedRectangle(cornerRadius: 12.0)
                    .fill(.orange)
                    .frame(width: 16.0, height: 2.0)
            }
        }
        .onTapGesture {
            onClick()
        }
    }
}

#Preview {
    HomeView()
}
