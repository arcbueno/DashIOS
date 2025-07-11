//
//  HabitTrackerPage.swift
//  Dash
//
//  Created by Pedro Bueno on 02/07/25.
//

import SwiftUI

struct HabitTrackerPage: View {
    @StateObject private var viewModel = HabitTrackerViewModel(habitTrackerRepository:Injection.shared.container.resolve(HabitRepository.self)!)
    
    var appController: AppController
    
    init(appController: AppController){
        self.appController = appController
    }
    
    
    var body: some View {
        NavigationView() {
            ZStack {
                GeometryReader { geometry in
                    VStack(){
                        VStack(alignment: .leading){
                            Text("Habit Tracker")
                                .font(.system(size: 42))
                                .fontWeight(.semibold)
                            VStack(){
                                HStack{
                                    Text(viewModel.getWeekText().0)
                                        .padding()
                                        .frame(alignment: .center)
                                    Spacer()
                                    Text("to")
                                        .padding()
                                        .frame(alignment: .center)
                                    Spacer()
                                    Text(viewModel.getWeekText().1)
                                        .padding()
                                        .frame(alignment: .center)
                                }
                                if(viewModel.state.items.isEmpty) {
                                    Text("No habits found")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(.darkGray))
                                        .padding()
                                }
                                else {
                                    Grid(alignment: .leading,horizontalSpacing: 10, verticalSpacing: 10){
                                        GridRow(alignment: .top){
                                            Text("Habits")
                                                .font(.system(size: 24))
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(.darkGray))
                                                .frame(alignment:.leading)
                                                .gridCellAnchor(.init(x: 0.20, y: 0.0))
                                            Text("Sun")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(.darkGray))
                                            Text("Mon")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(.darkGray))
                                            Text("Tue")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(.darkGray))
                                            Text("Wed")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(.darkGray))
                                            Text("Thu")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(.darkGray))
                                            Text("Fri")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(.darkGray))
                                            Text("Sat")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color(.darkGray))
                                        }
                                        .gridCellUnsizedAxes([.vertical])
                                        
                                        Divider()
                                            .gridCellUnsizedAxes(.horizontal)
                                        ForEach(viewModel.state.items, id: \.self) { item in
                                            GridRow{
                                                Text(item.title)
                                                    .font(.system(size: 20))
                                                    .foregroundColor(Color(.darkGray))
                                                    .lineLimit(3)
                                                    .gridCellAnchor(.init(x: 0.20, y: 0.1))
                                                ForEach(item.records, id: \.self) { record in
                                                    Image(systemName: record.done ? "checkmark.circle.fill" : "circle")
                                                        .font(.system(size: 24))
                                                        .foregroundColor(record.done ? Color(.darkGray) : .gray)
                                                        .onTapGesture {
                                                            Task {
                                                                await viewModel.toggleHabitDone(id: item.id, date: record.date)
                                                            }
                                                            
                                                        }
                                                }
                                                
                                            }
                                            .contextMenu {
                                                Button{
                                                    Task {
                                                        await viewModel.deleteItem(id: item.id)
                                                    }
                                                } label: {
                                                    Label("Delete habit", systemImage: "trash")
                                                }
                                            }
//                                            .gridCellUnsizedAxes([.vertical])
                                        }
                                        .listRowInsets(.init())
                                        
                                    }
                                }
                                
                                Spacer()
                                HStack{
                                    TextField("Add habit", text: $viewModel.inboxText, prompt: Text("Add habit").foregroundColor(.gray))
                                        .font(.system(size: 24))
                                    
                                    Button(action: {
                                        Task {
                                            if(viewModel.inboxText.isEmpty) {
                                                return
                                            }
                                            await viewModel.addHabit(title: viewModel.inboxText)
                                            viewModel.inboxText = ""
                                        }
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(Color(.darkGray))
                                    }
                                }.padding()
                                
                                
                                
                            }
                            
                        }
                        .frame(maxWidth: geometry.size.width, alignment: .leading)
                    }
                    .padding()
                }
                if($viewModel.state.wrappedValue is HabitTrackerLoading) {
                    ProgressView("Loading...")
                }
            }
            .onAppear{
                Task {
                    await viewModel.loadHabits()
                }
            }
            
        }
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
                        await viewModel.loadHabits()
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
}

#Preview {
    HabitTrackerPage(appController: AppController())
}


//                .navigationViewStyle(StackNavigationViewStyle())
