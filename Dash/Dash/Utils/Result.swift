//
//  Result.swift
//  Dash
//
//  Created by Pedro Bueno on 28/06/25.
//

protocol Result<T> {
    associatedtype T
}

struct Success<T> : Result {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}

struct Failure<T> : Result {
    let error: Error
    
    init(_ error: Error) {
        self.error = error
    }

}




