//
//  ApplePlacesAutocompleteViewModel.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 26/10/26.
//

import Foundation
import MapKit
import Combine

class ApplePlacesAutocompleteViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchQuery: String = "" {
        didSet {
            completer.queryFragment = searchQuery
        }
    }
    @Published var searchResults: [MKLocalSearchCompletion] = []
    
    private let completer = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
        
        // Scope the search region to Indonesia
        let indonesiaCenter = CLLocationCoordinate2D(latitude: -0.7893, longitude: 113.9213)
        let indonesiaSpan = MKCoordinateSpan(latitudeDelta: 25.0, longitudeDelta: 40.0)
        completer.region = MKCoordinateRegion(center: indonesiaCenter, span: indonesiaSpan)
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error fetching Apple Maps suggestions: \(error.localizedDescription)")
    }
    
    func resolveCompletion(_ completion: MKLocalSearchCompletion, completionHandler: @escaping (String, String) -> Void) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let mapItem = response?.mapItems.first else {
                DispatchQueue.main.async {
                    completionHandler(completion.title, completion.subtitle)
                }
                return
            }
            
            let name = mapItem.name ?? completion.title
            let fullAddress = mapItem.placemark.title ?? completion.subtitle
            
            DispatchQueue.main.async {
                completionHandler(name, fullAddress)
            }
        }
    }
}
