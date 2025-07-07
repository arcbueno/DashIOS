//
//  InboxRepository.swift
//  Dash
//
//  Created by Pedro Bueno on 01/07/25.
//

import FirebaseAuth
import FirebaseFirestore

class InboxRepository {
    let firebaseAuth: AuthProtocol
    let db: FirestoreProtocol
    
    init(firebaseAuth: AuthProtocol, firestore: FirestoreProtocol) {
        self.firebaseAuth = firebaseAuth
        self.db = firestore
    }
    
    func fetchInboxItems() async throws -> any Result<[InboxItem]> {
        guard let user = firebaseAuth.currentUser else {
            throw NSError(domain: "User not authenticated", code: 401, userInfo: nil)
        }
        do {
            var list = [InboxItem]()
            let snapshot = try await db.collection(user.uid).document("InboxData").collection("items").getDocuments()
            for document in snapshot.documents {
                let item = try document.data(as: InboxItem.self)
                list.append(item)
            }
            list.sort{ $0.done && !$1.done }
            
            return Success(list)
        } catch {
            print("Error getting documents: \(error)")
        }
        
        return Success([InboxItem]())
    }
    
    func deleteItem(item: InboxItem) async throws -> any Result<Bool> {
        guard let user = firebaseAuth.currentUser else {
            throw NSError(domain: "User not authenticated", code: 401, userInfo: nil)
        }
        do{
            let userRef = db.collection(user.uid).document("InboxData").collection("items").document(item.id)
            try await userRef.delete()
            return Success(true)
        } catch {
            print("Error deleting document: \(error)")
            return Failure(error)
        }
    }
    
    func clear() async throws -> any Result<Bool> {
        guard let user = firebaseAuth.currentUser else {
            throw NSError(domain: "User not authenticated", code: 401, userInfo: nil)
        }
        
        do {
            let userRef = db.collection(user.uid).document("InboxData").collection("items")
            let snapshot = try await userRef.getDocuments()
            for document in snapshot.documents {
                try await document.reference.delete()
            }
            return Success(true)
        } catch {
            print("Error clearing inbox: \(error)")
            return Failure(error)
        }
    }


    
    func addItem(item:InboxItem) async throws -> any Result<Bool> {
        guard let user = firebaseAuth.currentUser else {
            throw NSError(domain: "User not authenticated", code: 401, userInfo: nil)
        }
        
        do {
            let userRef = db.collection(user.uid).document("InboxData").collection("items").document(item.id)
            let _ = try userRef.setData(from: item)
            return Success(true)
        } catch {
            print("Error adding document: \(error)")
            return Failure(error)
        }
    }
}
