//
//  WeeklyPrioritiesViewModel.swift
//  Dash
//
//  Created by Pedro Bueno on 01/07/25.
//


import Foundation

class WeeklyPrioritiesViewModel: ObservableObject {
    @Published var state: WeeklyPrioritiesState = WeeklyPrioritiesLoadingState()
    @Published var weeklyTitle: String = ""
    let weeklyDataRepository: WeeklyDataRepository
    
    init(weeklyDataRepository: WeeklyDataRepository) {
        self.weeklyDataRepository = weeklyDataRepository
    }
    
    func getAllItems() async {
        do {
            await MainActor.run {
                state = WeeklyPrioritiesLoadingState()
            }
            
            let result: any Result<[WeeklyItem]> = try await weeklyDataRepository.fetchWeeklyItems()
            if(result is Success<[WeeklyItem]>){
                let list = (result as! Success<[WeeklyItem]>).value
                await MainActor.run {
                    state = WeeklyPrioritiesSuccess(weeklyData: list)
                }
                
            }
            if(result is Failure<[WeeklyItem]>){
                let error = (result as! Failure<[WeeklyItem]>).error
                await MainActor.run {
                    state = WeeklyPrioritiesStateError(errorMessage: "Error: \(error)")
                }
                
            }
            
        }
        catch{
            await MainActor.run {
                state = WeeklyPrioritiesStateError(errorMessage: "Error: \(error)")
            }
        }
    }
    
    func deleteItem(id: String) async {
        if let index = (state as? WeeklyPrioritiesSuccess)?.weeklyData.firstIndex(where: { $0.id == id }) {
            let item = (state as? WeeklyPrioritiesSuccess)?.weeklyData[index]
            do {
                await MainActor.run {
                    state = WeeklyPrioritiesLoadingState()
                }
                
                let result: any Result<Bool> = try await weeklyDataRepository.deleteItem(item: item!)
                if(result is Success<Bool>){
                    await getAllItems()
                }
                if(result is Failure<Bool>){
                    let error = (result as! Failure<Bool>).error
                    await MainActor.run {
                        state = WeeklyPrioritiesStateError(errorMessage: "Error: \(error)")
                    }
                }
            }
            catch{
                
                await MainActor.run {
                    state = WeeklyPrioritiesStateError(errorMessage: "Error: \(error)")
                }
                
            }
        }
    }
    
    func addItem(title: String) async {
        let item = WeeklyItem(id: UUID().uuidString, title: title, done: false, createdAt: Date())
        do {
            await MainActor.run {
                state = WeeklyPrioritiesLoadingState()
            }
            let result: any Result<Bool> = try await weeklyDataRepository.addItem(item: item)
            if(result is Success<Bool>){
                weeklyTitle = ""
                await getAllItems()
            }
            if(result is Failure<Bool>){
                let error = (result as! Failure<Bool>).error
                await MainActor.run {
                    state = WeeklyPrioritiesStateError(errorMessage: "Error: \(error)")
                }
            }
        }
        catch{
            state = WeeklyPrioritiesStateError(errorMessage: "Error: \(error)")
        }
    }
    
    func handleItemTap(id: String)async{
        if let index = (state as? WeeklyPrioritiesSuccess)?.weeklyData.firstIndex(where: { $0.id == id }) {
            let item = (state as? WeeklyPrioritiesSuccess)?.weeklyData[index]
            let newItem = WeeklyItem(id: item!.id, title: item!.title, done: !item!.done, createdAt: item!.createdAt)
            do{
                let result: any Result<Bool> = try await weeklyDataRepository.addItem(item: newItem)
                if(result is Success<Bool>){
                    await getAllItems()
                }
                if(result is Failure<Bool>){
                    let error = (result as! Failure<Bool>).error
                    state = WeeklyPrioritiesStateError(errorMessage: "Error: \(error)")
                }
            }
            catch{
                state = WeeklyPrioritiesStateError(errorMessage: "Error: \(error)")
            }
        }
    }
}
