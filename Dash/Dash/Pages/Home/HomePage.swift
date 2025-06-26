//
//  HomePage.swift
//  Dash
//
//  Created by Pedro Bueno on 25/06/25.
//

import SwiftUI

struct HomePage: View {
 /*   @StateObject private var viewModel = LoginViewModel(loginRepository: Injection.shared.container.resolve(LoginRepository.self)!)*/
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        
    }
}

#Preview {
    LoginPage()
}
