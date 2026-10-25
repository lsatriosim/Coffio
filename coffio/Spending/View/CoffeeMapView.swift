//
//  CoffeeMapView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/10/26.
//

import UIKit
import MapKit
import SwiftUI

struct CoffeeMapView: View {
    let logs: [CoffeeLogEntry]
    
    @ObservedObject private var locationProvider = LocationProvider.shared
    @State private var selectedLog: CoffeeLogEntry? = nil
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    private let primaryBrown = Color(hex: "ad6928")

    var body: some View {
        Group {
            // Check if location authorization is denied or restricted
            if CLLocationManager().authorizationStatus == .denied ||
               CLLocationManager().authorizationStatus == .restricted {
                
                // Blocked state view
                VStack(spacing: 16) {
                    Image(systemName: "location.slash.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("Location Access Required")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("To view your coffee trail map, please enable location permissions in your device settings.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(primaryBrown)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
                
            } else {
                // Active Map View
                ZStack(alignment: .bottom) {
                    Map(position: $cameraPosition) {
                        UserAnnotation()
                        
                        // Only plot logs that contain valid coordinates
                        ForEach(logs.filter { $0.coordinate != nil }) { log in
                            if let coordinate = log.coordinate {
                                Annotation(log.coffeeName, coordinate: coordinate) {
                                    Button(action: { selectedLog = log }) {
                                        AsyncImage(url: URL(string: log.imageUrl)) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image.resizable().scaledToFit()
                                            default:
                                                Image(systemName: "cup.and.saucer.fill")
                                            }
                                        }
                                        .frame(width: 40, height: 40)
                                        .background(Circle().fill(Color.white))
                                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                        .overlay(Circle().stroke(primaryBrown, lineWidth: 2))
                                    }
                                }
                            }
                        }
                    }
                    .ignoresSafeArea(edges: [.horizontal, .bottom])
                    
                    // Selected Coffee Popup Card
                    if let log = selectedLog {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                AsyncImage(url: URL(string: log.imageUrl)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFit()
                                    default:
                                        Image(systemName: "cup.and.saucer.fill").foregroundColor(primaryBrown)
                                    }
                                }
                                .frame(width: 48, height: 48)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(log.coffeeName).font(.headline)
                                    if let selectedLog {
                                        Text("Spent: \(formatIDR(selectedLog.price))")
                                            .font(.subheadline)
                                            .foregroundColor(primaryBrown)
                                    }
                                    
                                    if let coordinate = log.coordinate,
                                       let distance = locationProvider.calculateDistance(latitude: coordinate.latitude, longitude: coordinate.longitude) {
                                        Text("\(distance.1) away")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                Button(action: { selectedLog = nil }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                        .font(.title3)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .navigationTitle("Coffee Trail")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatIDR(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "Rp \(Int(price))"
    }
}
