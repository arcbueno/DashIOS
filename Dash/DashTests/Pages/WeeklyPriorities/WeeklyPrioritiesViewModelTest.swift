import Testing
import Foundation
import FirebaseAuth
import FirebaseFirestore
@testable import Dash

// MARK: - Mock Repository
class MockWeeklyDataRepository: WeeklyDataRepository {
    
    init(){
        super.init(firebaseAuth: MockFirebaseAuth(), firestore: MockFirestore())
    }
    
    var shouldReturnError = false
    var mockWeeklyItems: [WeeklyItem] = []
    var addItemCalled = false
    var deleteItemCalled = false
    var lastAddedItem: WeeklyItem?
    var lastDeletedItem: WeeklyItem?
    
    override func fetchWeeklyItems() async throws -> any Result<[WeeklyItem]> {
        if shouldReturnError {
            return Failure(NSError(domain: "Test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"]))
        }
        return Success(mockWeeklyItems)
    }
    
    override func addItem(item: WeeklyItem) async throws -> any Result<Bool> {
        addItemCalled = true
        lastAddedItem = item
        if shouldReturnError {
            return Failure(NSError(domain: "Test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"]))
        }
        return Success(true)
    }
    
    override func deleteItem(item: WeeklyItem) async throws -> any Result<Bool> {
        deleteItemCalled = true
        lastDeletedItem = item
        if shouldReturnError {
            return Failure(NSError(domain: "Test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"]))
        }
        return Success(true)
    }
}

@MainActor
struct WeeklyPrioritiesViewModelTests {
    
    // MARK: - Test Data
    
    private func createSampleWeeklyItem(id: String = "test-id", title: String = "Test Item", done: Bool = false) -> WeeklyItem {
        return WeeklyItem(
            id: id,
            title: title,
            done: done,
            createdAt: Date()
        )
    }
    
    // MARK: - Get All Items Tests
    
    @Test func getAllItemsWithEmptyListSetsSuccessState() async {
        let mockRepo = MockWeeklyDataRepository()
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        
        await viewModel.getAllItems()
        
        #expect(viewModel.state is WeeklyPrioritiesSuccess)
        let successState = viewModel.state as! WeeklyPrioritiesSuccess
        #expect(successState.weeklyData.isEmpty)
    }
    
    @Test func getAllItemsWithExistingItemsSetsSuccessState() async {
        let mockRepo = MockWeeklyDataRepository()
        let items = [
            createSampleWeeklyItem(id: "item1", title: "Priority 1", done: false),
            createSampleWeeklyItem(id: "item2", title: "Priority 2", done: true)
        ]
        mockRepo.mockWeeklyItems = items
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        
        await viewModel.getAllItems()
        
        #expect(viewModel.state is WeeklyPrioritiesSuccess)
        let successState = viewModel.state as! WeeklyPrioritiesSuccess
        #expect(successState.weeklyData.count == 2)
        #expect(successState.weeklyData[0].id == "item1")
        #expect(successState.weeklyData[1].id == "item2")
    }
    
    @Test func getAllItemsWithRepositoryErrorSetsErrorState() async {
        let mockRepo = MockWeeklyDataRepository()
        mockRepo.shouldReturnError = true
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        
        await viewModel.getAllItems()
        
        #expect(viewModel.state is WeeklyPrioritiesStateError)
        let errorState = viewModel.state as! WeeklyPrioritiesStateError
        #expect(errorState.errorMessage.contains("Error"))
    }
    
    // MARK: - Add Item Tests
    
    @Test func addItemWithValidTitleCreatesNewItem() async {
        let mockRepo = MockWeeklyDataRepository()
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        
        await viewModel.addItem(title: "New Priority")
        
        #expect(mockRepo.addItemCalled)
        #expect(mockRepo.lastAddedItem?.title == "New Priority")
        #expect(mockRepo.lastAddedItem?.done == false)
        #expect(mockRepo.lastAddedItem?.id.isEmpty == false)
    }
    
    @Test func addItemWithRepositoryErrorSetsErrorState() async {
        let mockRepo = MockWeeklyDataRepository()
        mockRepo.shouldReturnError = true
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        
        await viewModel.addItem(title: "New Priority")
        
        #expect(viewModel.state is WeeklyPrioritiesStateError)
        let errorState = viewModel.state as! WeeklyPrioritiesStateError
        #expect(errorState.errorMessage.contains("Error"))
    }
    
    @Test func addItemWithEmptyTitleStillCreatesItem() async {
        let mockRepo = MockWeeklyDataRepository()
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        
        await viewModel.addItem(title: "")
        
        #expect(mockRepo.addItemCalled)
        #expect(mockRepo.lastAddedItem?.title == "")
    }
    
    // MARK: - Delete Item Tests
    
    @Test func deleteItemWithValidIdRemovesItem() async {
        let mockRepo = MockWeeklyDataRepository()
        let item = createSampleWeeklyItem(id: "item1", title: "Priority 1")
        mockRepo.mockWeeklyItems = [item]
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        await viewModel.getAllItems()
        
        await viewModel.deleteItem(id: "item1")
        
        #expect(mockRepo.deleteItemCalled)
        #expect(mockRepo.lastDeletedItem?.id == "item1")
    }
    
