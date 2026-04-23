//
//  DiscoverDetailEventView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 23/03/26.
//

import SwiftUI

private let kImageHeight: CGFloat = 320.0

struct DiscoverDetailEventView: View {
    @Environment(\.dismiss) private var dismiss
    let dataModel: DiscoverEventItem
    
    @State var showRegistrationSheet: Bool = false
    @EnvironmentObject var viewModel: DiscoverEventListViewModel
    
    private var capacityLabel: String {
        switch dataModel.registrationType {
        case .internal:
            "\(dataModel.participantRegistered)/\(dataModel.capacity)"
        case .external:
            "\(dataModel.capacity)"
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0.0) {
                    ZStack(alignment: .topLeading) {
                        if let imageUrl = dataModel.imageUrl {
                            carouselItem(imageUrl: imageUrl)
                            .frame(height: kImageHeight)
                        }
                        else {
                            placeholderView
                        }
                    }
                    .frame(height: kImageHeight)
                    
                    content
                        .padding(.horizontal, 24.0)
                        .padding(.top, 24.0)
                    Spacer()
                }
            }
            
            HStack {
                DiscoverTopButtonView(iconName: "chevron.left") {
                    dismiss()
                }
                Spacer()
                DiscoverTopButtonView(iconName: "square.and.arrow.up") {
                    
                }
            }
            .padding(.horizontal, 24.0)
            .padding(.top, 72.0)
        }
        .background(Color(hex: "f2efed"))
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showRegistrationSheet) {
            EventRegistrationSheet(eventId: dataModel.id, paymentInfo: dataModel.paymentInfo)
                .environmentObject(viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
    }
    
    var content: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            Text(dataModel.title)
                .font(.title)
                .foregroundStyle(Color(hex: "642e13"))
                .bold()
            
            GeneralInfoCardItemView(
                imageName: "calendar",
                title: "Date",
                value: DateFormatterUtil.formatDateRange(
                    start: dataModel.eventDate,
                    end: dataModel.endDate
                ),
                subtitle: nil
            )
            
            if let cafeName = dataModel.cafeName, let location = dataModel.location {
                GeneralInfoCardItemView(
                    imageName: "mappin",
                    title: "Location",
                    value: cafeName,
                    subtitle: location
                )
            }
            
            HStack(alignment: .center, spacing: 8.0) {
                GeneralInfoCardItemView(
                    imageName: "person",
                    title: "Quota",
                    value: capacityLabel,
                    subtitle: nil
                )
                
                GeneralInfoCardItemView(
                    imageName: "dollarsign.circle",
                    title: "Price",
                    value: dataModel.price == 0 ? "Free" : PriceUtil.formatLong(dataModel.price),
                    subtitle: nil
                )
            }
            
            if let description = dataModel.description {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            
            if dataModel.registrationType == .internal || (dataModel.registrationType == .external && dataModel.externalRegistrationURL != nil) {
                Button(action: {
                    switch dataModel.registrationType {
                    case .internal:
                        showRegistrationSheet = true
                    case .external:
                        if let externalUrl: String = dataModel.externalRegistrationURL, let url: URL = URL(string: externalUrl) {
                            UIApplication.shared.open(url)
                        }
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Register")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "ad6928"))
                }
            }
        }
    }
    
    @ViewBuilder
    private func carouselItem(imageUrl: String) -> some View {
        if let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: kImageHeight)
                        .clipped()

                case .failure(_), .empty:
                    placeholderView

                @unknown default:
                    placeholderView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: kImageHeight)
            .background(Color.clear)

        } else {
            placeholderView
        }
    }
    
    private var placeholderView: some View {
        GeometryReader { geo in
            Image("il_cafe")
                .resizable()
                .frame(width: geo.size.width)
                .aspectRatio(1.2, contentMode: .fit) // adjust height ratio
        }
        .frame(height: kImageHeight)
    }
}

private struct GeneralInfoCardItemView: View {
    let imageName: String
    let title: String
    let value: String
    let subtitle: String?
    
    var body: some View {
        HStack(alignment: .center, spacing: 12.0) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 20.0, height: 20.0)
                .foregroundStyle(Color(hex: "ad6928"))
            VStack(alignment: .leading, spacing: 4.0) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                if let subtitle {
                    Text(value)
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
                else {
                    Text(value)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
            }
            Spacer()
        }
        .padding(.leading, 12.0)
        .padding(.vertical, 8.0)
        .background {
            RoundedRectangle(cornerRadius: 16.0)
                .fill(.white)
        }
    }
}

private struct DiscoverDetailItemView: View {
    let iconName: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 4.0) {
            Image(systemName: iconName)
            Text(text)
            Spacer()
        }
    }
}

private struct DiscoverTopButtonView: View {
    let iconName: String
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.black)
        }
        .padding(8.0)
        .frame(width: 36.0, height: 36.0)
        .background(
            Circle()
                .fill(.white)
                .shadow(color: .black.opacity(0.3), radius: 12.0)
        )
    }
}

#Preview {
    DiscoverDetailEventView(dataModel: discoverEventMock[0])
}
