//
//  ListViewController.swift
//  myChat
//
//  Created by QwertY on 20.08.2022.
//

import UIKit
import FirebaseFirestore

class ListViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<ChatSection, MChat>?
    
    private var viewModel: ListViewModelType
    
    init(viewModel: ListViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = viewModel.currentUser.username
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.removeListeners()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupSearchBar()
        setupCollectionView()
        createDataSource()
        reloadDataSource()
        
        viewModel.createWaitingChatsObserver(completion: { result in
            switch result {
            case .success():
                if let chatRequestVC = self.viewModel.chatRequestVC {
                    let viewModel = self.viewModel as! WaitingChatNavigation
                    chatRequestVC.viewModel.setDelegate(delegate: viewModel)
                    self.present(chatRequestVC, animated: true)
                }
                
                self.viewModel.reloadDataSource { snapshot in
                    self.dataSource?.apply(snapshot, animatingDifferences: true)
                }
            case .failure(let error):
                self.showAlert(with: "Error!", message: error.localizedDescription)
            }
        })
        
        viewModel.createActiveChatsObserver(completion: { result in
            switch result {
            case .success():
                self.viewModel.reloadDataSource { snapshot in
                    self.dataSource?.apply(snapshot, animatingDifferences: true)
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                self.showAlert(with: "Error!", message: error.localizedDescription)
            }
        })
    }
    
    private func reloadDataSource() {
        viewModel.reloadDataSource { snapshot in
            self.dataSource?.apply(snapshot, animatingDifferences: true)
        }
    }
}

// MARK: - View Setup
extension ListViewController {
    private func setupSearchBar() {
        navigationController?.navigationBar.barTintColor = .mainWhite()
        navigationController?.navigationBar.shadowImage = UIImage()
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .mainWhite()
        view.addSubview(collectionView)
        
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseID)
        collectionView.register(ActiveChatCell.self, forCellWithReuseIdentifier: ActiveChatCell.reuseID)
        collectionView.register(WaitingChatCell.self, forCellWithReuseIdentifier: WaitingChatCell.reuseID)
        
        collectionView.delegate = self
    }
}

// MARK: - Data Source
extension ListViewController {    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<ChatSection, MChat>(collectionView: collectionView, cellProvider: { collectionView, indexPath, chat in
            guard let section = ChatSection(rawValue: indexPath.section) else { fatalError("Unknown section type")
            }
            
            switch section {
            case .activeChats:
                return self.configure(collectionView: collectionView, cellType: ActiveChatCell.self, with: chat, for: indexPath)
            case .waitingChats:
                return self.configure(collectionView: collectionView, cellType: WaitingChatCell.self, with: chat, for: indexPath)
            }
        })
        
        dataSource?.supplementaryViewProvider = {
            collectionView, kind, indexPath in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseID, for: indexPath) as? SectionHeader else {
                fatalError("Can not create new section header")
            }
            
            guard let section = ChatSection(rawValue: indexPath.section) else {
                fatalError("Unknown section type")
            }
            
            
            
            sectionHeader.configure(text: section.description(), font: .laoSangamMN20(), textColor: #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1))
            return sectionHeader
        }
    }
}

// MARK: - UICollectionView Delegate
extension ListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let chat = self.dataSource?.itemIdentifier(for: indexPath) else { return }
        guard let section = ChatSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .waitingChats:
            let chatRequestViewModel = ChatRequestViewModel(chat: chat)
            let viewModel = self.viewModel as! WaitingChatNavigation
            chatRequestViewModel.delegate = viewModel
            let chatRequestVC = ChatRequestViewController(viewModel: chatRequestViewModel)
            self.present(chatRequestVC, animated: true)
        case .activeChats:
            let chatViewModel = ChatViewModel(user: viewModel.currentUser, chat: chat)
            let chatVC = ChatViewController(viewModel: chatViewModel)
            navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}

// MARK: - UISearchBarDelegate
extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}

// MARK: - Setup Layout
extension ListViewController {
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEvironment in
            guard let section = ChatSection(rawValue: sectionIndex) else { fatalError("Unknown section type")
            }
            
            switch section {
            case .activeChats:
                return self.createActiveChats()
            case .waitingChats:
                switch self.viewModel.isWaitingChatsEmpty {
                case true:
                    return self.emptySectionLayout()
                case false:
                    return self.createWaitingChats()
                }
            }
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20 
        layout.configuration = config
        return layout
    }
    
    private func createWaitingChats() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(88), heightDimension: .absolute(88))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 20
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func createActiveChats() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(78))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets.init(top: 16, leading: 20, bottom: 0, trailing: 20)
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
    }
    
    private func emptySectionLayout() -> NSCollectionLayoutSection {
        let sizeConstant: CGFloat = 0.01
        
        let size = NSCollectionLayoutSize(
            widthDimension: .absolute(sizeConstant),
            heightDimension: .absolute(sizeConstant)
        )
        let item = NSCollectionLayoutItem(
            layoutSize: size
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: size,
            subitems: [item]
        )
    
        let emptySectionLayout = NSCollectionLayoutSection(group: group)
        
        return emptySectionLayout
    }
    
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(1))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: sectionHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        return sectionHeader
    }
}
