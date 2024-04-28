import UIKit

struct Constants {
    struct FirestoreStrings {
        static let messagesCollection = "messages"
        static let usernamesCollection = "usernames"
        static let senderEmail = "senderEmail"
        static let senderUsername = "senderUsername"
        static let bodyField = "body"
        static let dateField = "date"
        static let usernameField = "username"
        static let emailField = "email"
    }
    
    struct Layout {
        static let authenticationPagesSidePadding = 20
        static let chatTableViewInset : CGFloat = 10
        static let messageInputContainerHeight = 60
        static let messageInputHeight = 40
    }
}

enum Result<T> {
    case success(T)
    case failure(String)
}

typealias ResultCallback<T> = (Result<T>) -> Void
