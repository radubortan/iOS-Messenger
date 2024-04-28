import UIKit

class Button: UIButton {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        layer.cornerRadius = 10
        titleLabel?.font = UIFont.systemFont(ofSize: 25)
        snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
