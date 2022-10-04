//
//  SetupProfileViewController.swift
//  myChat
//
//  Created by QwertY on 20.08.2022.
//

import UIKit

class SetupProfileViewController: UIViewController {
    
    private let welcomeLabel = UILabel(text: "Set up profile!", font: .avenir26())
    private let fullImageView = AddPhotoView()
    private let fullNameLabel = UILabel(text: "Full Name")
    private let aboutMeLabel = UILabel(text: "About me")
    private let sexLabel = UILabel(text: "Sex")
    private let fullNameTextField = OneLineTextField(font: .avenir20())
    private let aboutMeTextField = OneLineTextField(font: .avenir20())
    private let sexSegmentedControl = UISegmentedControl(first: "Male", second: "Female")
    private let continueButton = UIButton(title: "Continue", titleColor: .white, backgroundColor: .buttonDark(), cornerRadius: 4)
    
    private var viewModel: SetupProfileViewModelType?
    
    init(viewModel: SetupProfileViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    
        fullNameTextField.text = viewModel.username
    
        viewModel.avatarImage.bind(listener: { avatarImage in
            self.fullImageView.circleImageView.image = avatarImage
        })
        
        if let photoURL = viewModel.avatarURL {
            fullImageView.circleImageView.sd_setImage(with: photoURL)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupConstraints()
        
        fullImageView.plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    @objc private func plusButtonTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = viewModel.self
        present(imagePickerController, animated: true)
    }
    
    @objc private func continueButtonTapped() {
        viewModel?.saveProfileWith(
            username: fullNameTextField.text,
            avatarImage: fullImageView.circleImageView.image,
            description: aboutMeTextField.text,
            sex: sexSegmentedControl.titleForSegment(at: sexSegmentedControl.selectedSegmentIndex)
        ) { result in
            switch result {
            case .success(_):
                guard let mainTabBarController = self.viewModel?.mainTabBarController else { return }
                mainTabBarController.modalPresentationStyle = .fullScreen
                self.showAlert(with: "Success!", message: "Have fun.") {
                    self.present(mainTabBarController, animated: true)
                }
            case .failure(let error):
                self.showAlert(with: "Error!", message: error.localizedDescription)
            }
        }
    }
}

// MARK: - Setup Constraints
extension SetupProfileViewController {
    private func setupConstraints() {
        
        let fullNameStackView = UIStackView(arrangedSubviews: [fullNameLabel, fullNameTextField],
                                            axis: .vertical,
                                            spacing: 0)
        let aboutMeStackView = UIStackView(arrangedSubviews: [aboutMeLabel, aboutMeTextField],
                                           axis: .vertical,
                                           spacing: 0)
        let sexStackView = UIStackView(arrangedSubviews: [sexLabel, sexSegmentedControl],
                                       axis: .vertical,
                                       spacing: 12)
        
        continueButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let stackView = UIStackView(arrangedSubviews: [
            fullNameStackView,
            aboutMeStackView,
            sexStackView,
            continueButton
        ],
                                    axis: .vertical,
                                    spacing: 40)
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        fullImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(welcomeLabel)
        view.addSubview(fullImageView)
        view.addSubview(stackView)
        
        fullImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fullImageView)
        
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 160),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            fullImageView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 40),
            fullImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: fullImageView.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}
