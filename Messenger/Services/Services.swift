class Services {
    let authenticationService = AuthenticationService()
    let messagesService : MessagesService
    
    init() {
        self.messagesService = MessagesService(authenticationService: authenticationService)
    }
}
