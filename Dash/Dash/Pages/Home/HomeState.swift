//
//  HomeState.swift
//  Dash
//
//  Created by Pedro Bueno on 05/07/25.
//

class HomeViewModelState {
    var toDo: [InboxItem] = []
    var completed: [InboxItem] = []
    init(toDo: [InboxItem] = [], completed: [InboxItem] = []) {
        self.toDo = toDo
        self.completed = completed
    }
}

class HomeViewModelStateLoading: HomeViewModelState {
    
}
class HomeViewModelStateError: HomeViewModelState {
    let errorMessage: String
    init(toDo: [InboxItem] = [], completed: [InboxItem] = [], errorMessage: String = "An error occurred") {
        self.errorMessage = errorMessage
        super.init(toDo: toDo, completed:completed)
    }
}

class HomeViewModelSuccess: HomeViewModelState{
    
}
