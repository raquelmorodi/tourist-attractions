//
//  PlacesAPIService.swift
//  TouristAttractions
//
//  Created by Raquel Morodi on 2026/03/10.
//

import Foundation

class PlacesAPIService {

    static let shared = PlacesAPIService()
    private init() {}

    // Add your API key here
    private let apiKey = "YOUR_API_KEY_HERE"
    private let baseURL = "https://maps.googleapis.com/maps/api/place"

    // MARK: - Mock Data Fallback
    private let mockPlaces: [Place] = [
        Place(id: "1", name: "Blyde River Canyon", address: "Mpumalanga, South Africa", rating: 4.8, latitude: -24.5714, longitude: 30.8122, photoReference: nil, category: "attraction"),
        Place(id: "2", name: "Bourke's Luck Potholes", address: "Blyde River Canyon Nature Reserve", rating: 4.7, latitude: -24.6738, longitude: 30.8129, photoReference: nil, category: "nature"),
        Place(id: "3", name: "God's Window", address: "Panorama Route, Mpumalanga", rating: 4.6, latitude: -24.8778, longitude: 30.8879, photoReference: nil, category: "viewpoint"),
        Place(id: "4", name: "Graskop Gorge Lift", address: "R533, Graskop, 1270", rating: 4.5, latitude: -24.9455, longitude: 30.8415, photoReference: nil, category: "activity"),
        Place(id: "5", name: "Kruger National Park", address: "Mpumalanga & Limpopo", rating: 4.9, latitude: -23.9884, longitude: 31.5547, photoReference: nil, category: "park"),
        Place(id: "6", name: "Sudwala Caves", address: "R539, Nelspruit, 1200", rating: 4.4, latitude: -25.3697, longitude: 30.7011, photoReference: nil, category: "cave"),
        Place(id: "7", name: "Three Rondavels", address: "Blyde River Canyon, Mpumalanga", rating: 4.8, latitude: -24.5619, longitude: 30.8066, photoReference: nil, category: "viewpoint")
    ]

    //Search Places
    func searchPlaces(query: String, completion: @escaping (Result<[Place], Error>) -> Void) {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanQuery.isEmpty else {
            DispatchQueue.main.async { completion(.success([])) }
            return
        }

        guard let encoded = cleanQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        // Only request the fields you actually use — saves quota
        let urlString = "\(baseURL)/textsearch/json?query=\(encoded)&fields=place_id,name,formatted_address,rating,photos,opening_hours,geometry&key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(APIError.noData)) }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(PlacesResponse.self, from: data)
                let places = decoded.results.map { result in
                    Place(
                        id: result.place_id,
                        name: result.name,
                        address: result.formatted_address ?? "Address unavailable",
                        rating: result.rating ?? 0.0,
                        latitude: result.geometry.location.lat,
                        longitude: result.geometry.location.lng,
                        photoReference: result.photos?.first?.photo_reference,
                        category: "Point of Interest" // Or map according to your logic
                    )
                }
                
                DispatchQueue.main.async {
                    if places.isEmpty {
                        completion(.success(self.mockPlaces))
                    } else {
                        completion(.success(places))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("Decoding error: \(error)")
                    // Fallback to mock data on decode errors (or missing API Key)
                    completion(.success(self.mockPlaces))
                }
            }
        }.resume()
    }

    // MARK: - Photo URL Builder
    func photoURL(reference: String, maxWidth: Int = 400) -> URL? {
        let urlString = "\(baseURL)/photo?maxwidth=\(maxWidth)&photoreference=\(reference)&key=\(apiKey)"
        return URL(string: urlString)
    }

    // MARK: - Errors
    enum APIError: LocalizedError {
        case noData
        case invalidURL

        var errorDescription: String? {
            switch self {
            case .noData: return "No data was returned from the server."
            case .invalidURL: return "The URL provided was invalid."
            }
        }
    }
}

// MARK: - Decoding Models
struct PlacesResponse: Decodable {
    let results: [GooglePlaceResult]
}

struct GooglePlaceResult: Decodable {
    let place_id: String
    let name: String
    let formatted_address: String?
    let rating: Double?
    let geometry: Geometry
    let photos: [GooglePhoto]?

    struct Geometry: Decodable {
        let location: Location
    }
    
    struct Location: Decodable {
        let lat: Double
        let lng: Double
    }
    
    struct GooglePhoto: Decodable {
        let photo_reference: String
    }
}

