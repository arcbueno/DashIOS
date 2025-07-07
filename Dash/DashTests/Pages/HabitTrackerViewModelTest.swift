//
//  HabitTrackerViewModelTest.swift
//  Dash
//
//  Created by Pedro Bueno on 07/07/25.
//

import Testing
import protocol Dash.Result
@testable import Dash

@Suite("HabitTrackerViewModel Tests")
struct HabitTrackerViewModelTests {
    
    class MockHabitRepository: HabitRepository {
        
        init(){}
        
        var fetchAllHabitsResult: any Result<[HabitItem]>
        var addItemResult: any Result<Bool>
        var deleteItemResult: any Result<Bool>
        var lastAddedItem: HabitItem?
        var lastDeletedItem: HabitItem?
        
        override func fetchAllHabits() async throws -> any Result<[HabitItem]> {
            switch fetchAllHabitsResult {
            case .success(let items): return Success(items)
            case .failure(let error): return Failure(error)
            }
        }
        
        override func addItem(item: HabitItem) async throws -> any Result<Bool> {
            lastAddedItem = item
            switch addItemResult {
            case .success(let value): return Success(value: value)
            case .failure(let error): return Failure(error: error)
            case .none: return Success(value: true)
            }
        }
        
        @Test("loads habits successfully")
        func loadsHabitsSuccessfully() async {
            let mockRepo = MockHabitRepository()
            let items = [habitItemWithRecords()]
            mockRepo.fetchAllHabitsResult = .success(items)
            let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
            
            await viewModel.loadHabits()
            
            #expect(viewModel.state is HabitTrackerSuccess)
            #expect((viewModel.state as? HabitTrackerSuccess)?.items.count == 1)
        }
        
        @Test("handles load habits failure")
        func handlesLoadHabitsFailure() async {
            let mockRepo = MockHabitRepository()
            mockRepo.fetchAllHabitsResult = .failure(NSError(domain: "Test", code: 1))
            let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
            
            await viewModel.loadHabits()
            
            #expect(viewModel.state is HabitTrackerError)
        }
        
        @Test("generates records for habits with empty records")
        func generatesRecordsForHabitsWithEmptyRecords() async {
            let mockRepo = MockHabitRepository()
            let item = habitItemWithRecords(records: [])
            mockRepo.fetchAllHabitsResult = .success([item])
            let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
            
            await viewModel.loadHabits()
            
            let loadedItems = (viewModel.state as? HabitTrackerSuccess)?.items
            #expect(loadedItems != nil)
            #expect(!(loadedItems?.first?.records.isEmpty ?? true))
        }
        
        @Test("adds habit successfully")
        func addsHabitSuccessfully() async {
            let mockRepo = MockHabitRepository()
            mockRepo.addItemResult = .success(true)
            mockRepo.fetchAllHabitsResult = .success([])
            let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
            
            await viewModel.addHabit(title: "New Habit")
            
            #expect(viewModel.state is HabitTrackerSuccess)
            #expect(mockRepo.lastAddedItem?.title == "New Habit")
        }
        
        @Test("handles add habit failure")
        func handlesAddHabitFailure() async {
            let mockRepo = MockHabitRepository()
            mockRepo.addItemResult = .failure(NSError(domain: "Test", code: 2))
            let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
            
            await viewModel.addHabit(title: "Fail Habit")
            
            #expect(viewModel.state is HabitTrackerError)
        }
        
        @Test("adds habit with empty title")
        func addsHabitWithEmptyTitle() async {
            let mockRepo = MockHabitRepository()
            mockRepo.addItemResult = .success(true)
            mockRepo.fetchAllHabitsResult = .success([])
            let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
            
            await viewModel.addHabit(title: "")
            
            #expect(viewModel.state is HabitTrackerSuccess)
            #expect(mockRepo.lastAddedItem?.title == "")
        }
        
        @Test("deletes habit successfully")
        func deletesHabitSuccessfully() async {
            let mockRepo = MockHabitRepository()
            let item = habitItemWithRecords()
            mockRepo.fetchAllHabitsResult = .success([item])
            mockRepo.deleteItemResult = .success(true)
            let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
            await viewModel.loadHabits()
            
            await viewModel.deleteItem(id: item.id)
            
            #expect(mockRepo.lastDeletedItem?.id == item.id)
        }
        
