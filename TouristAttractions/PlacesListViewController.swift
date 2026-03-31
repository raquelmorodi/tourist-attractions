//
//  PlacesListViewController.swift
//  TouristAttractions
//
//  Created by Raquel Morodi on 2026/03/10.
//

import UIKit

class PlacesListViewController: UIViewController {

    //Outlets
    @IBOutlet weak var tableView: UITableView!


    //ViewModel
    private let viewModel = PlacesListViewModel()

    //Search
    private let searchController = UISearchController(searchResultsController: nil)

    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()

        setupSearchController()
        setupTableView()
        setupBindings()
        viewModel.fetchPlaces(query: "tourist attractions Mpumalanga")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh heart icons when coming back from Detail
        tableView.reloadData()
    }

    //Setup
    private func setupNavigation() {
        title = "Explore"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search places..."
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 88
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        // Register the nib/class (if not using Storyboard prototype cell, uncomment):
        // tableView.register(PlaceCell.self, forCellReuseIdentifier: "PlaceCell")
        setupFeaturedHeader()
    }

    private func setupFeaturedHeader() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 320))
        
        let titleLabel = UILabel()
        titleLabel.text = "Featured"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        let images = [
            "kruger national park",
            "blyde river canyon",
            "bourkes luck potholes",
            "gods window",
            "gorge lift co",
            "sudwala caves",
            "three rondavels"
        ]
        
        for (index, imageName) in images.enumerated() {
            let itemStack = UIStackView()
            itemStack.axis = .vertical
            itemStack.spacing = 8
            itemStack.alignment = .fill
            itemStack.translatesAutoresizingMaskIntoConstraints = false

            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 12
            imageView.layer.masksToBounds = true
            
            let nameLabel = UILabel()
            nameLabel.text = imageName.capitalized
            nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
            nameLabel.textAlignment = .center
            nameLabel.numberOfLines = 2
            
            imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
            imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            
            nameLabel.setContentHuggingPriority(.required, for: .vertical)
            nameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            
            itemStack.addArrangedSubview(imageView)
            itemStack.addArrangedSubview(nameLabel)
            
            switch index {
            case 0:
                itemStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapKruger)))
            case 1:
                itemStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBlyde)))
            case 2:
                itemStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBourkes)))
            case 3:
                itemStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapGodsWindow)))
            case 4:
                itemStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapGorgeLift)))
            case 5:
                itemStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapSudwala)))
            case 6:
                itemStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapThreeRondavels)))
            default:
                break
            }
            itemStack.isUserInteractionEnabled = true
            
            stackView.addArrangedSubview(itemStack)
            
            // Each image takes up exactly half the screen width minus padding/spacing (48 total horizontal padding for 2 items)
            itemStack.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.5, constant: -24).isActive = true
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
        
        tableView.tableHeaderView = headerView
    }

    @objc private func didTapKruger() {
        let kruger = Place(id: "kruger_featured", name: "Kruger National Park", address: "Mpumalanga, South Africa", rating: 4.8, latitude: -23.9881, longitude: 31.5526, photoReference: nil, category: "National Park")
        pushDetail(with: kruger)
    }

    @objc private func didTapBlyde() {
        let blyde = Place(id: "blyde_featured", name: "Blyde River Canyon", address: "Mpumalanga, South Africa", rating: 4.9, latitude: -24.5619, longitude: 30.8035, photoReference: nil, category: "Nature Reserve")
        pushDetail(with: blyde)
    }

    @objc private func didTapBourkes() {
        let place = Place(id: "bourkes_featured", name: "Bourke's Luck Potholes", address: "Mpumalanga, South Africa", rating: 4.7, latitude: -24.6740, longitude: 30.8116, photoReference: nil, category: "Nature Reserve")
        pushDetail(with: place)
    }

    @objc private func didTapGodsWindow() {
        let place = Place(id: "gods_window_featured", name: "God's Window", address: "Mpumalanga, South Africa", rating: 4.6, latitude: -24.8770, longitude: 30.8876, photoReference: nil, category: "Viewpoint")
        pushDetail(with: place)
    }

    @objc private func didTapGorgeLift() {
        let place = Place(id: "gorge_lift_featured", name: "Graskop Gorge Lift Co", address: "Mpumalanga, South Africa", rating: 4.8, latitude: -24.9351, longitude: 30.8443, photoReference: nil, category: "Attraction")
        pushDetail(with: place)
    }

    @objc private func didTapSudwala() {
        let place = Place(id: "sudwala_featured", name: "Sudwala Caves", address: "Mpumalanga, South Africa", rating: 4.5, latitude: -25.3712, longitude: 30.7001, photoReference: nil, category: "Cave")
        pushDetail(with: place)
    }

    @objc private func didTapThreeRondavels() {
        let place = Place(id: "three_rondavels_featured", name: "Three Rondavels", address: "Mpumalanga, South Africa", rating: 4.9, latitude: -24.5739, longitude: 30.8066, photoReference: nil, category: "Nature Reserve")
        pushDetail(with: place)
    }


    // MARK: - Bindings (ViewModel → ViewController)
    private func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            self?.tableView.reloadData()
        }

        viewModel.onError = { [weak self] message in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
                self?.viewModel.fetchPlaces()
            })
            self?.present(alert, animated: true)
        }
    }

}

// MARK: - UITableViewDataSource & Delegate
extension PlacesListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as? PlaceCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel.place(at: indexPath.row))
        return cell
    }

    /// Tap a row → push DetailViewController (mirrors NavigationLink in tutorial)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = viewModel.place(at: indexPath.row)
        pushDetail(with: place)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 88 }
}

//UISearchResultsUpdating & UISearchBarDelegate
extension PlacesListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            viewModel.fetchPlaces(query: "tourist attractions Mpumalanga")
            return
        }
        viewModel.fetchPlaces(query: query)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        
        // Go back to the explore root if we are detailing
        navigationController?.popToRootViewController(animated: false)
        searchController.isActive = false
        
        // Switch to Map tab
        guard let tabBar = tabBarController,
              let mapNav = tabBar.viewControllers?[1] as? UINavigationController,
              let mapVC = mapNav.viewControllers.first as? MapViewController else { return }
        
        tabBar.selectedIndex = 1
        mapVC.loadPlaces(for: query)
    }
}

//Navigation Helper
extension PlacesListViewController {
    private func pushDetail(with place: Place) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        detailVC.configure(with: place)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
