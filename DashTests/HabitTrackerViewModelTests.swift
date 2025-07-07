import Testing
import Foundation
@testable import Dash

@MainActor
struct HabitTrackerViewModelTests {
    
    // MARK: - Mock Repository
    
    class MockHabitRepository: HabitRepository {
        var shouldReturnError = false
        var mockHabits: [HabitItem] = []
        var addItemCalled = false
        var deleteItemCalled = false
        var lastAddedItem: HabitItem?
        var lastDeletedItem: HabitItem?
        
        override func fetchAllHabits() async throws -> any Result<[HabitItem]> {
            if shouldReturnError {
                return Failure(NSError(domain: "Test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"]))
            }
            return Success(mockHabits)
        }
        
        override func addItem(item: HabitItem) async throws -> any Result<Bool> {
            addItemCalled = true
            lastAddedItem = item
            if shouldReturnError {
                return Failure(NSError(domain: "Test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"]))
            }
            return Success(true)
        }
        
        override func deleteItem(item: HabitItem) async throws -> any Result<Bool> {
            deleteItemCalled = true
            lastDeletedItem = item
            if shouldReturnError {
                return Failure(NSError(domain: "Test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"]))
            }
            return Success(true)
        }
    }
    
    // MARK: - Test Data
    
    private func createSampleHabit(id: String = "test-id", title: String = "Test Habit", records: [HabitRecord] = []) -> HabitItem {
        return HabitItem(
            id: id,
            title: title,
            createdAt: Date(),
            records: records
        )
    }
    
    private func createSampleRecord(id: String = "record-id", habitId: String = "habit-id", date: Date = Date(), done: Bool = false) -> HabitRecord {
        return HabitRecord(id: id, habitId: habitId, date: date, done: done)
    }
    
    // MARK: - Load Habits Tests
    
    @Test func loadHabitsWithEmptyListSetsSuccessState() async {
        let mockRepo = MockHabitRepository()
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        
        await viewModel.loadHabits()
        
        #expect(viewModel.state is HabitTrackerSuccess)
        #expect((viewModel.state as? HabitTrackerSuccess)?.items.isEmpty == true)
    }
    
    @Test func loadHabitsWithExistingHabitsGeneratesRecordsForCurrentWeek() async {
        let mockRepo = MockHabitRepository()
        let habit = createSampleHabit(id: "habit1", title: "Exercise")
        mockRepo.mockHabits = [habit]
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        
        await viewModel.loadHabits()
        
        #expect(viewModel.state is HabitTrackerSuccess)
        let successState = viewModel.state as! HabitTrackerSuccess
        #expect(successState.items.count == 1)
        #expect(successState.items[0].records.count == 7) // 7 days in a week
    }
    
    @Test func loadHabitsWithExistingRecordsPreservesRecords() async {
        let mockRepo = MockHabitRepository()
        let existingRecord = createSampleRecord(habitId: "habit1", date: Date(), done: true)
        let habit = createSampleHabit(id: "habit1", title: "Exercise", records: [existingRecord])
        mockRepo.mockHabits = [habit]
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        
        await viewModel.loadHabits()
        
        #expect(viewModel.state is HabitTrackerSuccess)
        let successState = viewModel.state as! HabitTrackerSuccess
        #expect(successState.items[0].records.contains { $0.done == true })
    }
    
    @Test func loadHabitsWithRepositoryErrorSetsErrorState() async {
        let mockRepo = MockHabitRepository()
        mockRepo.shouldReturnError = true
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        
        await viewModel.loadHabits()
        
        #expect(viewModel.state is HabitTrackerError)
        let errorState = viewModel.state as! HabitTrackerError
        #expect(errorState.errorMessage.contains("Error"))
    }
    
    // MARK: - Add Habit Tests
    
    @Test func addHabitWithValidTitleCreatesNewHabit() async {
        let mockRepo = MockHabitRepository()
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        
        await viewModel.addHabit(title: "New Habit")
        
        #expect(mockRepo.addItemCalled)
        #expect(mockRepo.lastAddedItem?.title == "New Habit")
        #expect(mockRepo.lastAddedItem?.id.isEmpty == false)
        #expect(mockRepo.lastAddedItem?.records.isEmpty == true)
    }
    
    @Test func addHabitWithRepositoryErrorSetsErrorState() async {
        let mockRepo = MockHabitRepository()
        mockRepo.shouldReturnError = true
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        
        await viewModel.addHabit(title: "New Habit")
        
        #expect(viewModel.state is HabitTrackerError)
        let errorState = viewModel.state as! HabitTrackerError
        #expect(errorState.errorMessage.contains("Error"))
    }
    
    @Test func addHabitWithEmptyTitleStillCreatesHabit() async {
        let mockRepo = MockHabitRepository()
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        
        await viewModel.addHabit(title: "")
        
        #expect(mockRepo.addItemCalled)
        #expect(mockRepo.lastAddedItem?.title == "")
    }
    
    // MARK: - Delete Item Tests
    
    @Test func deleteItemWithValidIdRemovesItem() async {
        let mockRepo = MockHabitRepository()
        let habit = createSampleHabit(id: "habit1", title: "Exercise")
        mockRepo.mockHabits = [habit]
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        await viewModel.loadHabits()
        
        await viewModel.deleteItem(id: "habit1")
        
        #expect(mockRepo.deleteItemCalled)
        #expect(mockRepo.lastDeletedItem?.id == "habit1")
    }
    
    @Test func deleteItemWithInvalidIdDoesNothing() async {
        let mockRepo = MockHabitRepository()
        let habit = createSampleHabit(id: "habit1", title: "Exercise")
        mockRepo.mockHabits = [habit]
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        await viewModel.loadHabits()
        
        await viewModel.deleteItem(id: "nonexistent")
        
        #expect(mockRepo.deleteItemCalled == false)
    }
    
    @Test func deleteItemWithRepositoryErrorSetsErrorState() async {
        let mockRepo = MockHabitRepository()
        let habit = createSampleHabit(id: "habit1", title: "Exercise")
        mockRepo.mockHabits = [habit]
        mockRepo.shouldReturnError = true
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        await viewModel.loadHabits()
        mockRepo.shouldReturnError = true
        
        await viewModel.deleteItem(id: "habit1")
        
        #expect(viewModel.state is HabitTrackerError)
    }
    
    // MARK: - Toggle Habit Done Tests
    
    @Test func toggleHabitDoneWithValidHabitAndDateTogglesRecord() async {
        let mockRepo = MockHabitRepository()
        let testDate = Date()
        let record = createSampleRecord(id: "record1", habitId: "habit1", date: testDate, done: false)
        let habit = createSampleHabit(id: "habit1", title: "Exercise", records: [record])
        mockRepo.mockHabits = [habit]
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        await viewModel.loadHabits()
        
        await viewModel.toggleHabitDone(id: "habit1", date: testDate)
        
        #expect(mockRepo.addItemCalled)
    }
    
    @Test func toggleHabitDoneWithInvalidHabitIdDoesNothing() async {
        let mockRepo = MockHabitRepository()
        let habit = createSampleHabit(id: "habit1", title: "Exercise")
        mockRepo.mockHabits = [habit]
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        await viewModel.loadHabits()
        
        await viewModel.toggleHabitDone(id: "nonexistent", date: Date())
        
        #expect(mockRepo.addItemCalled == false)
    }
    
    @Test func toggleHabitDoneWithRepositoryErrorSetsErrorState() async {
        let mockRepo = MockHabitRepository()
        let testDate = Date()
        let record = createSampleRecord(id: "record1", habitId: "habit1", date: testDate, done: false)
        let habit = createSampleHabit(id: "habit1", title: "Exercise", records: [record])
        mockRepo.mockHabits = [habit]
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        await viewModel.loadHabits()
        mockRepo.shouldReturnError = true
        
        await viewModel.toggleHabitDone(id: "habit1", date: testDate)
        
        #expect(viewModel.state is HabitTrackerError)
    }
    
    // MARK: - Week Text Tests
    
    @Test func getWeekTextReturnsFormattedWeekDates() {
        let mockRepo = MockHabitRepository()
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        
        let (startText, endText) = viewModel.getWeekText()
        
        #expect(startText.isEmpty == false)
        #expect(endText.isEmpty == false)
        #expect(startText.contains(","))
        #expect(endText.contains(","))
    }
    
    // MARK: - State Management Tests
    
    @Test func initialStateIsLoading() {
        let mockRepo = MockHabitRepository()
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        
        #expect(viewModel.state is HabitTrackerLoading)
    }
    
    @Test func loadHabitsStartsWithLoadingState() async {
        let mockRepo = MockHabitRepository()
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        
        let loadTask = Task {
            await viewModel.loadHabits()
        }
        
        #expect(viewModel.state is HabitTrackerLoading)
        
        await loadTask.value
    }
    
    @Test func addHabitStartsWithLoadingState() async {
        let mockRepo = MockHabitRepository()
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        
        let addTask = Task {
            await viewModel.addHabit(title: "Test")
        }
        
        #expect(viewModel.state is HabitTrackerLoading)
        
        await addTask.value
    }
    
    @Test func deleteItemStartsWithLoadingState() async {
        let mockRepo = MockHabitRepository()
        let habit = createSampleHabit(id: "habit1", title: "Exercise")
        mockRepo.mockHabits = [habit]
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        await viewModel.loadHabits()
        
        let deleteTask = Task {
            await viewModel.deleteItem(id: "habit1")
        }
        
        #expect(viewModel.state is HabitTrackerLoading)
        
        await deleteTask.value
    }
    
    // MARK: - Edge Cases
    
    @Test func loadHabitsWithMultipleHabitsHandlesAllCorrectly() async {
        let mockRepo = MockHabitRepository()
        let habits = [
            createSampleHabit(id: "habit1", title: "Exercise"),
            createSampleHabit(id: "habit2", title: "Read"),
            createSampleHabit(id: "habit3", title: "Meditate")
        ]
        mockRepo.mockHabits = habits
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        
        await viewModel.loadHabits()
        
        #expect(viewModel.state is HabitTrackerSuccess)
        let successState = viewModel.state as! HabitTrackerSuccess
        #expect(successState.items.count == 3)
        for item in successState.items {
            #expect(item.records.count == 7)
        }
    }
    
    @Test func toggleHabitDoneWithDateNotInRecordsDoesNotCrash() async {
        let mockRepo = MockHabitRepository()
        let habit = createSampleHabit(id: "habit1", title: "Exercise", records: [])
        mockRepo.mockHabits = [habit]
        let viewModel = HabitTrackerViewModel(habitTrackerRepository: mockRepo)
        await viewModel.loadHabits()
        
        let futureDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        await viewModel.toggleHabitDone(id: "habit1", date: futureDate)
        
        #expect(mockRepo.addItemCalled == false)
    }
}