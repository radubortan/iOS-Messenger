import FirebaseAuth
import FirebaseFirestore

class AuthenticationService {
    
    let db = Firestore.firestore()
    
    var userEmail : String {
        return Auth.auth().currentUser?.email ?? ""
    }
    var username: String?
    
    func logIn(withEmail email: String, withPassword password: String, completion: @escaping ResultCallback<Void>) {
        let normalizedEmail = normalizeEmailAddress(email)
        Auth.auth().signIn(withEmail: normalizedEmail, password: password) { authResult, error in
            if let e = error {
                completion(.failure(e.localizedDescription))
            } else {
                self.db.collection(Constants.FirestoreStrings.usernamesCollection)
                    .whereField(Constants.FirestoreStrings.emailField, isEqualTo: normalizedEmail)
                    .getDocuments { querySnapshot, error in
                        if let e = error {
                            print("There was an error getting the username: \(e)")
                            completion(.failure("An error has occurred."))
                        } else {
                            if let document = querySnapshot?.documents.first, let username = document.data()[Constants.FirestoreStrings.usernameField] as? String {
                                self.username = username
                                completion(.success(()))
                            } else {
                                print("No username was found for user.")
                                completion(.failure("An error has occurred."))
                            }
                        }
                    }
            }
        }
    }
    
    func logOut(completion: @escaping ResultCallback<Void>) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
            completion(.failure(""))
        }
    }
    
    func signUp(
        withUsername username: String,
        withEmail email: String,
        withPassword password: String,
        completion: @escaping ResultCallback<Void>
    ) {
        checkUsernameAvailability(username) { result in
            switch result {
            case .success(let isUsernameAvailable):
                if isUsernameAvailable {
                    self.createUser(email: self.normalizeEmailAddress(email), password: password) { result in
                        switch result {
                        case .success(_):
                            self.saveUserDataToFirestore(username: username, email: email) { result in
                                switch result {
                                case .success(_):
                                    self.username = username
                                    print("Sign up successful")
                                    completion(.success(()))
                                case .failure(let errorMessage):
                                    completion(.failure(errorMessage))
                                }
                            }
                        case .failure(let errorMessage):
                            completion(.failure(errorMessage))
                        }
                    }
                } else {
                    completion(.failure("Username taken"))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func normalizeEmailAddress(_ email: String) -> String {
        return email.replacingOccurrences(of: " ", with: "").lowercased()
    }
    
    private func checkUsernameAvailability(_ username: String, completion: @escaping ResultCallback<Bool>) {
        guard username != "" else {
            completion(.failure("Username cannot be empty."))
            return
        }
        db.collection(Constants.FirestoreStrings.usernamesCollection)
            .whereField(Constants.FirestoreStrings.usernameField, isEqualTo: username).getDocuments { querySnapshot, error in
                if let error = error {
                    print("There was an error fetching the usernames: \(error)")
                    completion(.failure("An error has occurred."))
                } else {
                    let isUsernameAvailable = querySnapshot?.documents.isEmpty ?? true
                    completion(.success(isUsernameAvailable))
                }
            }
    }

    private func saveUserDataToFirestore(username: String, email: String, completion: @escaping ResultCallback<Void>) {
        db.collection(Constants.FirestoreStrings.usernamesCollection).addDocument(data: [
            Constants.FirestoreStrings.usernameField: username,
            Constants.FirestoreStrings.emailField: email
        ]) { error in
            if let error {
                print("There was an error saving the data to Firestore: \(error)")
                completion(.failure("An error has occurred."))
            } else {
                completion(.success(()))
            }
        }
    }

    private func createUser(email: String, password: String, completion: @escaping ResultCallback<Void>) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error {
                print(error.localizedDescription)
                completion(.failure(error.localizedDescription))
            } else {
                completion(.success(()))
            }
        }
    }
}
