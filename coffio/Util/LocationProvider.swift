//
//  LocationProvider.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 10/04/26.
//

import CoreLocation
import Foundation

class LocationProvider: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    static let shared: LocationProvider = .init()
    
    // This will store the latest location found
    var currentLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 1. Request permission
        locationManager.requestWhenInUseAuthorization()
        
        // 2. Start looking for location
        locationManager.startUpdatingLocation()
    }

    // Delegate method: called when the phone receives a location update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard currentLocation == nil else {
            locationManager.stopUpdatingLocation()
            return
        }
        if let location = locations.last {
            self.currentLocation = location
            print("Current Lat: \(location.coordinate.latitude)")
            print("Current Lon: \(location.coordinate.longitude)")
        }
    }
    
    func calculateDistance(latitude: Double, longitude: Double) -> String? {
        guard let currentLocation else { return nil}
        // 1. Create a CLLocation object for the destination
        let destination = CLLocation(latitude: latitude, longitude: longitude)
        
        // 2. Calculate distance in meters
        let distanceInMeters = currentLocation.distance(from: destination)
        
        // 3. Convert to Kilometers
        let distanceInKm = distanceInMeters / 1000
        
        // 4. Format the string to look like "2,5 km"
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.decimalSeparator = "," // Force comma if specifically required
        
        let formattedDistance = formatter.string(from: NSNumber(value: distanceInKm)) ?? "0"
        
        return "\(formattedDistance) km"
    }

    // Handle errors (e.g., user denied permission)
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
