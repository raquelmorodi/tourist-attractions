//
//  Place.swift
//  TouristAttractions
//
//  Created by Raquel Morodi on 2026/03/09.
//

import Foundation
import CoreLocation

struct Place: Codable, Identifiable, Equatable {

    // Properties (match Google Places API JSON keys)
    let id: String              // Google's unique placeID
    let name: String            // Display name
    let address: String         // Formatted address
    let rating: Double          // 0.0 – 5.0
    let latitude: Double
    let longitude: Double
    let photoReference: String? // Used to build photo URL
    let category: String?       // e.g. "restaurant", "museum"

    //Computed Helpers
    /// Ready-to-use CLLocationCoordinate2D for MapKit
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Star string for display (e.g. "⭐ 4.5")
    var ratingDisplay: String {
        rating > 0 ? "⭐ \(rating)" : "No rating"
    }

    // Equatable
    static func == (lhs: Place, rhs: Place) -> Bool {
        lhs.id == rhs.id
    }
}
