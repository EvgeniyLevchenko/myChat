//
//  ProfileViewController.swift
//  myChat
//
//  Created by QwertY on 02.09.2022.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    
    private let containerView = UIView()
    private let imageView = UIImageView(image: #imageLiteral(resourceName: "human2"), contentMode: .scaleAspectFill)
    private let nameLabel = UILabel(text: "Peter Ben", font: .systemFont(ofSize: 20, weight: .light))
    private let aboutMeLabel = UILabel(text: "You have the opportunity to chat with the best man in the world!", font: .systemFont(ofSize: 16, weight: .light))
    private let myTextField = InsertableTextField()
    
    private var viewModel: ProfileViewModelType
    
    init(viewModel: ProfileViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        constomizeElements()
        setupConstraints()
        bindViews()
    }
    
    private func constomizeElements() {
        aboutMeLabel.numberOfLines = 0
        containerView.backgroundColor = .mainWhite()
        containerView.layer.cornerRadius = 30
        
        if let button = myTextField.rightView as? UIButton {
            button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        }
    }
    
    @objc private func sendMessage() {
        guard let message = myTextField.text, message != "" else { return }
        dismiss(animated: true) {
            self.viewModel.sendMessage(message: message) { error in
                if let error = error {
                    let topVC = UIApplication.topViewController()
                    topVC?.showAlert(with: "Error!", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func bindViews() {
        viewModel.username.bind { username in
            self.nameLabel.text = username
        }
        
        viewModel.description.bind { description in
            self.aboutMeLabel.text = description
        }
        
        viewModel.avatarStringURL.bind { _ in
            self.viewModel.setImage() { avatarImage in
                self.imageView.image = avatarImage
            }
        }
    }
}

extension ProfileViewController {
    
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
        myTextField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(aboutMeLabel)
        containerView.addSubview(myTextField)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: 30)
        ])
        
        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 206)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 35),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24)
        ])
        
        NSLayoutConstraint.activate([
            aboutMeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            aboutMeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            aboutMeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24)
        ])
        
        NSLayoutConstraint.activate([
            myTextField.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 8),
            myTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            myTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            myTextField.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}
