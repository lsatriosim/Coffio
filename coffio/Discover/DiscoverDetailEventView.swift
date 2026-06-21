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
    
    @State var showRegistrationSheet: Bool = false
    @State private var navigateToRegistrations = false
    
    @StateObject private var viewModel: DiscoverDetailEventViewModel
    @State private var isShowingPreview: Bool = false

    init(eventId: String, event: DiscoverEventItem? = nil) {
        _viewModel = StateObject(wrappedValue: DiscoverDetailEventViewModel(eventId: eventId, initialEvent: event))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(hex: "f2efed").ignoresSafeArea()
            
            if let dataModel = viewModel.event {
                renderContent(dataModel)
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.isError {
                Text("Failed to load event details.")
                    .foregroundStyle(.secondary)
            }
        }
        .task {
            await viewModel.fetchEventDetails()
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                }
            }
        }
        .sheet(isPresented: $viewModel.isEditEventSheetPresented) {
            EventFormSheet(editingEvent: viewModel.event)
                .presentationDetents([.large])
        }
        .onChange(of: viewModel.isEditEventSheetPresented) { oldValue, newValue in
            if newValue == false {
                Task {
                    await viewModel.fetchEventDetails()
                }
            }
        }
        .navigationDestination(isPresented: $navigateToRegistrations) {
            MyEventRegistrationListView(eventId: viewModel.eventId)
        }
        .overlay {
            if isShowingPreview {
                InteractiveImagePreview(
                    imageUrl: viewModel.event?.imageUrl,
                    isPresented: $isShowingPreview
                )
            }
        }
    }
    
    @ViewBuilder
    private func renderContent(_ dataModel: DiscoverEventItem) -> some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0.0) {
                ZStack(alignment: .topLeading) {
                    if let imageUrl = dataModel.imageUrl {
                        carouselItem(imageUrl: imageUrl)
                    } else {
                        placeholderView
                    }
                }
                .frame(height: kImageHeight)

                content(dataModel)
                    .padding(.horizontal, 24.0)
                    .padding(.top, 24.0)
                
                Spacer()
            }
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showRegistrationSheet) {
            EventRegistrationSheet(eventId: dataModel.id, paymentInfo: dataModel.paymentInfo)
                .environmentObject(viewModel)
                .presentationDetents([.large])
        }
    }

    // Pass dataModel into the existing content view logic
    private func content(_ dataModel: DiscoverEventItem) -> some View {
        VStack(alignment: .leading, spacing: 12.0) {
            Text(dataModel.title)
                .font(.title)
                .foregroundStyle(Color(hex: "642e13"))
                .bold()
            
            if let community = dataModel.communityInfo {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hosted By")
                        .font(.caption)
                        .bold()
                        .textCase(.uppercase)
                        .foregroundStyle(.gray)
                    
                    NavigationLink(destination: CommunityDetailView(communityId: dataModel.communityInfo?.id ?? "")) {
                        HStack(spacing: 12) {
                            // Community Avatar Circle
                            if let imgUrlStr = community.imageUrl, let url = URL(string: imgUrlStr) {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Color(hex: "fcede1")
                                }
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                            } else {
                                // Default fallback letter mark icon
                                ZStack {
                                    Circle().fill(Color(hex: "fcede1"))
                                    Text(String(community.name.prefix(1)).uppercased())
                                        .font(.headline)
                                        .bold()
                                        .foregroundStyle(Color(hex: "642e13"))
                                }
                                .frame(width: 44, height: 44)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(community.name)
                                    .font(.body)
                                    .bold()
                                    .foregroundStyle(.primary)
                                
                                if let desc = community.description {
                                    Text(desc)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.gray)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.02), radius: 4, x: 0, y: 2)
                        )
                    }
                }
                .padding(.vertical, 4)
            }

            GeneralInfoCardItemView(
                imageName: "calendar",
                title: "Date",
                value: DateFormatterUtil.formatDateRange(start: dataModel.eventDate, end: dataModel.endDate),
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
                    value: dataModel.registrationType == .internal ?
                        "\(dataModel.participantRegistered)/\(dataModel.capacity)" : "\(dataModel.capacity)",
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
            
            switch dataModel.registrationType {
            case .internal:
                if viewModel.isAuthor {
                    VStack(spacing: 12.0) {
                        CoffioButton(title: "Edit Event", style: .secondary) {
                            viewModel.isEditEventSheetPresented = true
                        }
                        
                        if dataModel.eventStatus == .rejected {
                            CoffioInfoBox(
                                type: .failed,
                                title: "Submission Rejected",
                                description: "Please edit and review your event verification details, location description, or ticket pricing format before submitting for verification again."
                            )
                            .padding(.top, 2)
                        }
                        
                        if viewModel.event?.eventStatus != .rejected {
                            CoffioButton(title: viewModel.event?.eventStatus == .approved ? "See Participant" : "Waiting for Approval", isDisabled: viewModel.event?.eventStatus == .pending) {
                                navigateToRegistrations = true
                            }
                        }
                    }
                }
                else if viewModel.isAlreadyRegistered {
                    Button(action: {}) {
                        Text("You've already registered")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "ad6928")))
                    }
                    .disabled(true)
                    .opacity(0.6)
                }
                else if dataModel.slotLeft <= 0 {
                    CoffioButton(title: "Sold Out", isDisabled: true) {}
                }
                else {
                    CoffioButton(title: "Register") {
                        guard viewModel.authService.user != nil else {
                            viewModel.authService.showLoginPage()
                            return
                        }
                        showRegistrationSheet = true
                    }
                }
            case .external:
                Button(action: {
                    guard viewModel.authService.user != nil else {
                        viewModel.authService.showLoginPage()
                        return
                    }
                    if let urlStr = dataModel.externalRegistrationURL, let url = URL(string: urlStr) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Register")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(hex: "ad6928")))
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
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isShowingPreview = true
                }
            }
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
