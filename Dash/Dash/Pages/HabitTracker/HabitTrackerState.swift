//
//  HabitTrackerState.swift
//  Dash
//
//  Created by Pedro Bueno on 05/07/25.
//

class HabitTrackerState {
    var items: [HabitItem] = []
    init(items: [HabitItem] = []) {
        self.items = items
    }
}

class HabitTrackerLoading: HabitTrackerState {
    
}

class HabitTrackerError: HabitTrackerState {
    let errorMessage: String
    init(items: [HabitItem] = [], errorMessage: String = "An error occurred") {
        self.errorMessage = errorMessage
        super.init(items: items)
    }
}

class HabitTrackerSuccess: HabitTrackerState{
    
}
