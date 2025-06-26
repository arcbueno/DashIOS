//
//  AppController.swift
//  Dash
//
//  Created by Pedro Bueno on 25/06/25.
//

import FirebaseAuth

@MainActor
class AppController : ObservableObject{
    @Published var user: User? = nil
    var isAuthenticated: Bool {
        return user != nil
    }
    
    
}
