import UIKit

enum TextFieldType {
    case regular
    case email
    case password
}

class TextField: UITextField {
    init(withPlaceholder placeholder: String, ofType type: TextFieldType) {
        super.init(frame: .zero)
        
        self.placeholder = placeholder
        layer.cornerRadius = 10
        textAlignment = .center
        backgroundColor = .systemGray6
        font = UIFont.systemFont(ofSize: 25)
        snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        switch type {
        case .regular:
            autocorrectionType = .no
            autocapitalizationType = .none
        case .email:
            keyboardType = .emailAddress
            autocorrectionType = .no
            autocapitalizationType = .none
        case .password:
            isSecureTextEntry = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
