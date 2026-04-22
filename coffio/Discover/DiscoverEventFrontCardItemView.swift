//
//  DiscoverEventFrontCardItemView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/04/26.
//

import SwiftUI

struct DiscoverEventFrontCardItemView: View {
    let cardHeight: CGFloat = 320
    let dataModel: DiscoverEventItem
    @EnvironmentObject var viewModel: DiscoverEventListViewModel
    
    var body: some View {
        NavigationLink {
            DiscoverDetailEventView(dataModel: dataModel)
                .environmentObject(viewModel)
        } label: {
            VStack(alignment: .leading, spacing: 8.0) {
                ZStack(alignment: .topLeading) {
                    if let imageUrl = dataModel.imageUrl,
                       let url = URL(string: imageUrl) {
                        
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                
                            case .failure(_), .empty:
                                placeholderView
                                
                            @unknown default:
                                placeholderView
                            }
                        }
                        .frame(width: .infinity, height: cardHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                    } else {
                        placeholderView
                    }
                }
                .frame(width: .infinity, height: cardHeight)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(alignment: .leading, spacing: 4.0) {
                    Text(dataModel.title)
                        .font(.headline)
                        .bold()
                        .lineLimit(2)
                        .truncationMode(.tail)
                    HStack {
                        Text(DateFormatterUtil.formatDate(dataModel.eventDate))
                            .font(.body)
                        Spacer()
                        if let cafeName = dataModel.cafeName {
                            Text(cafeName)
                                .font(.body)
                        }
                    }
                    
                    HStack(alignment: .bottom) {
                        Text(dataModel.price == 0 ? "Free" : PriceUtil.formatLong(dataModel.price))
                            .font(.title3)
                            .bold()
                            .foregroundStyle(Color(hex: "ad6928"))
                        Spacer()
                        Text("\(dataModel.capacity - dataModel.participantRegistered) slot(s) left")
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .frame(width: .infinity)
        }
        .buttonStyle(.plain)
    }
    
    var placeholderView: some View {
        Image("il_cafe")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: .infinity, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    DiscoverEventFrontCardItemView(dataModel: discoverEventMock[0])
}
