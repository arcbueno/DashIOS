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
import FirebaseFirestore


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
    @StateObject var appController : AppController = AppController()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if(appController.isAuthenticated) {
                    HomePage(appController: appController)
                } else {
                    LoginPage(appController: appController)
                }
            }
        }.environmentObject(appController)
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
        let firestoreDb = Firestore.firestore()
        container.register(Firestore.self ,factory: { _ in firestoreDb })
        container.register(Auth.self ,factory: { _ in Auth.auth() })
        container.register(LoginRepository.self, factory: { resolver in
            LoginRepository(firebaseAuth: resolver.resolve(Auth.self)!)
        })
        container.register(WeeklyDataRepository.self, factory: { resolver in
            WeeklyDataRepository(firebaseAuth: resolver.resolve(Auth.self)!, firestore: resolver.resolve(Firestore.self)!)
        })
        container.register(InboxRepository.self, factory: { resolver in
            InboxRepository(firebaseAuth: resolver.resolve(Auth.self)!, firestore: resolver.resolve(Firestore.self)!)
        })
        return container
    }
}
