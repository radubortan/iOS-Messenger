import UIKit

class LoginViewController: UIViewController {
    
    private let services: Services
    
    private let mainStack = UIStackView()
    private let emailInput = TextField(withPlaceholder: "Email", ofType: .regular)
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
        mainStack.addArrangedSubview(emailInput)
        emailInput.text = "test@test.com"
        mainStack.addArrangedSubview(passwordInput)
        passwordInput.text = "password"
        setupLoginButton()
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
        title.text = "Log In"
        title.font = UIFont.systemFont(ofSize: 40, weight: .black)
        title.textColor = Assets.Colors.green
    }
    
    private func setupLoginButton() {
        let loginButton = Button()
        mainStack.addArrangedSubview(loginButton)
        loginButton.setTitle("Log In", for: .normal)
        loginButton.backgroundColor = Assets.Colors.green
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
    }
    
    private func setupErrorLabel() {
        view.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(mainStack.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(Constants.Layout.authenticationPagesSidePadding)
            make.trailing.equalToSuperview().offset(-Constants.Layout.authenticationPagesSidePadding)
        }
    }
    
    @objc private func didTapLoginButton() {
        view.endEditing(true)
        guard let email = emailInput.text, let password = passwordInput.text else {
            return
        }
        
        services.authenticationService.logIn(withEmail: email, withPassword: password) { result in
            switch result {
            case .success():
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
