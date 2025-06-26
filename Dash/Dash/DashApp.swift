//
//  DashApp.swift
//  Dash
//
//  Created by Pedro Bueno on 24/06/25.
//

import SwiftUI
import FirebaseCore
import Swinject
import FirebaseAuth


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct DashApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State var appController : AppController = Injection.shared.container.resolve(AppController.self)!
        
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if(appController.isAuthenticated) {
                    HomePage()
                } else {
                    LoginPage()
                }
            }
        }
    }
}

final class Injection {
    static let shared = Injection()
    var container: Container {
        get {
            return _container ?? buildContainer()
        }
        set {
            _container = newValue
        }
    }

    private var _container: Container?
    private func buildContainer() -> Container {
        let container = Container()
        container.register(AppController.self, factory: { _ in AppController() })
        container.register(Auth.self ,factory: { _ in Auth.auth() })
        container.register(LoginRepository.self, factory: { resolver in
            LoginRepository(firebaseAuth: resolver.resolve(Auth.self)!)
        })
        return container
    }
}
