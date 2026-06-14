//
//  EventFormSheet.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 12/06/26.
//

import SwiftUI
import PhotosUI

// MARK: - Enums
enum TicketType: String, CaseIterable, Identifiable {
    case free = "Free"
    case paid = "Paid"
    var id: String { self.rawValue }
}

struct EventFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EventFormViewModel
    
    // Photo Picker States
    @State private var posterItem: PhotosPickerItem?
    @State private var posterImage: Image?
    
    @State private var menuItem: PhotosPickerItem?
    @State private var menuImage: Image?
    
    // MARK: - Dedicated Mode Dependency Initializer
    init(editingEvent event: DiscoverEventItem? = nil) {
        // Wire state object explicitly to feed dependencies forward safely
        _viewModel = StateObject(wrappedValue: EventFormViewModel(editingEvent: event))
    }
    
    private var selectedShopName: String {
        if let id = viewModel.selectedCoffeeShopId,
           let shop = viewModel.coffeeShops.first(where: { "\($0.id)".description.lowercased() == id.lowercased() }) {
            return shop.name
        }
        return "Select a place..."
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 6)
                    .padding(.top, 12)
                
                ScrollView {
                    VStack(spacing: 24.0) {
                        // Dynamic Headers Based on Mode state
                        VStack(spacing: 8.0) {
                            Text(isEditingMode ? "Update Event Profile" : "Create New Event")
                                .font(.title2)
                                .bold()
                            
                            Text(isEditingMode ? "Modify details regarding this board game configuration" : "Host and share a new board game experience")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                        .padding(.top, 8)
                        
                        // Form Inputs Container
                        VStack(alignment: .leading, spacing: 20.0) {
                            
                            // 1. Core Event Text Data Fields
                            inputField(label: "Event Title", placeholder: "e.g., Brew & Tiles (Mahjong)", text: $viewModel.title)
                            
                            inputTextArea(label: "Description", placeholder: "Describe what makes this session special...", text: $viewModel.description)
                            
                            CoffioPhotoPickerField(
                                label: "Event Poster",
                                placeholder: "Choose event poster",
                                selectedItem: $posterItem,
                                selectedImage: $posterImage,
                                remoteUrlString: viewModel.existingPosterUrl
                            )
                            
                            CoffioPhotoPickerField(
                                label: "Menu Image",
                                placeholder: "Choose menu selection image",
                                selectedItem: $menuItem,
                                selectedImage: $menuImage,
                                remoteUrlString: viewModel.existingMenuUrl
                            )
                            
                            // 3. Date & Time Block Wrapped inside an Apple-Style Inset Card
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Date & Timing")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                    .padding(.leading, 4)
                                
                                VStack(spacing: 12) {
                                    DatePicker("Starts", selection: $viewModel.startTime, displayedComponents: [.date, .hourAndMinute])
                                        .font(.body)
                                    
                                    Divider()
                                    
                                    DatePicker("Ends", selection: $viewModel.endTime, displayedComponents: [.date, .hourAndMinute])
                                        .font(.body)
                                }
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 12).fill(.white).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                            }
                            
                            // 4. Location Details Block
                            VStack(alignment: .leading, spacing: 4.0) {
                                Text("Coffee Shop Partner")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                    .padding(.leading, 4)
                                
                                NavigationLink {
                                    CoffeeShopSelectionView(
                                        coffeeShops: viewModel.coffeeShops,
                                        selectedId: $viewModel.selectedCoffeeShopId
                                    )
                                } label: {
                                    HStack {
                                        Text(selectedShopName)
                                            .foregroundStyle(viewModel.selectedCoffeeShopId == nil ? .gray.opacity(0.8) : .primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .font(.footnote)
                                            .foregroundStyle(.gray)
                                    }
                                    .padding(14.0)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "ad6928").opacity(0.4), lineWidth: 1.5)
                                    )
                                }
                                .buttonStyle(.plain)
                                .onChange(of: viewModel.selectedCoffeeShopId) { oldValue, selectedId in
                                    if let selectedId = selectedId,
                                       let chosenShop = viewModel.coffeeShops.first(where: { "\($0.id)".description.lowercased() == selectedId.lowercased() }) {
                                        viewModel.cafeName = chosenShop.name
                                        viewModel.fullAddress = chosenShop.address
                                    }
                                }
                            }
                            
                            inputField(label: "Venue / Cafe Name", placeholder: "e.g., Yellow Fox - Pluit", text: $viewModel.cafeName)
                            inputField(label: "Full Address", placeholder: "Enter complete structural street address details", text: $viewModel.fullAddress)
                            
                            // 5. Logistics Configuration Segment Card
                            inputField(label: "Capacity Limit", placeholder: "e.g., 16", text: $viewModel.capacity, keyboardType: .numberPad)
                            
                            segmentedControlField(label: "Registration System", selection: $viewModel.registrationMethod) {
                                Text("Internal (App)").tag(RegistrationType.internal)
                                Text("External URL").tag(RegistrationType.external)
                            }
                            
                            segmentedControlField(label: "Ticket Type", selection: $viewModel.ticketType) {
                                ForEach(TicketType.allCases) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            
                            // 6. Paid Fields Inset Card (Animated Conditional Transition Block)
                            if viewModel.ticketType == .paid {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Financial Payment Routing Info")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                        .bold()
                                        .padding(.leading, 4)
                                    
                                    inputField(label: "Ticket Price (IDR)", placeholder: "e.g., 90000", text: $viewModel.ticketPrice, keyboardType: .numberPad)
                                    inputField(label: "Bank / E-Wallet Name", placeholder: "e.g., BCA, Mandiri, GoPay", text: $viewModel.bankName)
                                    inputField(label: "Account Number", placeholder: "Enter routing account destination number", text: $viewModel.accountNumber, keyboardType: .numberPad)
                                    inputField(label: "Account Holder Name", placeholder: "e.g., Novani Sutikno", text: $viewModel.accountHolderName)
                                }
                                .padding(16)
                                .background {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.orange.opacity(0.04))
                                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "ad6928").opacity(0.15), lineWidth: 1))
                                }
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // MARK: - Streamlined Component Implementation Block
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .padding(.vertical, 12)
                            } else {
                                CoffioButton(
                                    title: isEditingMode ? "Update Changes" : "Publish Event",
                                    icon: isEditingMode ? "checkmark.circle.fill" : "paperplane.fill",
                                    style: .primary,
                                    isDisabled: isFormInvalid
                                ) {
                                    handleSubmitAction()
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                }
            }
            .background(Color(hex: "f2efed"))
            .navigationBarTitleDisplayMode(.inline)
            .animation(.easeInOut(duration: 0.25), value: viewModel.ticketType)
            .task {
                await viewModel.loadCoffeeShopLookupData()
            }
            .coffioPopup(isPresented: $viewModel.isError) {
                VStack(spacing: 16) {
                    Text(viewModel.errorMessage)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                    
                    CoffioButton(title: "Close", style: .secondary) {
                        viewModel.isError = false
                    }
                }
                .padding(16)
            }
        }
    }
}

