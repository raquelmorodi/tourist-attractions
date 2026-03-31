//
//  DetailFavoritesViewLoginModel.swift
//  TouristAttractions
//
//  Created by Raquel Morodi on 2026/03/10.
//

import Foundation

class DetailViewModel {

    // MARK: - State
    private(set) var place: Place

    // MARK: - Outputs
    var onFavoriteToggled: ((Bool) -> Void)?
    var onWeatherLoaded: (() -> Void)?

    // MARK: - Weather
    var weatherText: String?

    init(place: Place) {
        self.place = place
    }

    // MARK: - Computed
    var isFavorite: Bool { FavoritesService.shared.isFavorite(place) }
    var favoriteIconName: String { isFavorite ? "heart.fill" : "heart" }
    var name: String { place.name }
    var address: String { place.address }
    var ratingText: String { place.ratingDisplay }

    var descriptionText: String {
        let n = place.name.lowercased()
        if n.contains("kruger") {
            return "Kruger National Park is one of Africa's largest game reserves. Its high density of wild animals includes the Big 5: lions, leopards, rhinos, elephants and buffalos."
        } else if n.contains("blyde") {
            return "The Blyde River Canyon is a significant natural feature of South Africa, located in Mpumalanga. It is one of the largest canyons on Earth and the largest 'green canyon'."
        } else if n.contains("bourke") {
            return "Bourke's Luck Potholes are natural geological formations formed by centuries of swirling water where the Treur River meets the Blyde River."
        } else if n.contains("god") {
            return "God's Window provides a magnificent panoramic view over the Lowveld, dropping steeply down by more than 700 meters."
        } else if n.contains("gorge") {
            return "The Graskop Gorge Lift drops you 51 meters into a lush Afromontane forest below."
        } else if n.contains("sudwala") {
            return "The Sudwala Caves are the oldest known caves in the world, formed about 240 million years ago, featuring stunning dolomite formations."
        } else if n.contains("three") {
            return "The Three Rondavels are three round mountain tops with slightly pointed peaks, widely resembling traditional African beehive huts."
        } else {
            return "A highly recommended tourist attraction offering unique experiences and beautiful sights."
        }
    }

    var activitiesText: String {
        let n = place.name.lowercased()
        if n.contains("kruger") {
            return "• Guided Safari Drives\n• Bird Watching\n• Wildlife Photography\n• Bush Walks"
        } else if n.contains("blyde") {
            return "• Scenic Boat Cruises\n• Hiking Trails\n• Photography\n• Nature Walks"
        } else if n.contains("bourke") {
            return "• Viewing the Potholes\n• Light Hiking\n• Picnic spots\n• Geological Tours"
        } else if n.contains("god") {
            return "• Scenic Viewing\n• Rainforest Walk\n• Souvenir Shopping\n• Photography"
        } else if n.contains("gorge") {
            return "• Gorge Lift Experience\n• Forest Walk\n• Ziplining\n• Big Swing"
        } else if n.contains("sudwala") {
            return "• Guided Cave Tours\n• Crystal Room Visit\n• Butterfly Effect Park\n• Dinosaur Park"
        } else if n.contains("three") {
            return "• Panoramic Viewing\n• Nature Trails\n• Photography"
        } else {
            return "• Sightseeing\n• Guided Tours\n• Photography\n• Local Dining"
        }
    }

    var photoURL: URL? {
        guard let ref = place.photoReference else { return nil }
        return PlacesAPIService.shared.photoURL(reference: ref, maxWidth: 800)
    }

    // MARK: - Actions
    func toggleFavorite() {
        let newState = FavoritesService.shared.toggle(place)
        onFavoriteToggled?(newState)
    }

    func loadWeather() {
        WeatherAPIService.shared.fetchWeather(lat: place.latitude, lon: place.longitude) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let text):
                    self?.weatherText = text
                case .failure:
                    self?.weatherText = "Weather data unavailable"
                }
                self?.onWeatherLoaded?()
            }
        }
    }
}


// ============================================================
// FavoritesViewModel.swift
// TravelLandmarks › ViewModels
// ============================================================

class FavoritesViewModel {

    // MARK: - Outputs
    var onDataUpdated: (() -> Void)?

    // MARK: - State
    private(set) var favorites: [Place] = []
    var isEmpty: Bool { favorites.isEmpty }
    var count: Int { favorites.count }

    // MARK: - Actions
    func loadFavorites() {
        favorites = FavoritesService.shared.getAll()
        onDataUpdated?()
    }

    func place(at index: Int) -> Place { favorites[index] }

    func removeFavorite(at index: Int) {
        let place = favorites[index]
        FavoritesService.shared.remove(place)
        favorites.remove(at: index)
        onDataUpdated?()
    }
}


// ============================================================
// LoginViewModel.swift
// TravelLandmarks › ViewModels
// ============================================================

struct User {
    let email: String
    let displayName: String
}

class LoginViewModel {

    // outputs
    var onLoginSuccess: ((User) -> Void)?
    var onLoginError: ((String) -> Void)?
    var onLogout: (() -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?

    //State
    private(set) var currentUser: User?
    var isLoggedIn: Bool { currentUser != nil }

    //Validation
    func validate(email: String, password: String) -> String? {
        if email.trimmingCharacters(in: .whitespaces).isEmpty { return "Please enter your email." }
        if !email.contains("@") || !email.contains(".") { return "Enter a valid email address." }
        if password.isEmpty { return "Please enter your password." }
        if password.count < 6 { return "Password must be at least 6 characters." }
        return nil // nil = valid
    }

    //Actions
    func login(email: String, password: String) {
        if let errorMsg = validate(email: email, password: password) {
            onLoginError?(errorMsg)
            return
        }
        onLoadingChanged?(true)

    
        // Auth.auth().signIn(withEmail: email, password: password)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.onLoadingChanged?(false)
            let user = User(
                email: email,
                displayName: email.components(separatedBy: "@").first?.capitalized ?? "Traveller"
            )
            self?.currentUser = user
            UserDefaults.standard.set(email, forKey: "loggedInUserEmail")
            self?.onLoginSuccess?(user)
        }
    }

    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "loggedInUserEmail")
        onLogout?()
    }

    func restoreSession() -> User? {
        guard let email = UserDefaults.standard.string(forKey: "loggedInUserEmail") else { return nil }
        let user = User(email: email, displayName: email.components(separatedBy: "@").first?.capitalized ?? "Traveller")
        currentUser = user
        return user
    }
}
