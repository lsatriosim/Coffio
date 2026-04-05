//
//  LoginView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 05/04/26.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: AuthViewModel = AuthViewModel()

    var body: some View {
        VStack(spacing: -80.0) {
            AuthHeaderView(
                title: "Invoicely",
                ctaLabel: "Doesn't have an account?",
                trailingText: "Get Started",
                trailingAction: { viewModel.updateShowRegister(isPresented: true)
                }
            )
            HStack(alignment: .center) {
                Spacer()
                
                VStack(alignment: .center, spacing: 24.0) {
                    form
                    .padding(.top, 36.0)
                    
                    Button(action: {
                        //TODO: add forgot password
                    }) {
                        Text("Forgot your password?")
                            .font(.body)
                            .foregroundStyle(.black)
                    }
                }
                
                Spacer()
            }
            .background(.white)
            .cornerRadius(24.0)
            
            Spacer()
        }
        .fullScreenCover(isPresented: $viewModel.showRegister) {
            RegisterView(viewModel: viewModel)
        }
    }
    
    private var form: some View {
        VStack(spacing: 16.0) {
            Text("Welcome Back")
                .font(.title)
                .bold()
            
            Text("Enter your details below")
                .font(.body)
            
            VStack(alignment: .leading, spacing: 16.0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4.0) {
                        Text("Email Address")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        
                        TextField("Email Address", text: $viewModel.email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .textFieldStyle(.plain)
                    }
                    Spacer()
                }
                .padding(8.0)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.gray.opacity(0.8))
                        .shadow(color: .black.opacity(0.1), radius: 10)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 4.0) {
                        Text("Password")
                            .font(.caption)
                            .foregroundStyle(.gray)
                        
                        SecureField("Password", text: $viewModel.password)
                            .textFieldStyle(.plain)
                    }
                    Spacer()
                }
                .padding(8.0)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.gray.opacity(0.8))
                        .shadow(color: .black.opacity(0.1), radius: 10)
                }
                
                if let errorMessage: String = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.body)
                        .foregroundStyle(.red)
                }
                
                Button {
                    Task {
                        await viewModel.login()
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Sign in")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .bold()
                        Spacer()
                    }
                    .padding(.vertical, 16.0)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill( LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.9),
                                    Color.purple.opacity(0.9)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .shadow(color: .black.opacity(0.1), radius: 10)
                    }
                }
                
            }
            .padding(.horizontal, 16.0)
        }
    }
    
    private var separatorLine: some View {
        HStack {
            Rectangle()
                .fill(.gray)
                .frame(height: 1.0)
            
            Text("Or")
                .font(.caption)
                .foregroundStyle(.black)
            
            Rectangle()
                .fill(.gray)
                .frame(height: 1.0)
        }
    }
}


#Preview {
    LoginView()
}