// MARK: - Secondary View Subcomponents Extension
private extension EventFormSheet {
    
    // Core structural checker toggles
    var isEditingMode: Bool {
        switch viewModel.mode {
        case .create: return false
        case .edit: return true
        }
    }
    
    var isFormInvalid: Bool {
        // 💡 Adjusted verification condition: a valid form needs EITHER a new local image input OR an existing storage URL reference from Supabase
        let missingPoster = (posterImage == nil && viewModel.existingPosterUrl == nil)
        
        return viewModel.title.isEmpty ||
               viewModel.description.isEmpty ||
               viewModel.cafeName.isEmpty ||
               viewModel.fullAddress.isEmpty ||
               viewModel.capacity.isEmpty ||
               missingPoster
    }
    
    func handleSubmitAction() {
        viewModel.publishEvent(posterImage: posterImage, menuImage: menuImage) {
            dismiss()
        }
    }
    
    @ViewBuilder
    func inputField(label: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.leading, 4)
            
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textFieldStyle(.plain)
                .padding(12.0)
                .background(fieldBackground)
        }
    }
    
    @ViewBuilder
    func inputTextArea(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.leading, 4)
            
            TextEditor(text: text)
                .frame(minHeight: 100)
                .padding(8)
                .background(fieldBackground)
                .overlay(alignment: .topLeading) {
                    if text.wrappedValue.isEmpty {
                        Text(placeholder)
                            .foregroundStyle(.gray.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 14)
                            .allowsHitTesting(false)
                    }
                }
        }
    }
    
    @ViewBuilder
    func segmentedControlField<SelectionValue: Hashable, Content: View>(
        label: String,
        selection: Binding<SelectionValue>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6.0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.leading, 4)
            
            Picker(label, selection: selection, content: content)
                .pickerStyle(.segmented)
        }
    }
    
    @ViewBuilder
    func photoPickerField(
        label: String,
        placeholder: String,
        selectedImage: Image?,
        remoteUrlString: String? = nil, // 💡 Holds existing asset URL context paths
        isPresented: Binding<Bool>,
        selection: Binding<PhotosPickerItem?>
    ) -> some View {
        VStack(alignment: .leading, spacing: 4.0) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.leading, 4)

            Button {
                isPresented.wrappedValue = true
            } label: {
                HStack {
                    Image(systemName: "photo")
                        .foregroundStyle(Color(hex: "ad6928"))

                    let hasAsset = (selectedImage != nil || remoteUrlString != nil)
                    Text(hasAsset ? "Change image selection" : placeholder)
                        .foregroundStyle(hasAsset ? .primary : Color.gray)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                .padding(12)
                .background(fieldBackground)
            }
            .buttonStyle(.plain)
            .photosPicker(
                isPresented: isPresented,
                selection: selection,
                matching: .images
            )
            
            if let selectedImage {
                ZStack {
                    Color.white
                    selectedImage
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 180)
                        .padding(8)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                .padding(.top, 4)
                
            } else if let remoteUrlString, let url = URL(string: remoteUrlString) {
                ZStack {
                    Color.white
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 180)
                                .padding(8)
                        case .failure, .empty:
                            Color.gray.opacity(0.1)
                                .frame(height: 120)
                                .overlay(Image(systemName: "photo").foregroundStyle(.gray))
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                .padding(.top, 4)
            }
        }
        .onChange(of: selection.wrappedValue) { oldValue, newValue in
            Task {
                if let loaded = try? await newValue?.loadTransferable(type: Image.self) {
                    if label == "Event Poster" {
                        self.posterImage = loaded
                    } else {
                        self.menuImage = loaded
                    }
                }
            }
        }
    }
    
    var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.02), radius: 4)
    }
}

// MARK: - Preview Engine Wrapper
#Preview {
    EventFormSheet()
}

// MARK: - Preview Engine Wrapper
#Preview {
    EventFormSheet()
}
