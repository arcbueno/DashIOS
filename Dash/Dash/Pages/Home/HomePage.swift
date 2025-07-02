//
//  HomePage.swift
//  Dash
//
//  Created by Pedro Bueno on 25/06/25.
//

import SwiftUI

struct HomePage: View {
    @StateObject private var viewModel = HomeViewModel(inboxRepository:Injection.shared.container.resolve(InboxRepository.self)!)
    
    var appController: AppController
    
    init(appController: AppController){
        self.appController = appController
    }
    
    var body: some View {
        
        NavigationView() {
            ZStack {
                VStack {
                    VStack(alignment: .leading){
                        HStack{
                            Text("Inbox")
                                .font(.system(size: 42))
                                .fontWeight(.semibold)
                            Spacer()
                            Button(action: {
                                Task {
                                    await viewModel.clear()
                                }
                            }) {
                                Text("Clear")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(.darkGray))
                            }
                        }
                        HStack{
                            TextField("Add to inbox", text: $viewModel.inboxText, prompt: Text("Add to inbox").foregroundColor(Color(.darkGray)))
                                .font(.system(size: 32))
                            
                            Button(action: {
                                Task {
                                    if(viewModel.inboxText.isEmpty) {
                                        return
                                    }
                                    await viewModel.addItem(title: viewModel.inboxText)
                                    viewModel.inboxText = ""
                                }
                            }) {
                                Image(systemName: "arrow.forward")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(.darkGray))
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        if(viewModel.state.toDo.isEmpty) {
                            Text("Your inbox is empty")
                                .font(.system(size: 24))
                                .foregroundColor(Color(.darkGray))
                                .padding()
                        }
                        if(!viewModel.state.toDo.isEmpty){
                            Text("To process")
                                .font(.system(size: 24))
                                .foregroundColor(Color(.darkGray))
                                .padding()
                        }
                        List {
                            ForEach(viewModel.state.toDo, id: \.self) { item in
                                HStack{
                                    Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 24))
                                        .foregroundColor(item.done ? Color(.darkGray) : .gray)
                                    
                                    Text(item.title)
                                        .font(.system(size: 24))
                                }
                                .onTapGesture {
                                    Task{
                                        await viewModel.handleItemTap(id: item.id)
                                    }
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                        .background(.clear)
                        if(!viewModel.state.completed.isEmpty){
                            Text("Processed")
                                .font(.system(size: 24))
                                .foregroundColor(Color(.darkGray))
                                .padding(.leading, 16)
                        }
                        List {
                            ForEach(viewModel.state.completed, id: \.self) { item in
                                HStack{
                                    Image(systemName:"checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(.darkGray))
                                    
                                    Text(item.title)
                                        .font(.system(size: 24))
                                        .foregroundStyle(Color(.darkGray))
                                        .strikethrough(true, color: Color(.darkGray))
                                }
                                .onTapGesture {
                                    Task{
                                        await viewModel.handleItemTap(id: item.id)
                                    }
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                        .background(.clear)
                        
                        HStack{
                            NavigationLink(destination:WeeklyPrioritiesPage(appController: self.appController) ){
                                Text("Habit tracker")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.darkGray))
                                    .cornerRadius(99)
                            }
                            NavigationLink(destination: WeeklyPrioritiesPage(appController: self.appController)) {
                                Text("Priorities")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.darkGray))
                                    .cornerRadius(99)
                            }
                            
                        }
                        
                        
                    }.frame(maxWidth: .infinity, alignment: .leading)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("Dash")
                                    .font(.largeTitle)
                                    .fontWeight(.semibold)
                                    .padding()
                                
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    Task {
                                        await viewModel.getAllItems()
                                    }
                                }) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(.darkGray))
                                }
                            }
                            
                        }
                    
                    
                }
                .padding()
                if($viewModel.state.wrappedValue is HomeViewModelStateLoading) {
                    ProgressView("Loading...")
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear{
            Task {
                await viewModel.getAllItems()
            }
        }
        
    }
}

#Preview {
    HomePage(appController: AppController())
}
