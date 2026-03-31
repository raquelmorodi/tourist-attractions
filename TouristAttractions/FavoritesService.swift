//
//  FavoritesService.swift
//  TouristAttractions
//
//  Created by Raquel Morodi on 2026/03/10.
//

import Foundation

class FavoritesService {

    // MARK: - Singleton
    static let shared = FavoritesService()
    private init() {}

    private let storageKey = "savedFavoritePlaces"

    // MARK: - Read
    func getAll() -> [Place] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let places = try? JSONDecoder().decode([Place].self, from: data)
        else { return [] }
        return places
    }

    func isFavorite(_ place: Place) -> Bool {
        getAll().contains(where: { $0.id == place.id })
    }

    /// Toggles a place in/out of favorites. Returns new favorite state.
    @discardableResult
    func toggle(_ place: Place) -> Bool {
        var saved = getAll()
        if let index = saved.firstIndex(where: { $0.id == place.id }) {
            saved.remove(at: index)
            persist(saved)
            return false   // removed
        } else {
            saved.append(place)
            persist(saved)
            return true    // added
        }
    }

    func remove(_ place: Place) {
        var saved = getAll()
        saved.removeAll { $0.id == place.id }
        persist(saved)
    }

    // MARK: - Private
    private func persist(_ places: [Place]) {
        if let data = try? JSONEncoder().encode(places) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

