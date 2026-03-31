//
//  WeatherAPIService.swift
//  TouristAttractions
//

import Foundation

class WeatherAPIService {
    static let shared = WeatherAPIService()
    
    let apiKey = "e8270fcf65029deaf9c9e517c9f5e1da"
    
    private var cache: [String: String] = [:]
    
    private init() {}
    
    func fetchWeather(lat: Double, lon: Double, completion: @escaping (Result<String, Error>) -> Void) {
        let cacheKey = "\(lat),\(lon)"
        if let cached = cache[cacheKey] {
            completion(.success(cached))
            return
        }
        
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let weatherResponse = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
                let temp = weatherResponse.main.temp
                let description = weatherResponse.weather.first?.description.capitalized ?? "Clear"
                let weatherString = "Weather: \(Int(temp))°C, \(description)"
                self.cache[cacheKey] = weatherString
                completion(.success(weatherString))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

 
struct OpenWeatherResponse: Codable {
    let main: MainWeather
    let weather: [WeatherCondition]
}

struct MainWeather: Codable {
    let temp: Double
}

struct WeatherCondition: Codable {
    let description: String
}