    @Test func deleteItemWithInvalidIdDoesNothing() async {
        let mockRepo = MockWeeklyDataRepository()
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        await viewModel.getAllItems()
        
        await viewModel.deleteItem(id: "nonexistent")
        
        #expect(mockRepo.deleteItemCalled == false)
    }
    
    @Test func deleteItemWithRepositoryErrorSetsErrorState() async {
        let mockRepo = MockWeeklyDataRepository()
        let item = createSampleWeeklyItem(id: "item1", title: "Priority 1")
        mockRepo.mockWeeklyItems = [item]
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        await viewModel.getAllItems()
        mockRepo.shouldReturnError = true
        
        await viewModel.deleteItem(id: "item1")
        
        #expect(viewModel.state is WeeklyPrioritiesStateError)
    }
    
    // MARK: - Handle Item Tap Tests
    
    @Test func handleItemTapTogglesItemDoneStatus() async {
        let mockRepo = MockWeeklyDataRepository()
        let item = createSampleWeeklyItem(id: "item1", title: "Priority 1", done: false)
        mockRepo.mockWeeklyItems = [item]
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        await viewModel.getAllItems()
        
        await viewModel.handleItemTap(id: "item1")
        
        #expect(mockRepo.addItemCalled)
        #expect(mockRepo.lastAddedItem?.id == "item1")
        #expect(mockRepo.lastAddedItem?.done == true)
    }
    
    @Test func handleItemTapWithCompletedItemTogglesBackToTodo() async {
        let mockRepo = MockWeeklyDataRepository()
        let item = createSampleWeeklyItem(id: "item1", title: "Priority 1", done: true)
        mockRepo.mockWeeklyItems = [item]
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        await viewModel.getAllItems()
        
        await viewModel.handleItemTap(id: "item1")
        
        #expect(mockRepo.addItemCalled)
        #expect(mockRepo.lastAddedItem?.done == false)
    }
    
    @Test func handleItemTapWithInvalidIdDoesNothing() async {
        let mockRepo = MockWeeklyDataRepository()
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        await viewModel.getAllItems()
        
        await viewModel.handleItemTap(id: "nonexistent")
        
        #expect(mockRepo.addItemCalled == false)
    }
    
    @Test func handleItemTapWithRepositoryErrorSetsErrorState() async {
        let mockRepo = MockWeeklyDataRepository()
        let item = createSampleWeeklyItem(id: "item1", title: "Priority 1", done: false)
        mockRepo.mockWeeklyItems = [item]
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        await viewModel.getAllItems()
        mockRepo.shouldReturnError = true
        
        await viewModel.handleItemTap(id: "item1")
        
        #expect(viewModel.state is WeeklyPrioritiesStateError)
    }
    
    // MARK: - State Management Tests
    
    @Test func initialStateIsLoading() {
        let mockRepo = MockWeeklyDataRepository()
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        
        #expect(viewModel.state is WeeklyPrioritiesLoadingState)
    }
    
    @Test func getAllItemsStartsWithLoadingState() async {
        let mockRepo = MockWeeklyDataRepository()
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        
        let loadTask = Task {
            await viewModel.getAllItems()
        }
        
        #expect(viewModel.state is WeeklyPrioritiesLoadingState)
        
        await loadTask.value
    }
    
    @Test func addItemStartsWithLoadingState() async {
        let mockRepo = MockWeeklyDataRepository()
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        
        let addTask = Task {
            await viewModel.addItem(title: "Test")
        }
        
        #expect(viewModel.state is WeeklyPrioritiesLoadingState)
        
        await addTask.value
    }
    
    // MARK: - Edge Cases
    
    @Test func getAllItemsWithMixedItems() async {
        let mockRepo = MockWeeklyDataRepository()
        let items = [
            createSampleWeeklyItem(id: "item1", title: "Priority 1", done: false),
            createSampleWeeklyItem(id: "item2", title: "Priority 2", done: true),
            createSampleWeeklyItem(id: "item3", title: "Priority 3", done: false)
        ]
        mockRepo.mockWeeklyItems = items
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        
        await viewModel.getAllItems()
        
        #expect(viewModel.state is WeeklyPrioritiesSuccess)
        let successState = viewModel.state as! WeeklyPrioritiesSuccess
        #expect(successState.weeklyData.count == 3)
        
        let todoItems = successState.weeklyData.filter { !$0.done }
        let completedItems = successState.weeklyData.filter { $0.done }
        #expect(todoItems.count == 2)
        #expect(completedItems.count == 1)
    }
    
    @Test func handleItemTapPreservesOtherItemProperties() async {
        let mockRepo = MockWeeklyDataRepository()
        let originalDate = Date()
        let item = WeeklyItem(id: "item1", title: "Priority 1", done: false, createdAt: originalDate)
        mockRepo.mockWeeklyItems = [item]
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        await viewModel.getAllItems()
        
        await viewModel.handleItemTap(id: "item1")
        
        #expect(mockRepo.lastAddedItem?.id == "item1")
        #expect(mockRepo.lastAddedItem?.title == "Priority 1")
        #expect(mockRepo.lastAddedItem?.createdAt == originalDate)
        #expect(mockRepo.lastAddedItem?.done == true)
    }
    
    @Test func deleteItemWithEmptyStateDoesNothing() async {
        let mockRepo = MockWeeklyDataRepository()
        let viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository: mockRepo)
        
        await viewModel.deleteItem(id: "item1")
        
        #expect(mockRepo.deleteItemCalled == false)
    }
}