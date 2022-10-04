//
//  ActiveChatCell.swift
//  myChat
//
//  Created by QwertY on 23.08.2022.
//

import UIKit
import SDWebImage

class ActiveChatCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseID: String = "ActiveChatCell"
    
    private let friendImageView = UIImageView()
    private var photoMessageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray2
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        imageView.layer.borderColor = UIColor.systemGray4.cgColor
        imageView.layer.borderWidth = 1
        imageView.image = UIImage(named: "imagePlaceholder")
        return imageView
    }()
    private let friendName = UILabel(text: "User name:", font: .laoSangamMN20())
    private let lastMessage = UILabel(text: "How are you?", font: .laoSangamMN18())
    private let gradientView = GradientView(from: .topTrailing, to: .bottomLeading, startColor: #colorLiteral(red: 0.7882352941, green: 0.631372549, blue: 0.9411764706, alpha: 1), endColor: #colorLiteral(red: 0.4784313725, green: 0.6980392157, blue: 0.9215686275, alpha: 1))
    private var lastMessageStackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupConstraints()
        
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure<U>(with value: U) where U : Hashable {
        guard let chat: MChat = value as? MChat else { return }
        friendImageView.sd_setImage(with: URL(string: chat.friendAvatarStringURL))
        friendName.text = chat.friendUsername
        lastMessage.textColor = .black
        if chat.isFriendTyping {
            // MARK: - TO DO typing status animation
            lastMessage.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
            lastMessage.text = "is typing..."
        } else if chat.lastMessageContent.isEmpty {
            addPhotoMessageImageView()
            let photoMessage = "Photo"
            lastMessage.text = photoMessage
        } else {
            removePhotoMessageImageView()
            lastMessage.text = chat.lastMessageContent
        }
    }
    
    private func addPhotoMessageImageView() {
        lastMessageStackView.insertArrangedSubview(photoMessageImageView, at: 0)
    }

    private func removePhotoMessageImageView() {
        lastMessageStackView.removeArrangedSubview(photoMessageImageView)
        photoMessageImageView.removeFromSuperview()
    }
}

// MARK: - Setup Constraints
extension ActiveChatCell {
    private func setupConstraints() {
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        friendName.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(friendImageView)
        addSubview(gradientView)
        addSubview(friendName)
        
        lastMessageStackView = UIStackView(arrangedSubviews: [lastMessage],
                                           axis: .horizontal,
                                           spacing: 8)
        lastMessageStackView.translatesAutoresizingMaskIntoConstraints = false
        lastMessageStackView.alignment = .lastBaseline
        addSubview(lastMessageStackView)
        
        NSLayoutConstraint.activate([
            friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            friendImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            friendImageView.heightAnchor.constraint(equalToConstant: 78),
            friendImageView.widthAnchor.constraint(equalToConstant: 78)
        ])
        
        NSLayoutConstraint.activate([
            friendName.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            friendName.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            friendName.trailingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            gradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            gradientView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 78),
            gradientView.widthAnchor.constraint(equalToConstant: 8)
        ])
        
        NSLayoutConstraint.activate([
            lastMessageStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
            lastMessageStackView.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            lastMessageStackView.trailingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            photoMessageImageView.heightAnchor.constraint(equalToConstant: 24),
            photoMessageImageView.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
}
