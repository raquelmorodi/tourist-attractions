//
//  DetailViewController.swift
//  TouristAttractions
//
//  Created by Raquel Morodi on 2026/03/10.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {

    //Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var miniMapView: MKMapView!
    @IBOutlet weak var favoriteButton: UIButton!

    //Dynamic Labels
    private let descriptionLabel = UILabel()
    private let activitiesHeaderLabel = UILabel()
    private let activitiesLabel = UILabel()
    private let weatherLabel = UILabel()

    //ViewModel
    private var viewModel: DetailViewModel!

    //Configuration (call BEFORE viewDidLoad)
    func configure(with place: Place) {
        viewModel = DetailViewModel(place: place)
    }

    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(viewModel != nil, "❌ Call configure(with:) before presenting DetailViewController")
        setupNavigation()
        setupStyles()
        populateStaticContent()
        setupBindings()
        loadPhoto()
        setupMiniMap()
    }

    //Setup
    private func setupNavigation() {
        navigationItem.largeTitleDisplayMode = .never
        title = ""  // Name is shown in the label below the photo

        // Favorite button in navigation bar (top right)
        let favBarButton = UIBarButtonItem(
            image: UIImage(systemName: viewModel.favoriteIconName),
            style: .plain,
            target: self,
            action: #selector(favoriteTapped)
        )
        favBarButton.tintColor = viewModel.isFavorite ? .systemRed : .systemGray
        navigationItem.rightBarButtonItem = favBarButton
    }

    private func setupStyles() {
        view.backgroundColor = .systemBackground

        placeImageView.contentMode = .scaleAspectFill
        placeImageView.clipsToBounds = true
        placeImageView.backgroundColor = .secondarySystemBackground

        nameLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        nameLabel.numberOfLines = 0

        categoryLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        categoryLabel.textColor = .systemBlue
        categoryLabel.textTransform()

        addressLabel.font = UIFont.systemFont(ofSize: 15)
        addressLabel.textColor = .secondaryLabel
        addressLabel.numberOfLines = 0

        ratingLabel.font = UIFont.systemFont(ofSize: 15)

        miniMapView.isUserInteractionEnabled = false   // Thumbnail — not interactive
        miniMapView.layer.cornerRadius = 12
        miniMapView.clipsToBounds = true

        // Inline favorite button (below map)
        favoriteButton.layer.cornerRadius = 14
        updateFavoriteButton()

        // Inject dynamic labels
        if let textStack = ratingLabel.superview as? UIStackView {
            textStack.setCustomSpacing(16, after: ratingLabel)

            weatherLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            weatherLabel.textColor = .systemBlue
            weatherLabel.numberOfLines = 0
            
            descriptionLabel.font = UIFont.systemFont(ofSize: 15)
            descriptionLabel.textColor = .label
            descriptionLabel.numberOfLines = 0

            activitiesHeaderLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            activitiesHeaderLabel.textColor = .label

            activitiesLabel.font = UIFont.systemFont(ofSize: 15)
            activitiesLabel.textColor = .secondaryLabel
            activitiesLabel.numberOfLines = 0

            textStack.addArrangedSubview(weatherLabel)
            textStack.setCustomSpacing(16, after: weatherLabel)
            textStack.addArrangedSubview(descriptionLabel)
            textStack.setCustomSpacing(16, after: descriptionLabel)
            textStack.addArrangedSubview(activitiesHeaderLabel)
            textStack.setCustomSpacing(4, after: activitiesHeaderLabel)
            textStack.addArrangedSubview(activitiesLabel)
            textStack.setCustomSpacing(16, after: activitiesLabel)
        }
    }

    private func populateStaticContent() {
        nameLabel.text = viewModel.name
        addressLabel.text = viewModel.address
        ratingLabel.text = viewModel.ratingText
        categoryLabel.text = viewModel.place.category?.replacingOccurrences(of: "_", with: " ").capitalized

        descriptionLabel.text = viewModel.descriptionText
        activitiesHeaderLabel.text = "Activities to Do"
        activitiesLabel.text = viewModel.activitiesText
    }

    //Bindings
    private func setupBindings() {
        viewModel.onFavoriteToggled = { [weak self] isFavorite in
            self?.updateFavoriteButton()
            self?.animateFavoriteButton()
        }
        
        viewModel.onWeatherLoaded = { [weak self] in
            guard let self = self, let weatherText = self.viewModel.weatherText else { return }
            self.weatherLabel.text = weatherText
        }
        
        // Fetch weather
        weatherLabel.text = "Loading weather..."
        viewModel.loadWeather()
    }

    //Photo Loading
    private func loadPhoto() {
        let lowerName = viewModel.name.lowercased().replacingOccurrences(of: "'", with: "")
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
        } else if let url = viewModel.photoURL {
            ImageLoader.shared.load(url: url, into: placeImageView,
                                    placeholder: UIImage(systemName: "photo.fill"))
        } else {
            placeImageView.image = UIImage(systemName: "mappin.circle.fill")
            placeImageView.tintColor = .systemBlue
        }
    }

    //Mini Map
    private func setupMiniMap() {
        let region = MKCoordinateRegion(
            center: viewModel.place.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        miniMapView.setRegion(region, animated: false)

        let pin = MKPointAnnotation()
        pin.coordinate = viewModel.place.coordinate
        pin.title = viewModel.name
        miniMapView.addAnnotation(pin)
    }

    // MARK: - Favorite Button UI
    private func updateFavoriteButton() {
        let icon = UIImage(systemName: viewModel.favoriteIconName)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        favoriteButton.setImage(icon, for: .normal)
        favoriteButton.tintColor = viewModel.isFavorite ? .systemRed : .systemGray
        favoriteButton.setTitle(viewModel.isFavorite ? "  Saved" : "  Save Place", for: .normal)
        favoriteButton.backgroundColor = viewModel.isFavorite
            ? UIColor.systemRed.withAlphaComponent(0.1)
            : UIColor.systemGray.withAlphaComponent(0.1)

        // Update nav bar button too
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: viewModel.favoriteIconName)
        navigationItem.rightBarButtonItem?.tintColor = viewModel.isFavorite ? .systemRed : .systemGray
    }

    private func animateFavoriteButton() {
        UIView.animate(withDuration: 0.15, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.favoriteButton.transform = .identity
            }
        }
    }

    //Actions
    @IBAction func favoriteTapped(_ sender: Any) {
        viewModel.toggleFavorite()
    }
}

//UILabel helper
private extension UILabel {
    func textTransform() { /* placeholder — category label styling */ }
}
