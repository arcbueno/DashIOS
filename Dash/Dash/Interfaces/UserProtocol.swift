//
//  UserProtocol.swift
//  Dash
//
//  Created by Pedro Bueno on 07/07/25.
//

import FirebaseAuth

protocol AuthUser {
    var uid: String { get }
    var email: String? { get }
    var displayName: String? { get }
}

extension FirebaseAuth.User: AuthUser {}
