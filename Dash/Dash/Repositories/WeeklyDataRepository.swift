//
//  WeeklyDataRepository.swift
//  Dash
//
//  Created by Pedro Bueno on 26/06/25.
//

import FirebaseAuth
import FirebaseFirestore

class WeeklyDataRepository {
    let firebaseAuth: AuthProtocol
    let db: FirestoreProtocol
    
    init(firebaseAuth: AuthProtocol, firestore: FirestoreProtocol) {
        self.firebaseAuth = firebaseAuth
        self.db = firestore
    }
    
    func fetchWeeklyItems() async throws -> any Result<[WeeklyItem]> {
        guard let user = firebaseAuth.currentUser else {
            throw NSError(domain: "User not authenticated", code: 401, userInfo: nil)
        }
        do {
            var list = [WeeklyItem]()
            let snapshot = try await db.collection(user.uid).document("WeeklyData").collection("items").getDocuments()
            for document in snapshot.documents {
                let item = try document.data(as: WeeklyItem.self)
                list.append(item)
            }
            
            return Success(list)
        } catch {
            print("Error getting documents: \(error)")
        }
        
        return Success([WeeklyItem]())
    }
    
    func deleteItem(item: WeeklyItem) async throws -> any Result<Bool> {
        guard let user = firebaseAuth.currentUser else {
            throw NSError(domain: "User not authenticated", code: 401, userInfo: nil)
        }
        do{
            let userRef = db.collection(user.uid).document("WeeklyData").collection("items").document(item.id)
            try await userRef.delete()
            return Success(true)
        } catch {
            print("Error deleting document: \(error)")
            return Failure(error)
        }
    }

    
    func addItem(item:WeeklyItem) async throws -> any Result<Bool> {
        guard let user = firebaseAuth.currentUser else {
            throw NSError(domain: "User not authenticated", code: 401, userInfo: nil)
        }
        
        do {
            let userRef = db.collection(user.uid).document("WeeklyData").collection("items").document(item.id)
            let _ = try userRef.setData(from: item)
            return Success(true)
        } catch {
            print("Error adding document: \(error)")
            return Failure(error)
        }
    }
}
