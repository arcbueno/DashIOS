//
//  HomePage.swift
//  Dash
//
//  Created by Pedro Bueno on 25/06/25.
//

import SwiftUI

struct HomePage: View {
 /*   @StateObject private var viewModel = LoginViewModel(loginRepository: Injection.shared.container.resolve(LoginRepository.self)!)*/
    
    var appController: AppController
    @State private var path: [String] = []
    
    init(appController: AppController){
        self.appController = appController
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            .padding()
        }
        
    }
}

#Preview {
    HomePage(appController: AppController())
}
