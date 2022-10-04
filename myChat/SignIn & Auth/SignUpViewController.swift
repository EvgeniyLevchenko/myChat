//
//  SignUpViewController.swift
//  myChat
//
//  Created by QwertY on 12.08.2022.
//

import UIKit

class SignUpViewController: UIViewController {
    
    private let welcomeLabel = UILabel(text: "Good to see you!", font: .avenir26())
    private let emailLabel = UILabel(text: "Email")
    private let passwordLabel = UILabel(text: "Password")
    private let confirmPasswordLabel = UILabel(text: "Confirm password")
    private let alreadyOnboardLabel = UILabel(text: "Already onboard?")
    private let emailTextField = OneLineTextField(font: .avenir20())
    private let passwordTextField = OneLineTextField(font: .avenir20())
    private let confirmPasswordTextField = OneLineTextField(font: .avenir20())
    private let signUpButton = UIButton(title: "Sign up",
                                        titleColor: .white,
                                        backgroundColor: .buttonDark())
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.buttonRed(), for: .normal)
        button.titleLabel?.font = .avenir20()
        return button
    }()
    
    weak var delegate: AuthNavigationDelegate?
    
    private var viewModel: SignUpViewModelType?
    
    init(delegate: AuthNavigationDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SignUpViewModel()
        view.backgroundColor = .white
        setupConstraints()
        
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    @objc private func signUpButtonTapped() {
        viewModel?.register(email: emailTextField.text,
                            password: passwordTextField.text,
                            confirmPassword: confirmPasswordTextField.text) { [self] result in
            switch result {
            case .success(_):
                guard let setupProfileVC = self.viewModel?.setupProfileVC else { return }
                self.showAlert(with: "Success", message: "You've signed up") {
                    self.present(setupProfileVC, animated: true)
                }
            case .failure(let error):
                self.showAlert(with: "Error!", message: error.localizedDescription)
            }
        }
    }
    
    @objc private func loginButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.toLoginVC()
        }
    }
}

// MARK: - Setup constraints
extension SignUpViewController {
    private func setupConstraints() {
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField], axis: .vertical, spacing: 0)
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField], axis: .vertical, spacing: 0)
        let confirmPasswordStackView = UIStackView(arrangedSubviews: [confirmPasswordLabel, confirmPasswordTextField], axis: .vertical, spacing: 0)
        
        signUpButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [
            emailStackView, passwordStackView, confirmPasswordStackView, signUpButton
        ],
                                    axis: .vertical,
                                    spacing: 40)
        loginButton.contentHorizontalAlignment = .leading
        let bottomStackView = UIStackView(arrangedSubviews: [
            alreadyOnboardLabel, loginButton
        ],
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
            welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 160),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 150),
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
