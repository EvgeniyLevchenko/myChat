//
//  LoginViewController.swift
//  myChat
//
//  Created by QwertY on 18.08.2022.
//

import UIKit

class LoginViewController: UIViewController {
    
    private let welcomeLabel = UILabel(text: "Welcome back!", font: .avenir26())
    private let loginWithLabel = UILabel(text: "Login with")
    private let orLabel = UILabel(text: "Or")
    private let emailLabel = UILabel(text: "Email")
    private let passwordLabel = UILabel(text: "Password")
    private let needAnAccountLabel = UILabel(text: "Need an account?")
    private let emailTextField = OneLineTextField(font: .avenir20())
    private let passwordTextField = OneLineTextField(font: .avenir20())
    private let googleButton = UIButton(title: "Google",
                                        titleColor: .black,
                                        backgroundColor: .white,
                                        isShadow: true)
    private let loginButton = UIButton(title: "Login",
                                       titleColor: .white,
                                       backgroundColor: .buttonDark())
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.buttonRed(), for: .normal)
        button.titleLabel?.font = .avenir20()
        return button
    }()
    
    weak var delegate: AuthNavigationDelegate?
    
    private var viewModel: LoginViewModelType?
    
    init(delegate: AuthNavigationDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = LoginViewModel()
        
        googleButton.customizeGoogleButton()
        view.backgroundColor = .white
        setupConstraints()
        
        googleButton.addTarget(self, action: #selector(googleButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
    }
    
    @objc private func googleButtonTapped() {
        viewModel?.googleLogin(presentingVC: self) { result in
            switch result {
            case .success(_):
                if let mainTabBarVC = self.viewModel?.mainTabBarVC {
                    self.showAlert(with: "Success!", message: "You've signed in") {
                        mainTabBarVC.modalPresentationStyle = .fullScreen
                        self.present(mainTabBarVC, animated: true)
                    }
                }
                
                if let setupProfileVC = self.viewModel?.setupProfileVC {
                    self.showAlert(with: "Success!", message: "You've signed up") {
                        self.present(setupProfileVC, animated: true)
                    }
                }
            case .failure(let error):
                self.showAlert(with: "An error occured!", message: error.localizedDescription)
            }
        }
    }
    
    @objc private func loginButtonTapped() {
        viewModel?.login(email: emailTextField.text, password: passwordTextField.text) { result in
            switch result {
            case .success(_):
                if let mainTabBarVC = self.viewModel?.mainTabBarVC {
                    self.showAlert(with: "Success!", message: "You've signed in") {
                        mainTabBarVC.modalPresentationStyle = .fullScreen
                        self.present(mainTabBarVC, animated: true)
                    }
                }
                
                if let setupProfileVC = self.viewModel?.setupProfileVC {
                    self.showAlert(with: "Success!", message: "You've signed up") {
                        self.present(setupProfileVC, animated: true)
                    }
                }
            case .failure(let error):
                self.showAlert(with: "An error occured!", message: error.localizedDescription)
            }
        }
    }
    
    @objc private func signUpButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.toSignUpVC()
        }
    }
}

// MARK: - Setup Constraints
extension LoginViewController {
    private func setupConstraints() {
        let loginWithView = ButtonFormView(label: loginWithLabel, button: googleButton)
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField],
                                         axis: .vertical,
                                         spacing: 0)
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField],
                                            axis: .vertical,
                                            spacing: 0)
        
        loginButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let stackView = UIStackView(arrangedSubviews: [
            loginWithView,
            orLabel,
            emailStackView,
            passwordStackView,
            loginButton
        ],
                                    axis: .vertical,
                                    spacing: 40)
        
        signUpButton.contentHorizontalAlignment = .leading
        let bottomStackView = UIStackView(arrangedSubviews: [needAnAccountLabel, signUpButton],
                                          axis: .horizontal,
                                          spacing: 10)
        bottomStackView.alignment = .firstBaseline
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(welcomeLabel)
        view.addSubview(stackView)
        view.addSubview(bottomStackView)
        
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 110),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 90),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            bottomStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}