        @Test("handles delete habit failure")
        func handlesDeleteHabitFailure() async {
            let mockRepo = MockHabitRepository()
            let item = habitItemWithRecords()
            mockRepo.fetchAllHabitsResult = .success([item])
            mockRepo.deleteItemResult = .failure(NSError(domain: "Test", code: 3))
            let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
            await viewModel.loadHabits()
            
            await viewModel.deleteItem(id: item.id)
            
            #expect(viewModel.state is HabitTrackerError)
        }
        
        @Test("delete item with invalid id does nothing")
        func deleteItemWithInvalidIdDoesNothing() async {
            let mockRepo = MockHabitRepository()
            let item = habitItemWithRecords()
            mockRepo.fetchAllHabitsResult = .success([item])
            let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
            await viewModel.loadHabits()
            
            await viewModel.deleteItem(id: "nonexistent")
            
            #expect(viewModel.state is HabitTrackerSuccess)
            #expect(mockRepo.lastDeletedItem == nil)
        }
        
        @Test("toggles habit done successfully")
        func togglesHabitDoneSuccessfully() async {
            let mockRepo = MockHabitRepository()
            let date = Date()
            let record = habitRecord(date: date, done: false)
            let item = habitItemWithRecords(records: [record])
            mockRepo.fetchAllHabitsResult = .success([item])
            mockRepo.addItemResult = .success(true)
            let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
            await viewModel.loadHabits()
            
            await viewModel.toggleHabitDone(id: item.id, date: date)
            
            #expect(viewModel.state is HabitTrackerSuccess)
            #expect(mockRepo.lastAddedItem?.records.first?.done == true)
        }
        
        @Test("handles toggle habit done failure")
        func handlesToggleHabitDoneFailure() async {
            let mockRepo = MockHabitRepository()
            let date = Date()
            let record = habitRecord(date: date, done: false)
            let item = habitItemWithRecords(records: [record])
            mockRepo.fetchAllHabitsResult = .success([item])
            mockRepo.addItemResult = .failure(NSError(domain: "Test", code: 4))
            let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
            await viewModel.loadHabits()
            
            await viewModel.toggleHabitDone(id: item.id, date: date)
            
            #expect(viewModel.state is HabitTrackerError)
        }
        
        @Test("toggle habit done with invalid id does nothing")
        func toggleHabitDoneWithInvalidIdDoesNothing() async {
            let mockRepo = MockHabitRepository()
            let item = habitItemWithRecords()
            mockRepo.fetchAllHabitsResult = .success([item])
            let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
            await viewModel.loadHabits()
            
            await viewModel.toggleHabitDone(id: "invalid", date: Date())
            
            #expect(viewModel.state is HabitTrackerSuccess)
            #expect(mockRepo.lastAddedItem == nil)
        }
        
        @Test("toggle habit done with non matching date does nothing")
        func toggleHabitDoneWithNonMatchingDateDoesNothing() async {
            let mockRepo = MockHabitRepository()
            let record = habitRecord(date: Date(), done: false)
            let item = habitItemWithRecords(records: [record])
            mockRepo.fetchAllHabitsResult = .success([item])
            let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
            await viewModel.loadHabits()
            
            await viewModel.toggleHabitDone(id: item.id, date: Date.distantPast)
            
            #expect(viewModel.state is HabitTrackerSuccess)
            #expect(mockRepo.lastAddedItem == nil)
        }
        
        @Test("get week text returns formatted dates")
        func getWeekTextReturnsFormattedDates() {
            let mockRepo = MockHabitRepository()
            let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
            
            let (start, end) = viewModel.getWeekText()
            
            #expect(!start.isEmpty)
            #expect(!end.isEmpty)
            #expect(start.contains(","))
            #expect(end.contains(","))
        }
        
        @Test("initial state is loading")
        func initialStateIsLoading() {
            let mockRepo = MockHabitRepository()
            let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
            
            #expect(viewModel.state is HabitTrackerLoading)
        }
        
        @Test("inbox text initializes as empty")
        func inboxTextInitializesAsEmpty() {
            let mockRepo = MockHabitRepository()
            let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
            
            #expect(viewModel.inboxText.isEmpty)
        }
    }
    
