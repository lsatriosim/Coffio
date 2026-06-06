//
//  AddSpendingView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 06/06/26.
//

import SwiftUI
import PhotosUI

struct AddSpendingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SpendingViewModel
    
    // Form Input States
    @State private var cafeName: String = ""
    @State private var amountString: String = ""
    @State private var quantityString: String = "1"
    @State private var transactionDate: Date = Date()
    @State private var selectedCoffeeShopId: String? = nil
    @State private var notes: String = ""
    
    // Receipt Attachment States
    @State private var imageSelection: PhotosPickerItem? = nil
    @State private var selectedUIImage: UIImage? = nil
    @State private var attachedFileName: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24.0) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 6)
                        .padding(.top, 12)
                    
                    VStack(spacing: 8.0) {
                        Text("Record Coffee Spend")
                            .font(.title2)
                            .bold()
                        
                        Text("Track your daily coffee consumption finances")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 18.0) {
                        // Item Name Field
                        inputField(label: "Item Name *", placeholder: "e.g. Iced Caffe Latte", text: $cafeName)
                        
                        // Total Price & Quantity Layout Splitting Form Group
                        HStack(alignment: .top, spacing: 16.0) {
                            inputField(label: "Total Price (Rp) *", placeholder: "45000", text: $amountString, keyboardType: .numberPad)
                            
                            inputField(label: "Quantity", placeholder: "1", text: $quantityString, keyboardType: .numberPad)
                                .frame(width: 100)
                        }
                        
                        // Transaction Date Field View Layout
                        VStack(alignment: .leading, spacing: 6.0) {
                            Text("Date *")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "5c4033"))
                                .padding(.leading, 2)
                            
                            DatePicker("", selection: $transactionDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .padding(10.0)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                }
                        }
                        
                        // Coffee Shop Optional Fetch-Populated Menu Picker
                        VStack(alignment: .leading, spacing: 6.0) {
                            Text("Coffee Shop (Optional)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "5c4033"))
                                .padding(.leading, 2)
                            
                            NavigationLink {
                                CoffeeShopSelectionView(
                                    coffeeShops: viewModel.coffeeShops,
                                    selectedId: $selectedCoffeeShopId
                                )
                            } label: {
                                HStack {
                                    Text(selectedShopName)
                                        .foregroundStyle(selectedCoffeeShopId == nil ? .gray.opacity(0.8) : .primary)
                                    
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
                        }
                        
                        // Notes Custom Input Layout Box Section
                        inputField(label: "Notes (Optional)", placeholder: "e.g. Treat for a friend", text: $notes)
                        
                        // Receipt File Image Handler UI Layout Setup
                        VStack(alignment: .leading, spacing: 6.0) {
                            Text("Receipt (Optional)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(hex: "5c4033"))
                                .padding(.leading, 2)
                            
                            HStack(spacing: 12.0) {
                                PhotosPicker(selection: $imageSelection, matching: .images) {
                                    Text("Choose File")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color(hex: "5c4033"))
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 14)
                                        .background(Color.gray.opacity(0.15))
                                        .cornerRadius(8)
                                }
                                
                                Text(attachedFileName.isEmpty ? "No file chosen" : attachedFileName)
                                    .font(.subheadline)
                                    .foregroundStyle(attachedFileName.isEmpty ? .gray : .primary)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                if selectedUIImage != nil {
                                    Button(action: {
                                        selectedUIImage = nil
                                        attachedFileName = ""
                                        imageSelection = nil
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.gray)
                                    }
                                }
                            }
                            .padding(10.0)
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Bottom Modal Interaction Action Row Controls Stack
                    HStack(spacing: 16.0) {
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        Button(action: {
                            let finalAmount = Int(amountString) ?? 0
                            let finalQuantity = Int(quantityString) ?? 1
                            
                            viewModel.saveSpending(
                                itemName: cafeName,
                                amount: finalAmount,
                                quantity: finalQuantity,
                                date: transactionDate,
                                coffeeShopId: selectedCoffeeShopId,
                                notes: notes.isEmpty ? nil : notes,
                                receiptImage: selectedUIImage
                            ) {
                                dismiss()
                            }
                        }) {
                            HStack {
                                Spacer()
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Save Purchase")
                                        .font(.headline)
                                        .bold()
                                        .foregroundStyle(.white)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 14)
                            .background(Color(hex: "8b5a2b")) // Matches the classic rich brown palette button
                            .cornerRadius(12)
                        }
                        .disabled(isFormInvalid || viewModel.isLoading)
                        .opacity(isFormInvalid ? 0.5 : 1.0)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    Spacer()
                }
            }
            .background(Color(hex: "f8f6f4")) // Off-white minimalist backdrop color structure
            .onAppear {
                viewModel.loadInitialData()
            }
            .onChange(of: imageSelection) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedUIImage = uiImage
                        attachedFileName = "receipt_\(Int(Date().timeIntervalSince1970)).jpg"
                    }
                }
            }
        }
    }
    
    private var selectedShopName: String {
        if let id = selectedCoffeeShopId, let shop = viewModel.coffeeShops.first(where: { $0.id == id }) {
            return shop.name
        }
        return "Select a place..."
    }
    
    private var isFormInvalid: Bool {
        let parsedAmount = Int(amountString) ?? 0
        let parsedQuantity = Int(quantityString) ?? 0
        return cafeName.isEmpty || parsedAmount <= 0 || parsedQuantity <= 0
    }
    
    @ViewBuilder
    private func inputField(label: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6.0) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color(hex: "5c4033")) // Subdued deep cocoa brown accent tone hierarchy
                .padding(.leading, 2)
            
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textFieldStyle(.plain)
                .padding(14.0)
                .background(.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct CoffeeShopSelectionView: View {
    let coffeeShops: [CoffeeShopLookupItem]
    @Binding var selectedId: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            // "Clear Selection" Default Row
            Button(action: {
                selectedId = nil
                dismiss()
            }) {
                HStack {
                    Text("Select a place...")
                        .foregroundStyle(.gray)
                    Spacer()
                    if selectedId == nil {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color(hex: "8b5a2b")) // Custom asset brand color
                    }
                }
            }
            .foregroundColor(.primary)
            
            // Loop through your available Coffee Shop items
            ForEach(coffeeShops) { shop in
                Button(action: {
                    selectedId = shop.id
                    dismiss() // Bounces back to the main view immediately upon selection
                }) {
                    HStack {
                        Text(shop.name)
                        Spacer()
                        if selectedId == shop.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color(hex: "8b5a2b")) // Matching checkmark accent
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .listStyle(.plain) // Keeps the clean, minimalist look from your third screenshot
        .navigationTitle("Select Coffee Shop")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .bold()
                        .foregroundStyle(Color(hex: "5c4033"))
                }
            }
        }
    }
}
