import UIKit

class ErrorLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        numberOfLines = 0
        textAlignment = .center
        textColor = .systemRed
        font = UIFont.systemFont(ofSize: 17)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
