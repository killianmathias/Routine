//
//  HomeView.swift
//  Routine
//
//  Created by Killian Mathias on 02/01/2026.
//

import Foundation
import SwiftUI
import CoreData

struct HomeView: View {
    private let viewContext: NSManagedObjectContext
    @StateObject var viewModel: ViewModel
    @State private var showSheet = false
    
    init(context: NSManagedObjectContext) {
        viewContext = context
        _viewModel = StateObject(wrappedValue: ViewModel(context: context))
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.dailyHabits) { dailyHabit in
                    if let habit = dailyHabit.habit {
                        
                        ZStack(alignment: .leading) {
                            NavigationLink(destination: HabitView(habit: habit, viewModel: viewModel)) {
                                EmptyView()
                            }
                            .opacity(0)
                            
                            UnevenRoundedRectangle(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 0,
                                bottomTrailingRadius: dailyHabit.completion < habit.objective ? 30 : 0,
                                topTrailingRadius: dailyHabit.completion < habit.objective ? 30 : 0
                            )
                            .foregroundStyle(dailyHabit.completion >= habit.objective ? .green : .blue)
                            .opacity(0.4)
                            .scaleEffect(
                                x: CGFloat(dailyHabit.completion) / CGFloat(habit.objective),
                                y: 1.0,
                                anchor: .leading
                            )
                            .animation(.easeInOut, value: dailyHabit.completion)
                            .ignoresSafeArea()
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(habit.name ?? "Inconnu")
                                        .font(.headline)
                                    
                                    Text(habit.frequency == 1 ? "Tous les jours" : "Autre fréquence")
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                }
                                
                                Spacer()
                                
                                Text("\(dailyHabit.completion.formatted()) / \(habit.objective.formatted()) \(habit.computedUnit.rawValue)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                if habit.computedType == .boolean {
                                    Button {
                                        viewModel.toggleHabit(id: dailyHabit.id!)
                                    } label: {
                                        Image(systemName: dailyHabit.completion == 0 ? "circle" : "checkmark.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(dailyHabit.completion >= 1 ? .green : .blue)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    Stepper(
                                        "Progression",
                                        onIncrement: {
                                            viewModel.incrementHabit(id: dailyHabit.id!)
                                        },
                                        onDecrement: {
                                            viewModel.decrementHabit(id: dailyHabit.id!)
                                        }
                                    )
                                    .labelsHidden()
                                }
                            }
                            .padding()
                        }
                        .listRowInsets(EdgeInsets())
                    }
                }
                .onDelete(perform: deleteDailyHabit)
            }
            .toolbar {
                Button {
                    showSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showSheet) {
                SheetView(viewModel: viewModel)
            }
            .navigationTitle("Routine")
            .listStyle(.plain)
        }
    }
    
    private func deleteDailyHabit(at offsets: IndexSet) {
        offsets.forEach { index in
            let dailyHabit = viewModel.dailyHabits[index]
            if let habitToDelete = dailyHabit.habit {
                if let indexInMainList = viewModel.habits.firstIndex(of: habitToDelete) {
                    viewModel.deleteHabit(at: IndexSet(integer: indexInMainList))
                }
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    HomeView(context: context)
}
