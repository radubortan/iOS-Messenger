import UIKit

class HomeViewController: UIViewController {
    
    private let services : Services
    
    private let titleLabel = UILabel()
    private let buttonsStack = UIStackView()
    
    init(services: Services) {
        self.services = services
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Assets.Colors.blue

        setupTitle()
        setupImage()
        setupButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        // to have no navbar transition
        navigationController?.navigationBar.layoutIfNeeded()
    }
    
    private func setupTitle() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        titleLabel.text = "Messenger"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 50, weight: .bold)
    }
    
    private func setupImage() {
        let image = UIImageView(image: Assets.Images.logo)
        view.addSubview(image)
        image.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-30)
            make.height.width.equalTo(75)
        }
    }
    
    private func setupButtons() {
        setupButtonsStack()
        setupLoginButton()
        setupSignUpButton()
    }
    
    private func setupButtonsStack() {
        view.addSubview(buttonsStack)
        buttonsStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
        buttonsStack.axis = .vertical
        buttonsStack.spacing = 30
    }
    
    private func setupLoginButton() {
        let loginButton = Button()
        buttonsStack.addArrangedSubview(loginButton)
        loginButton.backgroundColor = Assets.Colors.green
        loginButton.setTitle("Log In", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
    }
    
    private func setupSignUpButton() {
        let signUpButton = Button()
        buttonsStack.addArrangedSubview(signUpButton)
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.backgroundColor = .white
        signUpButton.setTitleColor(Assets.Colors.blue, for: .normal)
        signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
    }
    
    @objc private func didTapLoginButton() {
        navigationController?.pushViewController(LoginViewController(services: services), animated: true)
    }
    
    @objc private func didTapSignUpButton() {
        navigationController?.pushViewController(SignUpViewController(services: services), animated: true)
    }
}
