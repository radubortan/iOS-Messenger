import UIKit

enum MessageCellType {
    case normal
    case fullyRounded
    case topRounded
    case bottomRounded
}

class MessageCell: UITableViewCell {
    
    static let identifier = "MessageCell"
    
    let stack = UIStackView()
    let usernameContainer = UIView()
    let usernameLabel = UILabel()
    let bubble = UIView()
    let messageLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    
        setupStack()
        stack.addArrangedSubview(usernameContainer)
        setupUsernameLabel()
        setupBubble()
        setupMessageLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStack() {
        contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        stack.axis = .vertical
        stack.spacing = 5
    }
    
    private func setupUsernameLabel() {
        usernameContainer.addSubview(usernameLabel)
        usernameLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        usernameLabel.font = UIFont.systemFont(ofSize: 15)
        usernameLabel.textColor = .systemGray
    }
    
    private func setupBubble() {
        stack.addArrangedSubview(bubble)
        bubble.layer.cornerRadius = 20
    }
    
    private func setupMessageLabel() {
        bubble.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(10)
            make.bottom.trailing.equalToSuperview().offset(-10)
        }
        messageLabel.font = UIFont.systemFont(ofSize: 17)
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
    }
    
    func updateTopConstraintOffset(_ offset: Int) {
        stack.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(offset)
        }
    }
    
    func configure(withMessage message: Message, isMessageFromDifferentUser: Bool, withType type: MessageCellType) {
        usernameLabel.text = message.senderUsername
        messageLabel.text = message.body
        
        bubble.backgroundColor = Assets.Colors.blue
        
        if isMessageFromDifferentUser {
            stack.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(10)
                make.trailing.equalToSuperview().offset(-50)
            }
            bubble.backgroundColor = Assets.Colors.green
        } else {
            stack.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(50)
                make.trailing.equalToSuperview().offset(-10)
            }
            bubble.backgroundColor = Assets.Colors.blue
        }
        
        switch type {
        case .normal:
            makeCellNormal()
        case .fullyRounded:
            makeCellFullyRounded(isMessageFromDifferentUser: isMessageFromDifferentUser)
        case .topRounded:
            makeCellTopRounded(isMessageFromDifferentUser: isMessageFromDifferentUser)
        case .bottomRounded:
            makeCellBottomRounded()
        }
    }
    
    private func makeCellNormal() {
        bubble.layer.maskedCorners = []
        usernameContainer.isHidden = true
        stack.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(3)
        }
    }
    
    private func makeCellFullyRounded(isMessageFromDifferentUser: Bool) {
        bubble.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
        if isMessageFromDifferentUser {
            usernameContainer.isHidden = false
        } else {
            usernameContainer.isHidden = true
        }
        stack.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(10)
        }
    }
    
    private func makeCellTopRounded(isMessageFromDifferentUser: Bool) {
        makeCellFullyRounded(isMessageFromDifferentUser: isMessageFromDifferentUser)
        bubble.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func makeCellBottomRounded() {
        bubble.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        usernameContainer.isHidden = true
        stack.snp.updateConstraints { make in
            make.top.equalToSuperview().offset(3)
        }
    }
}
