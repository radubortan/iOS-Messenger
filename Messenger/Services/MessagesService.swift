import FirebaseAuth
import FirebaseFirestore

class MessagesService {
    
    weak var authenticationService: AuthenticationService?
    
    private let db = Firestore.firestore()
    
    init(authenticationService: AuthenticationService) {
        self.authenticationService = authenticationService
    }
    
    func getMessages(completion: @escaping ResultCallback<[Message]>) {
        db.collection(Constants.FirestoreStrings.messagesCollection)
            .order(by: Constants.FirestoreStrings.dateField)
            .addSnapshotListener { querySnapshot, error in
            guard error == nil, let snapshotDocuments = querySnapshot?.documents else {
                completion(.failure("There was an error fetching the messages : \(String(describing: error))"))
                return
            }
            var results: [Message] = []
            for document in snapshotDocuments {
                let data = document.data()
                if
                    let messageSender = data[Constants.FirestoreStrings.senderEmail] as? String,
                    let messageBody = data[Constants.FirestoreStrings.bodyField] as? String,
                    let username = data[Constants.FirestoreStrings.senderUsername] as? String
                {
                    let newMessage = Message(senderEmail: messageSender, senderUsername: username, body: messageBody)
                    results.append(newMessage)
                }
            }
            completion(.success(results))
        }
    }
    
    func sendMessage(withMessageBody messageBody: String) {
        guard let userEmail = authenticationService?.userEmail, let username = authenticationService?.username else { return }
        db.collection(Constants.FirestoreStrings.messagesCollection).addDocument(data: [
            Constants.FirestoreStrings.senderEmail : userEmail,
            Constants.FirestoreStrings.senderUsername : username,
            Constants.FirestoreStrings.bodyField : messageBody,
            Constants.FirestoreStrings.dateField : Date().timeIntervalSince1970,
        ]) { error in
            if let e = error {
                print("There was an issue saving data to Firestore, \(e)")
            } else {
                print("Message sent")
            }
        }
    }
}
