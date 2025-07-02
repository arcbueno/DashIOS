//
//  WeeklyPrioritiesPage.swift
//  Dash
//
//  Created by Pedro Bueno on 25/06/25.
//

import SwiftUI

struct WeeklyPrioritiesPage: View {
    @StateObject private var viewModel = WeeklyPrioritiesViewModel(weeklyDataRepository:Injection.shared.container.resolve(WeeklyDataRepository.self)!)
    @Environment(\.dismiss) private var dismiss
    
    var appController: AppController
    
    init(appController: AppController){
        self.appController = appController
    }
    
    
    // Tela de prioridades da semana com dois botões: habit tracker e weekly planner.
    var body: some View {
        
        NavigationView() {
            ZStack {
                VStack {
                    VStack(alignment: .leading){
                        Text("Weekly\nPriorities")
                            .font(.system(size: 42))
                            .fontWeight(.semibold)
                        
                        List {
                            ForEach(viewModel.state.weeklyData, id: \.self) { item in
                                HStack{
                                    Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 24))
                                        .foregroundColor(item.done ? Color(.darkGray) : .gray)
                                    
                                    Text(item.title)
                                        .font(.system(size: 24))
                                    Spacer()
                                    Image(systemName:  "trash")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(.darkGray))
                                        .onTapGesture{
                                            Task {
                                                await viewModel.deleteItem(id: item.id)
                                            }
                                        }
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
                            TextField("Add task", text: $viewModel.weeklyTitle, prompt: Text("Add task").foregroundColor(.gray))
                                .font(.system(size: 24))
                                .disableAutocorrection(true)
                            
                            Button(action: {
                                Task {
                                    if(viewModel.weeklyTitle.isEmpty) {
                                        return
                                    }
                                    await viewModel.addItem(title: viewModel.weeklyTitle)
                                    viewModel.weeklyTitle = ""
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color(.darkGray))
                            }
                        }.padding()
                        
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    
                        
                }
                .padding()
                if($viewModel.state.wrappedValue is WeeklyPrioritiesLoadingState) {
                    ProgressView("Loading...")
                }
            }
            .onAppear{
                Task {
                    await viewModel.getAllItems()
                }
            }
        }
        .navigationBarItems(leading: btnBack)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {

            ToolbarItem(placement: .principal) {
                Text("Dash")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding()
                
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    Task {
                        await viewModel.getAllItems()
                    }
                }) {
                    HStack{
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 24))
                            .foregroundColor(Color(.darkGray))
                    }
                }
            }
        }
        
    }
    
    var btnBack : some View {
        Button(action: {
            dismiss()
        }) {
            Image("arrow.backward")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
                .background(.black)
                .padding()
            
        }
    }
}

#Preview {
    HomePage(appController: AppController())
}
