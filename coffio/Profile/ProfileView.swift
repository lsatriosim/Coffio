//
//  ProfileView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 08/04/26.
//


import SwiftUI
import _PhotosUI_SwiftUI

struct ProfileView: View {
    let authService: AuthenticationService = .shared
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    @State var showLogOutPopUp: Bool = false
    @State var popUpMessage: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color matching your reference style
                Color(hex: "f2efed")
                    .ignoresSafeArea()
                
                if viewModel.isLoggedIn {
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            // MARK: - Profile Header & Stats Card
                            VStack(spacing: 20) {
                                profileHeader
                                
                                Divider()
                                    .padding(.horizontal)
                            }
                            .background(RoundedCardBackground())
                            .padding(.horizontal)
                            .padding(.top, 20)
                            
                            // MARK: - Account Section
                            VStack(alignment: .leading, spacing: 12) {
                                sectionHeader("Account")
                                
                                VStack(spacing: 0) {
                                    SettingsRow(icon: "envelope", title: "Email", subtitle: viewModel.email) { }
                                    Divider().padding(.leading, 50)
                                    SettingsRow(icon: "bell", title: "Notifications") { }
                                    Divider().padding(.leading, 50)
                                    SettingsRow(icon: "lock", title: "Privacy & Security") { }
                                }
                                .background(RoundedCardBackground())
                            }
                            .padding(.horizontal)
                            
                            // MARK: - Support Section
                            VStack(alignment: .leading, spacing: 12) {
                                sectionHeader("Support")
                                
                                SettingsRow(icon: "questionmark.circle", title: "Help Center") { }
                                    .background(RoundedCardBackground())
                            }
                            .padding(.horizontal)
                            
                            // MARK: - Logout
                            SettingsRow(icon: "door.right.hand.open", title: "Logout", color: Color(hex: "ad6928")) {
                                showLogOutPopUp = true
                            }
                            .background(RoundedCardBackground())
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                        }
                    }
                } else {
                    notLoggedInView
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            viewModel.onViewDidLoad()
        }
        .coffioPopup(isPresented: $showLogOutPopUp) {
            VStack {
                Text("Are you sure want to logout?")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .bold()
                
                HStack {
                    Button(action: { showLogOutPopUp = false }) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundStyle(Color(hex: "ad6928"))
                            .padding(.vertical, 12.0)
                            .padding(.horizontal, 16.0)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "f2efed"))
                                    .stroke(Color(hex: "ad6928"), lineWidth: 1.0)
                            }
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        viewModel.onLogoutButtonDidTap() {
                            showLogOutPopUp = false
                        }
                    }) {
                        if viewModel.isLogoutLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                        else {
                            Text("Confirm")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 12.0)
                    .padding(.horizontal, 16.0)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "ad6928"))
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showEditProfile) {
            EditProfileView()
        }
    }
    
    // MARK: - Subviews
    
    var profileHeader: some View {
        HStack(spacing: 20) {
            PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    if viewModel.isLoadingImage {
                        ProgressView()
                            .frame(width: 80, height: 80)
                            .background(Circle().fill(Color.gray.opacity(0.1)))
                    } else if let imageUrl = viewModel.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image.resizable().scaledToFill()
                            } else {
                                placeholderCircle
                            }
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    } else {
                        placeholderCircle
                    }
                    
                    // Camera Icon overlay
                    Image(systemName: "camera.fill")
                        .font(.caption2)
                        .padding(5)
                        .background(Color(hex: "ad6928"))
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.fullName)
                    .font(.title3)
                    .bold()
                
                Text(viewModel.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Button("Edit Profile") {
                    viewModel.showEditProfile = true
                }
                .font(.footnote)
                .foregroundColor(Color(hex: "ad6928"))
                .padding(.top, 2)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
    
    private var placeholderCircle: some View {
        Circle()
            .fill(Color(hex: "ad6928").opacity(0.2))
            .frame(width: 80, height: 80)
            .overlay(
                Text(viewModel.initialName)
                    .font(.title)
                    .bold()
                    .foregroundColor(Color(hex: "ad6928"))
            )
    }
    
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .bold()
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(Color(hex: "633a14")) // Darker brown for headers
            .padding(.leading, 4)
    }
    
    private var notLoggedInView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Illustration or Icon
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
                authService.showLoginPage()
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

// MARK: - Shared UI Components

struct RoundedCardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.white)
            .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var color: Color = .primary
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color == .primary ? Color(hex: "ad6928") : color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(Color.white.opacity(0.001))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfileView()
}
