//
//  LoginRepository.swift
//  Dash
//
//  Created by Pedro Bueno on 25/06/25.
//

import FirebaseAuth

struct LoginRepository {
    let  firebaseAuth: Auth;
    
    init(firebaseAuth: Auth) {
        self.firebaseAuth = firebaseAuth
    }
    
    func signIn(email: String, password: String) async throws -> AuthDataResult {
        return try await firebaseAuth.signIn(withEmail: email, password: password)
    }
    
}
