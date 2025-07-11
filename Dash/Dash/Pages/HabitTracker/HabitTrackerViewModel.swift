//
//  HabitTrackerViewModel.swift
//  Dash
//
//  Created by Pedro Bueno on 02/07/25.
//

import Foundation

class HabitTrackerViewModel: ObservableObject{
    @Published var state: HabitTrackerState = HabitTrackerLoading()
    var inboxText: String = ""
    let habitTrackerRepository: HabitRepository
    
    init(habitTrackerRepository: HabitRepository) {
        self.habitTrackerRepository = habitTrackerRepository
    }
    
    private func getCurrentPeriod() -> (Date, Date) {
        let dates:(Date?, Date?)? = Calendar(identifier: .gregorian).currentWeekBoundary()
        let startOfWeek = dates?.0 ?? Date()
        let endOfWeek = dates?.1 ?? Date()
        return (startOfWeek, endOfWeek)
    }
    
    private func getAllDatesFromPeriod(start: Date, end: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = start
        while currentDate <= end {
            dates.append(currentDate)
            if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        return dates
    }
    
    func deleteItem(id: String) async {
        if let index = (state as? HabitTrackerSuccess)?.items.firstIndex(where: { $0.id == id }) {
            let item = (state as? HabitTrackerSuccess)?.items[index]
            do {
                await MainActor.run {
                    state = HabitTrackerLoading()
                }
                
                let result: any Result<Bool> = try await habitTrackerRepository.deleteItem(item: item!)
                if(result is Success<Bool>){
                    await loadHabits()
                }
                if(result is Failure<Bool>){
                    let error = (result as! Failure<Bool>).error
                    await MainActor.run {
                        state = HabitTrackerError(errorMessage: "Error: \(error)")
                    }
                }
            }
            catch{
                
                await MainActor.run {
                    state = HabitTrackerError(errorMessage: "Error: \(error)")
                }
                
            }
        }
    }
    
    
    func getWeekText() -> (String, String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d"
        let (startOfWeek, endOfWeek) = getCurrentPeriod()
        return (dateFormatter.string(from: startOfWeek), dateFormatter.string(from: endOfWeek))
    }
    
    func loadHabits() async {
        do {
            await MainActor.run {
                state = HabitTrackerLoading()
            }
            let result: any Result<[HabitItem]> = try await habitTrackerRepository.fetchAllHabits()
            if(result is Success<[HabitItem]>){
                let serverList:[HabitItem] = (result as! Success<[HabitItem]>).value
                await MainActor.run {
                    var list: [HabitItem] = []
                    for var item in serverList {
                        if(item.records.isEmpty){
                            // Generate records for the current period
                            let dates = getAllDatesFromPeriod(start: getCurrentPeriod().0, end: getCurrentPeriod().1)
                            for date in dates {
                                let newRecord = HabitRecord(id: UUID().uuidString, habitId: item.id, date: date, done: false)
                                item.records.append(newRecord)
                            }
                        }
                        else {
                            // Ensure all dates in the current period have a record
                            for record in item.records{
                                if(getAllDatesFromPeriod(start: getCurrentPeriod().0, end: getCurrentPeriod().1).contains(record.date) == false){
                                    let newRecord = HabitRecord(id: UUID().uuidString, habitId: item.id, date: record.date, done: false)
                                    item.records.append(newRecord)
                                }
                            }
                        }
                        list.append(item)
                    }
                    state = HabitTrackerSuccess(items: list)
                }
            }
            if(result is Failure<[WeeklyItem]>){
                let error = (result as! Failure<[HabitItem]>).error
                await MainActor.run {
                    state = HabitTrackerError(errorMessage: "Error: \(error)")
                }
            }
        }
        catch{
            await MainActor.run {
                state = HabitTrackerError(errorMessage: "Error: \(error)")
            }
        }
    }
    
    func toggleHabitDone(id: String, date: Date) async {
        if let index = (state as? HabitTrackerSuccess)?.items.firstIndex(where: { $0.id == id }) {
            let item = (state as? HabitTrackerSuccess)?.items[index]
            do {
                await MainActor.run {
                    state = HabitTrackerLoading()
                }
                var habitItem = item!
                if let record:HabitRecord = habitItem.records.first(where: { $0.date == date }) {
                    let newRecord = HabitRecord(id: record.id, habitId: record.habitId, date: record.date, done: !record.done)
                    let recordIndex = habitItem.records.firstIndex(where: { $0.id == record.id }) ?? 0
                    habitItem.records[recordIndex] = newRecord
                    let result: any Result<Bool> = try await habitTrackerRepository.addItem(item: habitItem)
                    
                    if(result is Failure<Bool>){
                        let error = (result as! Failure<Bool>).error
                        await MainActor.run {
                            state = HabitTrackerError(errorMessage: "Error: \(error)")
                        }
                        return
                    }
                }
                await loadHabits()
            }
            catch {
                await MainActor.run {
                    state = HabitTrackerError(errorMessage: "Error: \(error)")
                }
            }
        }
        
    }
    
    func addHabit(title: String) async {
        do{
            await MainActor.run {
                state = HabitTrackerLoading()
            }
            let newHabit = HabitItem(
                id: UUID().uuidString, title: title, createdAt: Date(), records: []
            )
            let result: any Result<Bool> = try await habitTrackerRepository.addItem(item: newHabit)
            if(result is Success<Bool>){
                inboxText = ""
                await loadHabits()
            }
            if(result is Failure<Bool>){
                let error = (result as! Failure<Bool>).error
                await MainActor.run {
                    state = HabitTrackerError(errorMessage: "Error: \(error)")
                }
            }
        }
        catch{
            await MainActor.run {
                state = HabitTrackerError(errorMessage: "Error: \(error)")
            }
        }
        
    }
    
}


