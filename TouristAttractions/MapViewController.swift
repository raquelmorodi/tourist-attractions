//
//  MapViewController.swift
//  TouristAttractions
//
//  Created by Raquel Morodi on 2026/03/10.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapTypeControl: UISegmentedControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - ViewModel
    private let viewModel = MapViewModel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupMapView()
        setupBindings()
        loadPlaces()
    }

    // MARK: - Setup
    private func setupNavigation() {
        title = "Map"
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true       // Shows blue dot if location permission granted
        mapView.mapType = .standard
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
    }

    private func setupBindings() {
        viewModel.onPlacesLoaded = { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()

            // Add all pins
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(self.viewModel.makeAnnotations())

            // Zoom to show all pins natively
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
        viewModel.onError = { [weak self] message in
            self?.activityIndicator.stopAnimating()
            let alert = UIAlertController(title: "Map Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }

    private func loadPlaces() {
        loadPlaces(for: "tourist attractions Mpumalanga")
    }

    func loadPlaces(for query: String) {
        loadViewIfNeeded()
        activityIndicator.startAnimating()
        viewModel.loadPlaces(query: query)
    }

    //Actions
    /// Wire UISegmentedControl Value Changed to this
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: mapView.mapType = .standard
        case 1: mapView.mapType = .satellite
        case 2: mapView.mapType = .hybrid
        default: break
        }
    }
}

//MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {

    /// Style the annotation pins
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        let view = mapView.dequeueReusableAnnotationView(
            withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier,
            for: annotation
        ) as? MKMarkerAnnotationView

        view?.canShowCallout = true               // Shows name + rating on tap
        view?.markerTintColor = .systemBlue
        view?.glyphImage = UIImage(systemName: "mappin")

        // "Info" button inside the callout bubble
        let infoButton = UIButton(type: .detailDisclosure)
        view?.rightCalloutAccessoryView = infoButton

        return view
    }

    /// Tap the callout accessory → navigate to Detail
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation,
              let place = viewModel.place(for: annotation) else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(
            withIdentifier: "DetailViewController"
        ) as? DetailViewController else { return }

        detailVC.configure(with: place)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

