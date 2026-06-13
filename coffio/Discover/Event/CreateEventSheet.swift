//
//  CreateEventSheet.swift
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

struct CreateEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateEventViewModel()
    
    // Photo Picker States
    @State private var posterItem: PhotosPickerItem?
    @State private var posterImage: Image?
    @State private var showPosterPicker = false
    
    @State private var menuItem: PhotosPickerItem?
    @State private var menuImage: Image?
    @State private var showMenuPicker = false
    
    private var selectedShopName: String {
        if let id = viewModel.selectedCoffeeShopId,
           let shop = viewModel.coffeeShops.first(where: { "\($0.id)".description.lowercased() == id.lowercased() }) {
            return shop.name
        }
        return "Select a place..."
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 6)
                    .padding(.top, 12)
                ScrollView {
                    VStack(spacing: 24.0) {
                        VStack(spacing: 8.0) {
                            Text("Create New Event")
                                .font(.title2)
                                .bold()
                            
                            Text("Host and share a new board game experience")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                        .padding(.top, 8)
                        
                        // Form Inputs Container
                        VStack(alignment: .leading, spacing: 20.0) {
                            
                            // 1. Core Event Text Data Fields
                            inputField(label: "Event Title", placeholder: "e.g., Brew & Tiles (Mahjong)", text: $viewModel.title)
                            
                            inputTextArea(label: "Description", placeholder: "Describe what makes this session special...", text: $viewModel.description)
                            
                            // 2. Photo Pickers Block
                            photoPickerField(
                                label: "Event Poster",
                                placeholder: "Choose event poster",
                                selectedImage: posterImage,
                                isPresented: $showPosterPicker,
                                selection: $posterItem
                            )
                            
                            photoPickerField(
                                label: "Menu Image",
                                placeholder: "Choose menu selection image",
                                selectedImage: menuImage,
                                isPresented: $showMenuPicker,
                                selection: $menuItem
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
                                    .padding(14.0) // Matches your exact text input field paddings
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hex: "ad6928").opacity(0.4), lineWidth: 1.5) // Your signature brown border
                                    )
                                }
                                .buttonStyle(.plain)
                                .onChange(of: viewModel.selectedCoffeeShopId) {
                                    if let selectedId = viewModel.selectedCoffeeShopId,
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
                        
                        // Primary Action Button Execution Layer
                        Button(action: handleCreationSubmit) {
                            HStack {
                                Spacer()
                                if viewModel.isLoading {
                                    ProgressView().progressViewStyle(.circular)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                }
                                else {
                                    Text("Publish Event")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .bold()
                                }
                                Spacer()
                            }
                            .padding(.vertical, 16.0)
                            .disabled(viewModel.isLoading)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "ad6928"))
                                    .shadow(color: .black.opacity(0.1), radius: 10)
                            }
                        }
                        .padding(.horizontal, 24)
                        .disabled(isFormInvalid)
                        .opacity(isFormInvalid ? 0.6 : 1.0)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .background(Color(hex: "f2efed"))
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
                
                Button(action: {
                    viewModel.isError = false
                }) {
                    HStack {
                        Spacer()
                        Text("Close")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.vertical, 12.0)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "ad6928"))
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(16)
        }
    }
}

// MARK: - Secondary View Subcomponents Extension
private extension CreateEventSheet {
    
    var isFormInvalid: Bool {
        viewModel.title.isEmpty || viewModel.description.isEmpty || viewModel.cafeName.isEmpty || viewModel.fullAddress.isEmpty || viewModel.capacity.isEmpty || posterImage == nil
    }
    
    func handleCreationSubmit() {
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

                    Text(selectedImage == nil ? placeholder : "Change image selection")
                        .foregroundStyle(selectedImage == nil ? .gray : .primary)

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
                selectedImage
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 4)
            }
        }
        // Extraction assignment engine listener
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
    CreateEventSheet()
}
