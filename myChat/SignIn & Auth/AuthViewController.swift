//
//  AuthViewController.swift
//  myChat
//
//  Created by QwertY on 11.08.2022.
//

import UIKit

class AuthViewController: UIViewController {
    
    let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Logo"), contentMode: .scaleAspectFit)
    let googleLabel = UILabel(text: "Get started with")
    let emailLabel = UILabel(text: "Or sign up wigh ")
    let alreadyOnboardLabel = UILabel(text: "Already onboard?")
    let googleButton = UIButton(title: "Google", titleColor: .black, backgroundColor: .white, isShadow: true)
    let emailButton = UIButton(title: "Email", titleColor: .white, backgroundColor: .black)
    let loginButton = UIButton(title: "Login", titleColor: .buttonRed(), backgroundColor: .white, isShadow: true)
    
    var viewModel: AuthViewModelType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AuthViewModel()
        googleButton.customizeGoogleButton()
        view.backgroundColor = .white
        setupConstraints()
        
        googleButton.addTarget(self, action: #selector(googleButtonTapped), for: .touchUpInside)
        emailButton.addTarget(self, action: #selector(emailButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    @objc private func googleButtonTapped() {
        viewModel?.googleLogin(presentingVC: self, completion: { result in
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
        })
    }
    
    @objc private func emailButtonTapped() {
        guard let signUpVC = viewModel?.signUpVC else { return }
        present(signUpVC, animated: true)
    }
    
    @objc private func loginButtonTapped() {
        guard let loginVC = viewModel?.loginVC else { return }
        present(loginVC, animated: true)
    }
}

// MARK: - Setup constraints
extension AuthViewController {
    private func setupConstraints() {
        let googleView = ButtonFormView(label: googleLabel, button: googleButton)
        let emailView = ButtonFormView(label: emailLabel, button: emailButton)
        let loginView = ButtonFormView(label: alreadyOnboardLabel, button: loginButton)
        
        let stackView = UIStackView(arrangedSubviews: [googleView, emailView, loginView], axis: .vertical, spacing: 40)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoImageView)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 160),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 160),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}
