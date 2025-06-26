//
//  LoginPage.swift
//  Dash
//
//  Created by Pedro Bueno on 25/06/25.
//

import SwiftUI

struct LoginPage: View {
    var appController: AppController
    @StateObject private var viewModel = LoginViewModel(loginRepository: Injection.shared.container.resolve(LoginRepository.self)!)
    
    init(appController: AppController){
        self.appController = appController
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                VStack (alignment: .center) {
                    
                    Text("Dash")
                        .font(.system(size: 52))
                        .fontWeight(.semibold)
                        .padding()
                    VStack{
                        TextField("Email", text: $viewModel.email, prompt: Text("Email").foregroundColor(.gray))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.black)
                            .padding(.top, 4)
                    }.padding()
                    
                    VStack{
                        SecureField("Password", text: $viewModel.password, prompt: Text("Password").foregroundColor(.gray))
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.black)
                            .padding(.top, 4)
                    }.padding()
                    Button(action: {
                        Task {
                            let success = await viewModel.signIn()
                            if let user = success {
                                self.appController.user = user
                            }
                        }
                    }) {
                        Text("Log in")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.darkGray))
                            .cornerRadius(99)
                    }.padding()
                    //                        .navigationDestination(isPresented: $viewModel.isSuccess) {
                    //                            HomePage(appController: appController)
                    //                        }
                    if let errorState = viewModel.state as? LoginViewModelStateError {
                        Text(errorState.errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
                if($viewModel.state.wrappedValue is LoginViewModelStateLoading) {
                    ProgressView("Loading...")
                }
                
            }
        }
    }
}

#Preview {
    LoginPage(appController: AppController())
}
