import Testing
import Foundation
import FirebaseAuth
import FirebaseFirestore
@testable import Dash

// MARK: - Mock Repository
class MockInboxRepository: InboxRepository {
    
    init(){
        super.init(firebaseAuth: MockFirebaseAuth(), firestore: MockFirestore())
    }
    
    var shouldReturnError = false
    var mockInboxItems: [InboxItem] = []
    var addItemCalled = false
    var deleteItemCalled = false
    var clearCalled = false
    var lastAddedItem: InboxItem?
    var lastDeletedItem: InboxItem?
    
    override func fetchInboxItems() async throws -> any Result<[InboxItem]> {
        if shouldReturnError {
            return Failure(NSError(domain: "Test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"]))
        }
        return Success(mockInboxItems)
    }
    
    override func addItem(item: InboxItem) async throws -> any Result<Bool> {
        addItemCalled = true
        lastAddedItem = item
        if shouldReturnError {
            return Failure(NSError(domain: "Test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"]))
        }
        return Success(true)
    }
    
    override func deleteItem(item: InboxItem) async throws -> any Result<Bool> {
        deleteItemCalled = true
        lastDeletedItem = item
        if shouldReturnError {
            return Failure(NSError(domain: "Test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"]))
        }
        return Success(true)
    }
    
    override func clear() async throws -> any Result<Bool> {
        clearCalled = true
        if shouldReturnError {
            return Failure(NSError(domain: "Test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock error"]))
        }
        return Success(true)
    }
}

@MainActor
struct HomeViewModelTests {
    
    // MARK: - Test Data
    
    private func createSampleInboxItem(id: String = "test-id", title: String = "Test Item", done: Bool = false) -> InboxItem {
        return InboxItem(
            id: id,
            title: title,
            done: done,
            createdAt: Date()
        )
    }
    
    // MARK: - Get All Items Tests
    
    @Test func getAllItemsWithEmptyListSetsSuccessState() async {
        let mockRepo = MockInboxRepository()
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        
        await viewModel.getAllItems()
        
        #expect(viewModel.state is HomeViewModelSuccess)
        let successState = viewModel.state as! HomeViewModelSuccess
        #expect(successState.toDo.isEmpty)
        #expect(successState.completed.isEmpty)
    }
    
    @Test func getAllItemsWithMixedItemsSeparatesCorrectly() async {
        let mockRepo = MockInboxRepository()
        let todoItem = createSampleInboxItem(id: "todo1", title: "Todo Item", done: false)
        let completedItem = createSampleInboxItem(id: "done1", title: "Done Item", done: true)
        mockRepo.mockInboxItems = [todoItem, completedItem]
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        
        await viewModel.getAllItems()
        
        #expect(viewModel.state is HomeViewModelSuccess)
        let successState = viewModel.state as! HomeViewModelSuccess
        #expect(successState.toDo.count == 1)
        #expect(successState.completed.count == 1)
        #expect(successState.toDo[0].id == "todo1")
        #expect(successState.completed[0].id == "done1")
    }
    
    @Test func getAllItemsWithRepositoryErrorSetsErrorState() async {
        let mockRepo = MockInboxRepository()
        mockRepo.shouldReturnError = true
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        
        await viewModel.getAllItems()
        
        #expect(viewModel.state is HomeViewModelStateError)
        let errorState = viewModel.state as! HomeViewModelStateError
        #expect(errorState.errorMessage.contains("Error"))
    }
    
    @Test func getAllItemsClearsInboxText() async {
        let mockRepo = MockInboxRepository()
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        viewModel.inboxText = "Some text"
        
        await viewModel.getAllItems()
        
        #expect(viewModel.inboxText.isEmpty)
    }
    
    // MARK: - Add Item Tests
    
    @Test func addItemWithValidTitleCreatesNewItem() async {
        let mockRepo = MockInboxRepository()
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        
        await viewModel.addItem(title: "New Item")
        
        #expect(mockRepo.addItemCalled)
        #expect(mockRepo.lastAddedItem?.title == "New Item")
        #expect(mockRepo.lastAddedItem?.done == false)
        #expect(mockRepo.lastAddedItem?.id.isEmpty == false)
    }
    
    @Test func addItemWithRepositoryErrorSetsErrorState() async {
        let mockRepo = MockInboxRepository()
        mockRepo.shouldReturnError = true
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        
        await viewModel.addItem(title: "New Item")
        
        #expect(viewModel.state is HomeViewModelStateError)
        let errorState = viewModel.state as! HomeViewModelStateError
        #expect(errorState.errorMessage.contains("Error"))
    }
    
    @Test func addItemWithEmptyTitleStillCreatesItem() async {
        let mockRepo = MockInboxRepository()
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        
        await viewModel.addItem(title: "")
        
        #expect(mockRepo.addItemCalled)
        #expect(mockRepo.lastAddedItem?.title == "")
    }
    
    // MARK: - Delete Item Tests
    
    @Test func deleteItemWithValidIdRemovesItem() async {
        let mockRepo = MockInboxRepository()
        let todoItem = createSampleInboxItem(id: "item1", title: "Item 1", done: false)
        let completedItem = createSampleInboxItem(id: "item2", title: "Item 2", done: true)
        mockRepo.mockInboxItems = [todoItem, completedItem]
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        await viewModel.getAllItems()
        
        await viewModel.deleteItem(id: "item1")
        
        #expect(mockRepo.deleteItemCalled)
        #expect(mockRepo.lastDeletedItem?.id == "item1")
    }
    
