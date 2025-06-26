//
//  LoginViewModel.swift
//  Dash
//
//  Created by Pedro Bueno on 25/06/25.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var state: LoginViewModelState = LoginViewModelStateFilling()
    
    private let loginRepository: LoginRepository
    
    init(loginRepository: LoginRepository) {
        self.loginRepository = loginRepository
    }
    
    func signIn(email: String, password: String) async -> Bool {
        self.state = LoginViewModelStateLoading()
        do {
            let result = try await loginRepository.signIn(email: email, password: password)
            print("User signed in successfully: \(result.user.email ?? "No email")")
            return true;
        }catch {
            print("Error signing in: \(error.localizedDescription)")
            self.state = LoginViewModelStateError(errorMessage: error.localizedDescription)
            return false;
        }
    }

}

protocol LoginViewModelState{}

class LoginViewModelStateFilling: LoginViewModelState {
}

class LoginViewModelStateLoading: LoginViewModelState {
}

class LoginViewModelStateError: LoginViewModelState {
    let errorMessage: String
    
    init(errorMessage: String = "An error occurred"){
        self.errorMessage = errorMessage
    }
}
