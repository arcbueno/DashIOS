//
//  AuthProtocol.swift
//  Dash
//
//  Created by Pedro Bueno on 07/07/25.
//
import Foundation
import FirebaseAuth

protocol AuthProtocol {
    func signIn(withEmail email: String, password: String) async throws -> AuthDataResult
    func signOut() throws
    var currentUser: User? { get }
}

extension Auth: AuthProtocol {
}
