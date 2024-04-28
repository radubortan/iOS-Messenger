import UIKit

class SignUpViewController: UIViewController {
    
    private let services: Services
    
    private let mainStack = UIStackView()
    private let usernameInput = TextField(withPlaceholder: "Username", ofType: .regular)
    private let emailInput = TextField(withPlaceholder: "Email", ofType: .email)
    private let passwordInput = TextField(withPlaceholder: "Password", ofType: .password)
    private let errorLabel = ErrorLabel()
    
    init(services: Services) {
        self.services = services
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardOnTouchOutside)))
        
        setupMainStack()
        setupTitle()
        mainStack.addArrangedSubview(usernameInput)
        mainStack.addArrangedSubview(emailInput)
        mainStack.addArrangedSubview(passwordInput)
        setupSignUpButton()
        setupErrorLabel()
    }
    
    private func setupMainStack() {
        view.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(Constants.Layout.authenticationPagesSidePadding)
            make.trailing.equalToSuperview().offset(-Constants.Layout.authenticationPagesSidePadding)
        }
        mainStack.axis = .vertical
        mainStack.spacing = 30
    }
    
    private func setupTitle() {
        let title = UILabel()
        mainStack.addArrangedSubview(title)
        title.textAlignment = .center
        title.text = "Sign Up"
        title.font = UIFont.systemFont(ofSize: 40, weight: .black)
        title.textColor = Assets.Colors.blue
    }
    
    private func setupSignUpButton() {
        let signUpButton = Button()
        mainStack.addArrangedSubview(signUpButton)
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.backgroundColor = Assets.Colors.blue
        signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
    }
    
    private func setupErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(mainStack.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(Constants.Layout.authenticationPagesSidePadding)
            make.trailing.equalToSuperview().offset(-Constants.Layout.authenticationPagesSidePadding)
        }
    }
    
    @objc private func didTapSignUpButton() {
        view.endEditing(true)
        guard let username = usernameInput.text,
              let email = emailInput.text,
              let password = passwordInput.text else { return }
        
        services.authenticationService.signUp(withUsername: username, withEmail: email, withPassword: password) { result in
            switch result {
            case .success(_):
                self.navigationController?.pushViewController(ChatViewController(services: self.services), animated: true)
            case .failure(let errorMessage):
                self.errorLabel.text = errorMessage
            }
        }
    }
    
    @objc private func dismissKeyboardOnTouchOutside() {
        view.endEditing(true)
    }
}
