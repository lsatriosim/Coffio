//
//  ProfileView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 08/04/26.
//


import SwiftUI

struct ProfileView: View {
    let authService: AuthenticationService = .shared
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoggedIn {
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            // MARK: - Profile Header
                            profileHeader
                            .padding(.top, 40)
                            
                            
                            // MARK: - Settings Section
                            VStack(spacing: 0) {
                                
                                SettingsRow(
                                    icon: "person.circle",
                                    title: "Edit Profile",
                                    onClick: {
                                        viewModel.showEditProfile = true
                                    }
                                )
                                Divider()
                                SettingsRow(
                                    icon: "arrow.right.square",
                                    title: "Logout",
                                    color: .red,
                                    onClick: { viewModel.onLogoutButtonDidTap() }
                                )
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 5)
                            )
                            .padding(.horizontal)
                            
                            Spacer()
                        }
                    }
                }
                else {
                    notLoggedInView
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $viewModel.showEditProfile) {
//                NavigationStack {
//                    DetailProfileView(userId: authState.userId ?? "")
//                }
            }
        }
        .task {
            viewModel.onViewDidLoad()
        }
    }
    
    var profileHeader: some View {
        VStack(spacing: 12) {
            if let imageUrl = viewModel.imageUrl,
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
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                
            } else {
                placeholderView
            }
            
            Text(viewModel.fullName)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(viewModel.email)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    private var placeholderView: some View {
        Circle()
            .fill(Color.blue.opacity(0.2))
            .frame(width: 100, height: 100)
            .overlay(
                Text(viewModel.initialName)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.blue)
            )
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

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let onClick: () -> Void
    
    init(icon: String, title: String, color: Color = .blue, onClick: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.color = color
        self.onClick = onClick
    }
    
    var body: some View {
        Button {
            onClick()
        } label: {
            HStack(spacing: 16) {
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.body)
                    .foregroundStyle(color)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
        }

    }
}

#Preview {
    ProfileView()
}
