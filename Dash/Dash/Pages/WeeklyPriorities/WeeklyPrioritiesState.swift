//
//  WeeklyPrioritiesState.swift
//  Dash
//
//  Created by Pedro Bueno on 05/07/25.
//


class WeeklyPrioritiesState {
    var weeklyData: [WeeklyItem] = []
    init(weeklyData: [WeeklyItem] = []) {
        self.weeklyData = weeklyData
    }
}

class WeeklyPrioritiesLoadingState: WeeklyPrioritiesState {
    
}

class WeeklyPrioritiesStateError: WeeklyPrioritiesState {
    let errorMessage: String
    init(weeklyData: [WeeklyItem] = [], errorMessage: String = "An error occurred") {
        self.errorMessage = errorMessage
        super.init(weeklyData: weeklyData)
    }
}

class WeeklyPrioritiesSuccess: WeeklyPrioritiesState{
    
}
