//
//  PlacesListViewModel.swift
//  TouristAttractions
//
//  Created by Raquel Morodi on 2026/03/10.
//

import Foundation

class PlacesListViewModel {

    // MARK: - Outputs → ViewController observes these closures
    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    
    // MARK: - State
    private(set) var allPlaces: [Place] = []

    /// Mirrors Apple's "Show Favorites Only" toggle from the tutorial
    var showFavoritesOnly: Bool = false {
        didSet { onDataUpdated?() }
    }

    /// The list the ViewController actually renders
    var displayedPlaces: [Place] {
        showFavoritesOnly
            ? allPlaces.filter { FavoritesService.shared.isFavorite($0) }
            : allPlaces
    }
    // MARK: - Actions
    func fetchPlaces(query: String = "tourist attractions Mpumalanga") {
        onLoadingChanged?(true)
        PlacesAPIService.shared.searchPlaces(query: query) { [weak self] result in
            self?.onLoadingChanged?(false)
            switch result {
            case .success(let places):
                self?.allPlaces = places
                self?.onDataUpdated?()
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }

    func place(at index: Int) -> Place {
        displayedPlaces[index]
    }

    var count: Int { displayedPlaces.count }
}
