//
//  MapView.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 18/04/26.
//

import SwiftUI
import MapKit

struct CoffeeShopLocation: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
}

struct MultiPinMapView: View {
    let coffeeShop: [DiscoverCoffeeShopItemDataModel]
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(coffeeShop, id:\.id) { location in
                Marker(
                    location.name,
                    coordinate: CLLocationCoordinate2D(
                        latitude: CLLocationDegrees(location.latitude),
                        longitude: CLLocationDegrees(location.longitude)
                    )
                )
            }
        }
        .mapStyle(.standard)
        .onAppear {
            cameraPosition = .automatic
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
