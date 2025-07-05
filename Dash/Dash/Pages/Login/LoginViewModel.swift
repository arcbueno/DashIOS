//
//  LoginViewModel.swift
//  Dash
//
//  Created by Pedro Bueno on 25/06/25.
//

import Foundation
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var state: LoginViewModelState = LoginViewModelStateFilling()
    @Published var isSuccess = false
    
    var email: String = ""
    var password: String = ""
    
    private let loginRepository: LoginRepository
    
    init(loginRepository: LoginRepository) {
        self.loginRepository = loginRepository
    }
    
    func signIn() async -> User? {
        await MainActor.run {
            self.state = LoginViewModelStateLoading()
        }
        
        // TODO AddValidation for email and password
        do {
//            let result = try await loginRepository.signIn(email: email, password: password)
            // Test
            let result = try await loginRepository.signIn(email: "parcb.augusto@gmail.com", password: "123456")
            print("User signed in successfully: \(result.user.email ?? "No email")")
            
            await MainActor.run {
                self.isSuccess = true
                self.state = LoginViewModelStateFilling()
            }
            return result.user;
        }catch {
            print("Error signing in: \(error.localizedDescription)")
            
            self.state = LoginViewModelStateError(errorMessage: error.localizedDescription)
            return nil;
        }
    }
    
}

