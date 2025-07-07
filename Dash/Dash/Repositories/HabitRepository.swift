//
//  HabitRepository.swift
//  Dash
//
//  Created by Pedro Bueno on 02/07/25.
//

import FirebaseAuth
import FirebaseFirestore

class HabitRepository {
    let firebaseAuth: AuthProtocol
    let db: FirestoreProtocol
    
    init(firebaseAuth: AuthProtocol, firestore: FirestoreProtocol) {
        self.firebaseAuth = firebaseAuth
        self.db = firestore
    }
    
    func fetchAllHabits() async throws -> any Result<[HabitItem]> {
        guard let user = firebaseAuth.currentUser else {
            throw NSError(domain: "User not authenticated", code: 401, userInfo: nil)
        }
        do {
            var list = [HabitItem]()
            let snapshot = try await db.collection(user.uid).document("HabitData").collection("items").getDocuments()
            for document in snapshot.documents {
                let item = try document.data(as: HabitItem.self)
                list.append(item)
            }
            
            return Success(list)
        } catch {
            print("Error getting documents: \(error)")
        }
        
        return Success([HabitItem]())
    }
    
    func deleteItem(item: HabitItem) async throws -> any Result<Bool> {
        guard let user = firebaseAuth.currentUser else {
            throw NSError(domain: "User not authenticated", code: 401, userInfo: nil)
        }
        do{
            let userRef = db.collection(user.uid).document("HabitData").collection("items").document(item.id)
            try await userRef.delete()
            return Success(true)
        } catch {
            print("Error deleting document: \(error)")
            return Failure(error)
        }
    }
    
    func updateItem(item: HabitItem) async throws -> any Result<Bool> {
        guard let user = firebaseAuth.currentUser else {
            throw NSError(domain: "User not authenticated", code: 401, userInfo: nil)
        }
        do {
            let userRef = db.collection(user.uid).document("HabitData").collection("items").document(item.id)
            try userRef.setData(from: item)
            return Success(true)
        } catch {
            print("Error updating document: \(error)")
            return Failure(error)
        }
    }


    
    func addItem(item:HabitItem) async throws -> any Result<Bool> {
        guard let user = firebaseAuth.currentUser else {
            throw NSError(domain: "User not authenticated", code: 401, userInfo: nil)
        }
        
        do {
            let userRef = db.collection(user.uid).document("HabitData").collection("items").document(item.id)
            let _ = try userRef.setData(from: item)
            return Success(true)
        } catch {
            print("Error adding document: \(error)")
            return Failure(error)
        }
    }
}


