//
//  PlaceCell.swift
//  TouristAttractions
//
//  Created by Raquel Morodi on 2026/03/10.
//

import UIKit

class PlaceCell: UITableViewCell {

    // MARK: - Outlets (connect in Storyboard)
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var favoriteIcon: UIImageView!

    // Track active download so we can cancel on reuse
    private var imageTask: URLSessionDataTask?

    //Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        styleCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Cancel any in-flight image download before reuse
        imageTask?.cancel()
        placeImageView.image = UIImage(systemName: "photo")
    }

    //Configuration
    /// Call this from cellForRowAt with the Place to display
    func configure(with place: Place) {
        nameLabel.text = place.name
        addressLabel.text = place.address
        ratingLabel.text = place.ratingDisplay
        favoriteIcon.isHidden = !FavoritesService.shared.isFavorite(place)

        // 1. Check for local asset match
        let lowerName = place.name.lowercased().replacingOccurrences(of: "'", with: "")
        let imageMap: [String: String] = [
            "blyde river": "blyde river canyon",
            "bourkes luck": "bourkes luck potholes",
            "gods window": "gods window",
            "gorge lift": "gorge lift co",
            "kruger": "kruger national park",
            "sudwala": "sudwala caves",
            "three rondavels": "three rondavels"
        ]
        
        if let key = imageMap.keys.first(where: { lowerName.contains($0) }),
           let assetName = imageMap[key] {
            placeImageView.image = UIImage(named: assetName)
        } else if let ref = place.photoReference,
           let url = PlacesAPIService.shared.photoURL(reference: ref, maxWidth: 200) {
            // 2. Fallback to API photo
            imageTask = ImageLoader.shared.load(url: url, into: placeImageView)
        } else {
            // 3. Fallback placeholder
            placeImageView.image = UIImage(systemName: "mappin.circle.fill")
            placeImageView.tintColor = .systemBlue
        }
        
        // Fetch weather and append to rating label
        let currentPlaceName = place.name
        WeatherAPIService.shared.fetchWeather(lat: place.latitude, lon: place.longitude) { [weak self] result in
            DispatchQueue.main.async {
                // Ensure the cell hasn't been reused for another place
                guard let self = self, self.nameLabel.text == currentPlaceName else { return }
                if case .success(let weatherString) = result {
                    // Remove the "Weather: " prefix for a cleaner look in the list
                    let cleanWeather = weatherString.replacingOccurrences(of: "Weather: ", with: "")
                    self.ratingLabel.text = "\(place.ratingDisplay)  •  \(cleanWeather)"
                }
            }
        }
    }

    // MARK: - Styling
    private func styleCell() {
        selectionStyle = .none

        // Image
        placeImageView.layer.cornerRadius = 10
        placeImageView.clipsToBounds = true
        placeImageView.contentMode = .scaleAspectFill
        placeImageView.backgroundColor = .secondarySystemBackground

        // Name
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 1

        // Address
        addressLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        addressLabel.textColor = .secondaryLabel
        addressLabel.numberOfLines = 1

        // Rating
        ratingLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        ratingLabel.textColor = .secondaryLabel

        // Favorite icon
        favoriteIcon.image = UIImage(systemName: "heart.fill")
        favoriteIcon.tintColor = .systemRed
    }
}

