//
//  MapViewModel.swift
//  TouristAttractions
//
//  Created by Raquel Morodi on 2026/03/10.
//

import Foundation
import MapKit

class MapViewModel {

    // MARK: - Outputs
    var onPlacesLoaded: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?

    // MARK: - State
    private(set) var places: [Place] = []
    private(set) var isLoading: Bool = false {
        didSet {
            onLoadingStateChanged?(isLoading)
        }
    }

    // Actions
    func loadPlaces(query: String = "tourist attractions Mpumalanga") {
        isLoading = true
        PlacesAPIService.shared.searchPlaces(query: query) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let places):
                self?.places = places
                self?.onPlacesLoaded?()
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }

    /// Converts Place array to MKPointAnnotation array for MapKit
    func makeAnnotations() -> [PlaceAnnotation] {
        places.map { PlaceAnnotation(place: $0) }
    }

    /// Finds the Place that matches a tapped annotation
    func place(for annotation: MKAnnotation) -> Place? {
        guard let placeAnnotation = annotation as? PlaceAnnotation else { return nil }
        return placeAnnotation.place
    }

    /// Default map region centred on first result
    func defaultRegion() -> MKCoordinateRegion? {
        guard let first = places.first else { return nil }
        return MKCoordinateRegion(
            center: first.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    }
}


class PlaceAnnotation: NSObject, MKAnnotation {
    let place: Place
    var coordinate: CLLocationCoordinate2D { place.coordinate }
    var title: String? { place.name }
    var subtitle: String? { place.ratingDisplay }
    
    init(place: Place) { self.place = place }
    
}
