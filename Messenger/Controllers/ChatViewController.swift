import UIKit
import FirebaseAuth
import FirebaseFirestore
import IQKeyboardManager

class ChatViewController: UIViewController {
    
    private let inputContainer = UIView()
    private let input = UITextField()
    private let sendButton = UIButton()
    private let tableView = UITableView()
    
    private let services : Services
    private var messages : [Message] = []
    
    init(services: Services) {
        self.services = services
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6

        setupKeyboardBehavior()
        setupNavbar()
        setupInputContainer()
        setupTableView()
    }
    
    private func setupKeyboardBehavior() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardOnTouchOutside)))
        IQKeyboardManager.shared().isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupNavbar() {
        navigationItem.hidesBackButton = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let logoutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(didTapLogOut))
        navigationItem.rightBarButtonItem = logoutButton
    }
    
    private func setupInputContainer() {
        view.addSubview(inputContainer)
        inputContainer.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(Constants.Layout.messageInputContainerHeight)
            make.leading.trailing.equalToSuperview()
        }
        inputContainer.backgroundColor = .systemGray6
        
        inputContainer.addSubview(input)
        input.snp.makeConstraints { make in
            make.height.equalTo(Constants.Layout.messageInputHeight)
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        input.placeholder = "Write a message..."
        input.borderStyle = .roundedRect
        
        inputContainer.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            make.height.width.equalTo(Constants.Layout.messageInputHeight)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
            make.leading.equalTo(input.snp.trailing).offset(10)
        }
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-Constants.Layout.messageInputContainerHeight)
            make.leading.trailing.equalToSuperview()
        }
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: Constants.Layout.chatTableViewInset, left: 0, bottom: Constants.Layout.chatTableViewInset, right: 0)
        tableView.dataSource = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
        
        let noMessagesLabel = UILabel()
        tableView.backgroundView = noMessagesLabel
        noMessagesLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        noMessagesLabel.text = "No messages"
        noMessagesLabel.textColor = .systemGray4
        
        loadMessages()
    }
    
    private func loadMessages() {
        services.messagesService.getMessages { results in
            switch results {
            case .success(let testMessages):
                self.messages = []
                self.messages += testMessages
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                    // scroll to bottom of list when sending a message
                    if !self.messages.isEmpty {
                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: Constants.Layout.chatTableViewInset + keyboardSize.height, left: 0, bottom: Constants.Layout.chatTableViewInset, right: 0)
            tableView.contentInset = contentInsets
            tableView.scrollIndicatorInsets = contentInsets
            
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc private func keyboardWillHide() {
        let contentInsets = UIEdgeInsets(top: Constants.Layout.chatTableViewInset, left: 0, bottom: Constants.Layout.chatTableViewInset, right: 0)
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
        
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc private func dismissKeyboardOnTouchOutside() {
        view.endEditing(true)
    }
    
    @objc private func didTapLogOut() {
        services.authenticationService.logOut { result in
            switch result {
            case .success(_):
                self.navigationController?.popToRootViewController(animated: true)
            case .failure(_):
                break
            }
        }
    }
    
    @objc private func didTapSendButton() {
        view.endEditing(true)
        if let messageBody = input.text, !messageBody.isEmpty {
            services.messagesService.sendMessage(withMessageBody: messageBody)
        }
        input.text = ""
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages.isEmpty {
            tableView.backgroundView?.isHidden = false
        } else {
            tableView.backgroundView?.isHidden = true
        }
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as! MessageCell
        
        let message = messages[indexPath.row]
        let isMessageFromDifferentUser = services.authenticationService.userEmail != message.senderEmail
        
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == messages.count - 1
        let isOnlyMessage = messages.count == 1
        let isPrevMsgFromDifferentUser = !isFirst && messages[indexPath.row - 1].senderEmail != message.senderEmail
        let isNextMsgFromDifferentUser = !isLast && messages[indexPath.row + 1].senderEmail != message.senderEmail
        
        if isOnlyMessage || (isPrevMsgFromDifferentUser && isNextMsgFromDifferentUser) || (isLast && isPrevMsgFromDifferentUser) || (isFirst && isNextMsgFromDifferentUser) {
            cell.configure(withMessage: message, isMessageFromDifferentUser: isMessageFromDifferentUser, withType: .fullyRounded)
        } else if !isPrevMsgFromDifferentUser && (isNextMsgFromDifferentUser || isLast) {
            cell.configure(withMessage: message, isMessageFromDifferentUser: isMessageFromDifferentUser, withType: .bottomRounded)
        } else if !isNextMsgFromDifferentUser && (isPrevMsgFromDifferentUser || isFirst) {
            cell.configure(withMessage: message, isMessageFromDifferentUser: isMessageFromDifferentUser, withType: .topRounded)
        } else {
            cell.configure(withMessage: message, isMessageFromDifferentUser: isMessageFromDifferentUser, withType: .normal)
        }
        
        if isFirst {
            cell.updateTopConstraintOffset(0)
        }
        
        return cell
    }
}
