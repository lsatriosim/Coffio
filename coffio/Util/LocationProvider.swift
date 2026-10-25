//
//  LocationProvider.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 10/04/26.
//

import CoreLocation
import Foundation

@MainActor
final class LocationProvider: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    static let shared = LocationProvider()
    
    // Published property so SwiftUI views re-render when location updates
    @Published var currentLocation: CLLocation?
    
    // Published authorization status flag for UI empty states
    @Published var isLocationAuthorized: Bool = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check current initial status
        updateAuthorizationStatus(locationManager.authorizationStatus)
        
        // 1. Request permission
        locationManager.requestWhenInUseAuthorization()
        
        // 2. Start looking for location if already authorized
        if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    // Delegate method: called when authorization status changes
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.updateAuthorizationStatus(status)
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                manager.startUpdatingLocation()
            } else {
                manager.stopUpdatingLocation()
                self.currentLocation = nil
            }
        }
    }

    private func updateAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            self.isLocationAuthorized = true
        case .denied, .restricted, .notDetermined:
            self.isLocationAuthorized = false
        @unknown default:
            self.isLocationAuthorized = false
        }
    }

    // Delegate method: called when the phone receives a location update
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
         
        Task { @MainActor in
            // Stop updates once a valid location is found to save battery
            if self.currentLocation == nil {
                self.locationManager.stopUpdatingLocation()
            }
            self.currentLocation = location
            print("Current Lat: \(location.coordinate.latitude)")
            print("Current Lon: \(location.coordinate.longitude)")
        }
    }
    
    // Return distance and the formatted distance
    func calculateDistance(latitude: Double, longitude: Double) -> (Double, String)? {
        guard let currentLocation else { return nil }
         
        let destination = CLLocation(latitude: latitude, longitude: longitude)
        let distanceInMeters = currentLocation.distance(from: destination)
        let distanceInKm = distanceInMeters / 1000
         
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.decimalSeparator = ","
         
        let formattedDistance = formatter.string(from: NSNumber(value: distanceInKm)) ?? "0"
         
        return (distanceInKm, "\(formattedDistance) km")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
