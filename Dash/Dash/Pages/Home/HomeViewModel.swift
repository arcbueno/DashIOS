//
//  HomeViewModel.swift
//  Dash
//
//  Created by Pedro Bueno on 26/06/25.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var state: HomeViewModelState = HomeViewModelStateLoading()
    var inboxText: String = ""
    let inboxRepository: InboxRepository
    
    init(inboxRepository: InboxRepository) {
        self.inboxRepository = inboxRepository
    }
    
    func clear() async {
        do {
            await MainActor.run {
                state = HomeViewModelStateLoading()
            }
            
            let result: any Result<Bool> = try await inboxRepository.clear()
            if(result is Success<Bool>){
                await getAllItems()
            }
            if(result is Failure<Bool>){
                let error = (result as! Failure<Bool>).error
                await MainActor.run {
                    state = HomeViewModelStateError(errorMessage: "Error: \(error)")
                }
            }
        }
        catch{
            
            await MainActor.run {
                state = HomeViewModelStateError(errorMessage: "Error: \(error)")
            }
            
        }
    }
    
    func getAllItems() async {
        do {
            await MainActor.run {
                state = HomeViewModelStateLoading()
            }
            
            let result: any Result<[InboxItem]> = try await inboxRepository.fetchInboxItems()
            if(result is Success<[InboxItem]>){
                let list = (result as! Success<[InboxItem]>).value
               
                
                await MainActor.run {
                    let toDo = list.filter { !$0.done }
                    let completed = list.filter { $0.done }
                    inboxText = ""
                    state = HomeViewModelSuccess(toDo: toDo, completed: completed)
                }
                
            }
            if(result is Failure<[InboxItem]>){
                let error = (result as! Failure<[InboxItem]>).error
                await MainActor.run {
                    state = HomeViewModelStateError(errorMessage: "Error: \(error)")
                }
                
            }
            
        }
        catch{
            await MainActor.run {
                state = HomeViewModelStateError(errorMessage: "Error: \(error)")
            }
        }
    }
    
    func deleteItem(id: String) async {
        let tempList = ((state as? HomeViewModelSuccess)?.toDo ?? []) + ((state as? HomeViewModelSuccess)?.completed ?? [])
        if let index = tempList.firstIndex(where: { $0.id == id }) {
            let item = tempList[index]
            do {
                await MainActor.run {
                    state = HomeViewModelStateLoading()
                }
                
                let result: any Result<Bool> = try await inboxRepository.deleteItem(item: item)
                if(result is Success<Bool>){
                    await getAllItems()
                }
                if(result is Failure<Bool>){
                    let error = (result as! Failure<Bool>).error
                    await MainActor.run {
                        state = HomeViewModelStateError(errorMessage: "Error: \(error)")
                    }
                }
            }
            catch{
                
                await MainActor.run {
                    state = HomeViewModelStateError(errorMessage: "Error: \(error)")
                }
                
            }
        }
    }
    
    func addItem(title: String) async {
        let item = InboxItem(id: UUID().uuidString, title: title, done: false, createdAt: Date())
        do {
            await MainActor.run {
                state = HomeViewModelStateLoading()
            }
            let result: any Result<Bool> = try await inboxRepository.addItem(item: item)
            if(result is Success<Bool>){
                await getAllItems()
            }
            if(result is Failure<Bool>){
                let error = (result as! Failure<Bool>).error
                state = HomeViewModelStateError(errorMessage: "Error: \(error)")
            }
        }
        catch{
            state = HomeViewModelStateError(errorMessage: "Error: \(error)")
        }
    }
    
    func handleItemTap(id: String)async{
        let tempList = ((state as? HomeViewModelSuccess)?.toDo ?? []) + ((state as? HomeViewModelSuccess)?.completed ?? [])
        if let index = tempList.firstIndex(where: { $0.id == id }) {
            let item = tempList[index]
            let newItem = InboxItem(id: item.id, title: item.title, done: !item.done, createdAt: item.createdAt)
            do{
                let result: any Result<Bool> = try await inboxRepository.addItem(item: newItem)
                if(result is Success<Bool>){
                    await getAllItems()
                }
                if(result is Failure<Bool>){
                    let error = (result as! Failure<Bool>).error
                    state = HomeViewModelStateError(errorMessage: "Error: \(error)")
                }
            }
            catch{
                state = HomeViewModelStateError(errorMessage: "Error: \(error)")
            }
        }
    }
}


