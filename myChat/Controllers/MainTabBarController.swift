//
//  MainTabBarController.swift
//  myChat
//
//  Created by QwertY on 20.08.2022.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    let listViewController: ListViewController
    let peopleViewController: PeopleViewController

    init(currentUser: MUser) {
        let listViewModel = ListViewModel(currentUser: currentUser)
        let peopleViewModel = PeopleViewModel(currentUser: currentUser)
        listViewController = ListViewController(viewModel: listViewModel)
        peopleViewController = PeopleViewController(viewModel: peopleViewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func generateNavigationController(rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.title = title
        navigationVC.tabBarItem.image = image
        return navigationVC
    }
}


// MARK: - View setup
extension MainTabBarController {
    
    private func setupView() {
        setupViewControllers()
        setupTabBar()
    }
    
    private func setupViewControllers() {
        let boldConfig = UIImage.SymbolConfiguration(weight: .medium)
        guard let convImage = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: boldConfig),
              let peopleImage = UIImage(systemName: "person.2", withConfiguration: boldConfig)
        else {
            fatalError("Cannot find images to setup view")
        }
        
        viewControllers = [
            generateNavigationController(rootViewController: peopleViewController, title: "People", image: peopleImage),
            generateNavigationController(rootViewController: listViewController, title: "Conversations", image: convImage)
        ]
    }
    
    private func setupTabBar() {
        tabBar.tintColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        tabBar.backgroundColor = .white
        tabBar.layer.borderColor = UIColor.systemGray4.cgColor
        tabBar.layer.borderWidth = 1
    }
}
