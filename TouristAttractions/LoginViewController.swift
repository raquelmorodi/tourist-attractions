//
//  LoginViewController.swift
//  TouristAttractions
//
//  Created by Raquel Morodi on 2026/03/10.
//

import UIKit

class LoginViewController: UIViewController {

    //Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var forgotPasswordButton: UIButton!

    //ViewModel
    private let viewModel = LoginViewModel()

    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupKeyboard()
        checkExistingSession()
    }

    //UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Profile"

        logoImageView.image = UIImage(systemName: "airplane.circle.fill")
        logoImageView.tintColor = .systemBlue
        logoImageView.contentMode = .scaleAspectFit

        titleLabel.text = "Welcome Back"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)

        subtitleLabel.text = "Sign in to explore Mpumalanga"
        subtitleLabel.font = UIFont.systemFont(ofSize: 15)
        subtitleLabel.textColor = .secondaryLabel

        styleTextField(emailTextField,    placeholder: "Email address", icon: "envelope")
        styleTextField(passwordTextField, placeholder: "Password",      icon: "lock")
        passwordTextField.isSecureTextEntry = true
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.returnKeyType = .next
        passwordTextField.returnKeyType = .done

        loginButton.setTitle("Sign In", for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        loginButton.layer.cornerRadius = 14

        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
    }

    private func styleTextField(_ tf: UITextField, placeholder: String, icon: String) {
        tf.placeholder = placeholder
        tf.borderStyle = .none
        tf.backgroundColor = .secondarySystemBackground
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.separator.cgColor
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.keyboardType = icon == "envelope" ? .emailAddress : .default
        tf.autocapitalizationType = .none

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 52))
        let img = UIImageView(image: UIImage(systemName: icon))
        img.frame = CGRect(x: 12, y: 16, width: 20, height: 20)
        img.tintColor = .tertiaryLabel
        img.contentMode = .scaleAspectFit
        container.addSubview(img)
        tf.leftView = container
        tf.leftViewMode = .always
    }

    //Bindings
    private func setupBindings() {
        viewModel.onLoginSuccess = { [weak self] user in
            self?.navigateToProfile(user: user)
        }
        viewModel.onLoginError = { [weak self] message in
            self?.shakeAndAlert(message: message)
        }
        viewModel.onLoadingChanged = { [weak self] isLoading in
            if isLoading {
                self?.activityIndicator.startAnimating()
                self?.loginButton.setTitle("", for: .normal)
                self?.loginButton.isEnabled = false
                self?.loginButton.alpha = 0.7
            } else {
                self?.activityIndicator.stopAnimating()
                self?.loginButton.setTitle("Sign In", for: .normal)
                self?.loginButton.isEnabled = true
                self?.loginButton.alpha = 1
            }
        }
    }

    //Session Check
    private func checkExistingSession() {
        if let user = viewModel.restoreSession() {
            navigateToProfile(user: user)
        }
    }

    //Actions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        viewModel.login(
            email: emailTextField.text ?? "",
            password: passwordTextField.text ?? ""
        )
    }

    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Reset Password",
                                      message: "Enter your email and we'll send a link.",
                                      preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Email"; $0.keyboardType = .emailAddress }
        alert.addAction(UIAlertAction(title: "Send", style: .default))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    //Navigation
    private func navigateToProfile(user: User) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else { return }
        profileVC.configure(with: user, viewModel: viewModel)
        navigationController?.setViewControllers([profileVC], animated: true)
    }

    //Error UI
    private func shakeAndAlert(message: String) {
        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.values = [-10, 10, -8, 8, -4, 4, 0]
        shake.duration = 0.4
        loginButton.layer.add(shake, forKey: "shake")

        let alert = UIAlertController(title: "Sign In Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    //Keyboard
    private func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc private func keyboardWillShow(_ n: Notification) {
        guard let frame = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = frame.height + 20
    }
    @objc private func keyboardWillHide() { scrollView.contentInset.bottom = 0 }
    @objc private func dismissKeyboard() { view.endEditing(true) }
}

//UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField { passwordTextField.becomeFirstResponder() }
        else { textField.resignFirstResponder(); loginButtonTapped(loginButton) }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = UIColor.systemBlue.cgColor
            textField.layer.borderWidth = 1.5
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderColor = UIColor.separator.cgColor
            textField.layer.borderWidth = 1
        }
    }
}



class ProfileViewController: UIViewController {

    //Outlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tripsCountLabel: UILabel!
    @IBOutlet weak var favoritesCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    //Preferences UI
    private let travelDatePicker = UIDatePicker()
    private let seasonSegmentedControl = UISegmentedControl(items: ["Summer", "Autumn", "Winter", "Spring"])

    //Properties
    private var user: User?
    private var viewModel: LoginViewModel?

    private let menuItems: [(icon: String, title: String)] = [
        ("heart.fill",         "My Favourite Places"),
        ("map.fill",           "My Trips"),
        ("bell.fill",          "Notifications"),
        ("lock.fill",          "Privacy & Security"),
        ("questionmark.circle","Help & Support")
    ]

    //Configuration
    func configure(with user: User, viewModel: LoginViewModel) {
        self.user   = user
        self.viewModel = viewModel
    }

