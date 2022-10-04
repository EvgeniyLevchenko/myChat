//
//  PeopleViewController.swift
//  myChat
//
//  Created by QwertY on 20.08.2022.
//

import UIKit

class PeopleViewController: UIViewController {

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<UserSection, MUser>!

    private var viewModel: PeopleViewModelType?
    
    init(viewModel: PeopleViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = viewModel.currentUser.username
    }
    
    deinit {
        viewModel?.usersListener?.remove()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupCollectionView()
        createDataSource()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(signOut))
        
        viewModel?.users.bind(listener: { [unowned self] users in
            viewModel?.reloadDataSource(with: nil) { snapshot in
                self.dataSource?.apply(snapshot, animatingDifferences: true, completion: {
                    self.collectionView.reloadData()
                })
            }
        })
        
        viewModel?.createUsersObserver(completion: { error in
            if let error = error {
                self.showAlert(with: "Error", message: error.localizedDescription)
            }
        })
    }
    
    @objc private func signOut() {
        viewModel?.signOut(from: view, completion: { alertController in
            self.present(alertController, animated: true)
        })
    }
}

// MARK: - Data Source
extension PeopleViewController {
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<UserSection, MUser>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, user) -> UICollectionViewCell? in
            guard let section = UserSection(rawValue: indexPath.section) else {
                fatalError("Unknown section type")
            }
            
            switch section {
            case .users:
                return self.configure(collectionView: collectionView, cellType: UserCell.self, with: user, for: indexPath)
            }
        })
        
        createHeaderDataSource()
    }
    
    private func createHeaderDataSource() {
        dataSource?.supplementaryViewProvider = {
            collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseID, for: indexPath) as? SectionHeader else {
                fatalError("Can not create new section header")
            }
            
            guard let section = UserSection(rawValue: indexPath.section) else {
                fatalError("Unknown section type")
            }
            
            let items = self.dataSource.snapshot().itemIdentifiers(inSection: .users)
            sectionHeader.configure(text: section.description(usersCount: items.count), font: .systemFont(ofSize: 36, weight: .light), textColor: .label)
            return sectionHeader
        }
    }
}

// MARK: - Seach Bar Delegate
extension PeopleViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel?.reloadDataSource(with: searchText) { snapshot in
            self.dataSource?.apply(snapshot, animatingDifferences: true, completion: {
                self.collectionView.reloadData()
            })
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel?.reloadDataSource(with: nil) { snapshot in
            self.dataSource?.apply(snapshot, animatingDifferences: true, completion: {
                self.collectionView.reloadData()
            })
        }
    }
}

// MARK: - Collection View Delegate
extension PeopleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = self.dataSource.itemIdentifier(for: indexPath) else { return }
        let viewModel = ProfileViewModel(user: user)
        let profileVC = ProfileViewController(viewModel: viewModel)
        present(profileVC, animated: true)
    }
}

// MARK: - Setup View
extension PeopleViewController {
    private func setupSearchBar() {
        navigationController?.navigationBar.barTintColor = .mainWhite()
        navigationController?.navigationBar.shadowImage = UIImage()
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .mainWhite()
        view.addSubview(collectionView)
        
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseID)
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseID)
        
        collectionView.delegate = self
    }
}

// MARK: - Setup Layout
extension PeopleViewController {
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEvironment in
            guard let section = UserSection(rawValue: sectionIndex) else { fatalError("Unknown section type")
            }
            
            switch section {
            case .users:
                return self.createUserSection()
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        return layout
    }
    
    private func createUserSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.6))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        let spacing = CGFloat(15)
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 15, bottom: 0, trailing: 15)
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        return section
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem{
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize,
                                                                        elementKind: UICollectionView.elementKindSectionHeader,
                                                                        alignment: .top)
        return sectionHeader 
    }
}
