//
//  LoginState.swift
//  Dash
//
//  Created by Pedro Bueno on 05/07/25.
//

protocol LoginViewModelState{}

struct LoginViewModelStateFilling: LoginViewModelState {
}

struct LoginViewModelStateLoading: LoginViewModelState {
}

struct LoginViewModelStateError: LoginViewModelState {
    let errorMessage: String
    
    init(errorMessage: String = "An error occurred"){
        self.errorMessage = errorMessage
    }
}

