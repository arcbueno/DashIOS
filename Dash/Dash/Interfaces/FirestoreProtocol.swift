//
//  FirestoreProtocol.swift
//  Dash
//
//  Created by Pedro Bueno on 07/07/25.
//

import FirebaseFirestore

protocol FirestoreProtocol {
    func collection(_ collectionID: String) -> CollectionReference
}

extension Firestore: FirestoreProtocol {}
