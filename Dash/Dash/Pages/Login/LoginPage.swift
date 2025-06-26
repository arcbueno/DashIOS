//
//  LoginPage.swift
//  Dash
//
//  Created by Pedro Bueno on 25/06/25.
//

import SwiftUI

struct LoginPage: View {
    @StateObject private var viewModel = LoginViewModel(loginRepository: Injection.shared.container.resolve(LoginRepository.self)!)
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Login")
        }
        .padding()
        
    }
}

#Preview {
    LoginPage()
}