    //Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        populateUser()
    }

    private func setupUI() {
        title = "My Profile"
        view.backgroundColor = .systemGroupedBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Sign Out", style: .plain,
            target: self, action: #selector(signOutTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemRed

        avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        avatarImageView.tintColor = .systemBlue
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.clipsToBounds = true

        tableView.delegate   = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenuCell")
        tableView.backgroundColor = .clear

        setupPreferencesHeader()
    }

    private func setupPreferencesHeader() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 145))
        
        let prefsStack = UIStackView()
        prefsStack.axis = .vertical
        prefsStack.spacing = 16
        prefsStack.translatesAutoresizingMaskIntoConstraints = false
        
        let dateStack = UIStackView()
        dateStack.axis = .horizontal
        dateStack.spacing = 10
        dateStack.alignment = .center
        
        let dateLabel = UILabel()
        dateLabel.text = "Planned Travel Date"
        dateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        travelDatePicker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            travelDatePicker.preferredDatePickerStyle = .compact
        }
        travelDatePicker.tintColor = .systemBlue
        
        dateStack.addArrangedSubview(dateLabel)
        dateStack.addArrangedSubview(UIView())
        dateStack.addArrangedSubview(travelDatePicker)
        
        let seasonStack = UIStackView()
        seasonStack.axis = .vertical
        seasonStack.spacing = 8
        
        let seasonLabel = UILabel()
        seasonLabel.text = "Preferred Season"
        seasonLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        seasonSegmentedControl.selectedSegmentIndex = 0
        seasonSegmentedControl.selectedSegmentTintColor = .systemBlue
        seasonSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        seasonSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
        
        seasonStack.addArrangedSubview(seasonLabel)
        seasonStack.addArrangedSubview(seasonSegmentedControl)
        
        prefsStack.addArrangedSubview(dateStack)
        prefsStack.addArrangedSubview(seasonStack)
        
        headerView.addSubview(prefsStack)
        
        NSLayoutConstraint.activate([
            prefsStack.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            prefsStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            prefsStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            prefsStack.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])
        
        tableView.tableHeaderView = headerView
    }

    private func populateUser() {
        nameLabel.text  = user?.displayName ?? "Traveller"
        emailLabel.text = user?.email ?? ""
        favoritesCountLabel.text = "\(FavoritesService.shared.getAll().count)"
        tripsCountLabel.text = "0"
    }

    private func setupBindings() {
        viewModel?.onLogout = { [weak self] in
            self?.navigateToLogin()
        }
    }

    @objc private func signOutTapped() {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            self?.viewModel?.logout()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func navigateToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        navigationController?.setViewControllers([loginVC], animated: true)
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { menuItems.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        cell = UITableViewCell(style: .default, reuseIdentifier: "MenuCell")
        var config = cell.defaultContentConfiguration()
        config.text = menuItems[indexPath.row].title
        config.image = UIImage(systemName: menuItems[indexPath.row].icon)
        config.imageProperties.tintColor = .systemBlue
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .secondarySystemGroupedBackground
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 54 }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = menuItems[indexPath.row].title
        if item == "My Trips" {
            let vc = TripsViewController()
            navigationController?.pushViewController(vc, animated: true)
        } else if item == "Notifications" {
            let vc = NotificationsViewController()
            navigationController?.pushViewController(vc, animated: true)
        } else if item == "My Favourite Places" {
            // Re-use logic for Favorites if available, or just go to fav tab:
            tabBarController?.selectedIndex = 2
        }
    }
}


// MARK: - Menu View Controllers

class TripsViewController: UITableViewController {
    let mockTrips = [
        ("Kruger National Safari", "Dec 10 - Dec 15, 2026"),
        ("Panorama Route Highlights", "Jan 5 - Jan 8, 2027"),
        ("Sudwala Caves Adventure", "Feb 14 - Feb 15, 2027")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Trips"
        view.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TripCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mockTrips.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TripCell")
        let trip = mockTrips[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        config.text = trip.0
        config.textProperties.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        config.secondaryText = trip.1
        config.secondaryTextProperties.color = .secondaryLabel
        
        config.image = UIImage(systemName: "map.fill")
        config.imageProperties.tintColor = .systemBlue
        
        cell.contentConfiguration = config
        cell.backgroundColor = .secondarySystemGroupedBackground
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}

class NotificationsViewController: UITableViewController {
    let mockNotifications = [
        ("Saved Place Update", "Blyde River Canyon has added new hiking trails.", "1h ago"),
        ("Upcoming Trip Reminder", "Your Kruger National Safari is coming up soon!", "1d ago"),
        ("New Feature", "You can now book tickets directly in the app.", "3d ago")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        view.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NotifCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mockNotifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "NotifCell")
        let notif = mockNotifications[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        config.text = notif.0
        config.textProperties.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        config.secondaryText = "\(notif.1)\n\n\(notif.2)"
        config.secondaryTextProperties.numberOfLines = 0
        config.secondaryTextProperties.color = .secondaryLabel
        
        config.image = UIImage(systemName: "bell.fill")
        config.imageProperties.tintColor = .systemBlue
        
        cell.contentConfiguration = config
        cell.backgroundColor = .secondarySystemGroupedBackground
        cell.selectionStyle = .none
        return cell
    }
}