    @Test func deleteItemWithInvalidIdDoesNothing() async {
        let mockRepo = MockInboxRepository()
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        await viewModel.getAllItems()
        
        await viewModel.deleteItem(id: "nonexistent")
        
        #expect(mockRepo.deleteItemCalled == false)
    }
    
    @Test func deleteItemWithRepositoryErrorSetsErrorState() async {
        let mockRepo = MockInboxRepository()
        let item = createSampleInboxItem(id: "item1", title: "Item 1")
        mockRepo.mockInboxItems = [item]
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        await viewModel.getAllItems()
        mockRepo.shouldReturnError = true
        
        await viewModel.deleteItem(id: "item1")
        
        #expect(viewModel.state is HomeViewModelStateError)
    }
    
    // MARK: - Handle Item Tap Tests
    
    @Test func handleItemTapTogglesItemDoneStatus() async {
        let mockRepo = MockInboxRepository()
        let item = createSampleInboxItem(id: "item1", title: "Item 1", done: false)
        mockRepo.mockInboxItems = [item]
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        await viewModel.getAllItems()
        
        await viewModel.handleItemTap(id: "item1")
        
        #expect(mockRepo.addItemCalled)
        #expect(mockRepo.lastAddedItem?.id == "item1")
        #expect(mockRepo.lastAddedItem?.done == true)
    }
    
    @Test func handleItemTapWithCompletedItemTogglesBackToTodo() async {
        let mockRepo = MockInboxRepository()
        let item = createSampleInboxItem(id: "item1", title: "Item 1", done: true)
        mockRepo.mockInboxItems = [item]
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        await viewModel.getAllItems()
        
        await viewModel.handleItemTap(id: "item1")
        
        #expect(mockRepo.addItemCalled)
        #expect(mockRepo.lastAddedItem?.done == false)
    }
    
    @Test func handleItemTapWithInvalidIdDoesNothing() async {
        let mockRepo = MockInboxRepository()
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        await viewModel.getAllItems()
        
        await viewModel.handleItemTap(id: "nonexistent")
        
        #expect(mockRepo.addItemCalled == false)
    }
    
    @Test func handleItemTapWithRepositoryErrorSetsErrorState() async {
        let mockRepo = MockInboxRepository()
        let item = createSampleInboxItem(id: "item1", title: "Item 1", done: false)
        mockRepo.mockInboxItems = [item]
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        await viewModel.getAllItems()
        mockRepo.shouldReturnError = true
        
        await viewModel.handleItemTap(id: "item1")
        
        #expect(viewModel.state is HomeViewModelStateError)
    }
    
    // MARK: - Clear Tests
    
    @Test func clearWithSuccessRefreshesItems() async {
        let mockRepo = MockInboxRepository()
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        
        await viewModel.clear()
        
        #expect(mockRepo.clearCalled)
    }
    
    @Test func clearWithRepositoryErrorSetsErrorState() async {
        let mockRepo = MockInboxRepository()
        mockRepo.shouldReturnError = true
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        
        await viewModel.clear()
        
        #expect(viewModel.state is HomeViewModelStateError)
        let errorState = viewModel.state as! HomeViewModelStateError
        #expect(errorState.errorMessage.contains("Error"))
    }
    
    // MARK: - State Management Tests
    
    @Test func initialStateIsLoading() {
        let mockRepo = MockInboxRepository()
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        
        #expect(viewModel.state is HomeViewModelStateLoading)
    }
    
    @Test func getAllItemsStartsWithLoadingState() async {
        let mockRepo = MockInboxRepository()
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        
        let loadTask = Task {
            await viewModel.getAllItems()
        }
        
        #expect(viewModel.state is HomeViewModelStateLoading)
        
        await loadTask.value
    }
    
    @Test func addItemStartsWithLoadingState() async {
        let mockRepo = MockInboxRepository()
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        
        let addTask = Task {
            await viewModel.addItem(title: "Test")
        }
        
        #expect(viewModel.state is HomeViewModelStateLoading)
        
        await addTask.value
    }
    
    // MARK: - Edge Cases
    
    @Test func getAllItemsWithOnlyTodoItems() async {
        let mockRepo = MockInboxRepository()
        let items = [
            createSampleInboxItem(id: "item1", title: "Item 1", done: false),
            createSampleInboxItem(id: "item2", title: "Item 2", done: false)
        ]
        mockRepo.mockInboxItems = items
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        
        await viewModel.getAllItems()
        
        #expect(viewModel.state is HomeViewModelSuccess)
        let successState = viewModel.state as! HomeViewModelSuccess
        #expect(successState.toDo.count == 2)
        #expect(successState.completed.isEmpty)
    }
    
    @Test func getAllItemsWithOnlyCompletedItems() async {
        let mockRepo = MockInboxRepository()
        let items = [
            createSampleInboxItem(id: "item1", title: "Item 1", done: true),
            createSampleInboxItem(id: "item2", title: "Item 2", done: true)
        ]
        mockRepo.mockInboxItems = items
        let viewModel = HomeViewModel(inboxRepository: mockRepo)
        
        await viewModel.getAllItems()
        
        #expect(viewModel.state is HomeViewModelSuccess)
        let successState = viewModel.state as! HomeViewModelSuccess
        #expect(successState.toDo.isEmpty)
        #expect(successState.completed.count == 2)
    }
}