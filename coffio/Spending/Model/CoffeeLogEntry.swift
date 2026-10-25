//
//  CoffeeLogEntry.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/10/26.
//

import CoreLocation
import UIKit

struct CoffeeLogEntry: Identifiable {
    let id: UUID
    let date: Date
    let coffeeName: String
    let price: Double
    let imageUrl: String
    let latitude: Double?
    let longitude: Double?

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    init(
        id: UUID = UUID(),
        date: Date,
        coffeeName: String,
        price: Double,
        imageUrl: String,
        latitude: Double?,
        longitude: Double?
    ) {
        self.id = id
        self.date = date
        self.coffeeName = coffeeName
        self.price = price
        self.imageUrl = imageUrl
        self.latitude = latitude
        self.longitude = longitude
    }
}
