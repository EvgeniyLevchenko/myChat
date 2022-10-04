//
//  ChatViewController.swift
//  myChat
//
//  Created by QwertY on 14.09.2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    private let viewModel: ChatViewModelType
    
    init(viewModel: ChatViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = viewModel.chat.value.friendUsername
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.messageListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageInputBar()
        messagesCollectionView.backgroundColor = .mainWhite()
        
        bindViews()
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
        }
        
        messageInputBar.delegate = viewModel.self as? ChatViewModel
        messagesCollectionView.messagesDataSource = viewModel.self as? ChatViewModel
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        viewModel.createMessagesObserver { error in
            if let error = error {
                self.showAlert(with: "Error!", message: error.localizedDescription)
            }
        }
        
        viewModel.createChatObserver { error in
            if let error = error {
                self.showAlert(with: "Error!", message: error.localizedDescription)
            }
        }
        
        messageInputBar.inputTextView.delegate = viewModel.self as! ChatViewModel
    }
    
    private func bindViews() {
        viewModel.messages.bind { _ in
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem()
            }
        }
        
        viewModel.sendMessageResult?.bind(listener: { result in
            switch result {
            case .success(_):
                self.messagesCollectionView.scrollToLastItem()
            case .failure(let error):
                self.showAlert(with: "Error!", message: error.localizedDescription)
            }
        })
        
        viewModel.chat.bind { chat in
            DispatchQueue.main.async {
                if chat.isFriendTyping {
                    self.setTypingIndicatorViewHidden(false, animated: true)
                    self.messagesCollectionView.scrollToLastItem()
                } else {
                    self.setTypingIndicatorViewHidden(true, animated: true)
                }
            }
        }
    }
    
    @objc private func cameraButtonTapped() {
        let picker = UIImagePickerController()
        picker.delegate = viewModel.self as? ChatViewModel
        
        let imageSourceTypeAlert = UIAlertController(title: "Options", message: "Select an option", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                self.present(picker, animated: true)
            }
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default) { _ in
            self.present(picker, animated: true)
        }
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
        
        imageSourceTypeAlert.addAction(cameraAction)
        imageSourceTypeAlert.addAction(photoLibraryAction)
        imageSourceTypeAlert.addAction(dismissAction)
        
        present(imageSourceTypeAlert, animated: true)
    }
}

// MARK: - Messages Layout Delegate
extension ChatViewController: MessagesLayoutDelegate {
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.item % 4 == 0 {
            return 30
        } else {
            return 0
        }
    }
}

// MARK: - Messages Display Delegate
extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let viewModel = viewModel as! ChatViewModel
        return viewModel.isFromCurrentSender(message: message) ? .systemGreen : #colorLiteral(red: 0.7882352941, green: 0.631372549, blue: 0.9411764706, alpha: 1)
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return #colorLiteral(red: 0.2392156863, green: 0.2392156863, blue: 0.2392156863, alpha: 1)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize? {
        return .zero
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
}

// MARK: - Message Input Bar Setup
extension ChatViewController {
    
    func configureMessageInputBar() {
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundView.backgroundColor = .mainWhite()
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.placeholderTextColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 14, left: 30, bottom: 14, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 14, left: 36, bottom: 14, right: 36)
        messageInputBar.inputTextView.layer.borderColor = #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 0.4033635232)
        messageInputBar.inputTextView.layer.borderWidth = 0.2
        messageInputBar.inputTextView.layer.cornerRadius = 18.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        
        messageInputBar.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        messageInputBar.layer.shadowRadius = 5
        messageInputBar.layer.shadowOpacity = 0.3
        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        configureSendButton()
        configureCameraIcon()
    }
    
    func configureSendButton() {
        messageInputBar.sendButton.setImage(UIImage(named: "Sent"), for: .normal)
        messageInputBar.sendButton.setTitle("", for: .normal)
        messageInputBar.setRightStackViewWidthConstant(to: 45, animated: false)
        messageInputBar.sendButton.setSize(CGSize(width: 48, height: 48), animated: false)
        messageInputBar.middleContentViewPadding.right = -43
    }
    
    func configureCameraIcon() {
        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = #colorLiteral(red: 0.7882352941, green: 0.631372549, blue: 0.9411764706, alpha: 1)
        guard let cameraImage = UIImage(systemName: "camera") else { return }
        cameraItem.image = cameraImage
        
        cameraItem.addTarget(self, action: #selector(cameraButtonTapped), for: .primaryActionTriggered)
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: true)
        
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: true)
    }
}
