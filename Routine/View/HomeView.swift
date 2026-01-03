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
    private let viewContext :NSManagedObjectContext
    @StateObject var viewModel : ViewModel
    @State private var showSheet = false
    
    init (context: NSManagedObjectContext){
        viewContext = context
        _viewModel = StateObject(wrappedValue: ViewModel(context: context))
    }
    var body: some View{
        NavigationStack{
            List(viewModel.dailyHabits){ dailyHabit in
                ZStack(alignment: .leading){
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: dailyHabit.completion < dailyHabit.habit!.objective ? 30 : 0,
                        topTrailingRadius: dailyHabit.completion < dailyHabit.habit!.objective ? 30 : 0
                    )
                    .foregroundStyle(dailyHabit.completion == dailyHabit.habit!.objective ? .green : .blue)
                        .opacity(0.4)
                        .scaleEffect(
                            x: CGFloat(dailyHabit.completion) / CGFloat(dailyHabit.habit!.objective),
                            y: 1.0,
                            anchor: .leading
                        )
                        .animation(.easeInOut, value: dailyHabit.completion)
                        .ignoresSafeArea()
                    HStack{
                        VStack(alignment: .leading){
                            Text(dailyHabit.habit!.name!)
                                .font(.headline)
                            Text(dailyHabit.habit!.frequency == 1 ? "Tous les jours" : "Autre fréquence")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
//                        Text("\(dailyHabit.completion!)")
                        Text("\(dailyHabit.completion) / \(dailyHabit.habit!.objective)")
                            .font(.caption)
                            .foregroundStyle(.red)
                        Spacer()
                        if dailyHabit.habit!.objective == 1 {
                            Button{
                                viewModel.toggleHabit(id: dailyHabit.id!)
                            }label: {
                                Image(systemName :dailyHabit.completion == 0 ? "checkmark.circle" : "checkmark.circle.fill")
                                    .foregroundStyle(
                                        dailyHabit.completion == 1 ? .green
                                        : .blue)
                            }
                            
                        }else{
                            Stepper(
                                onIncrement: {
                                    viewModel
                                        .incrementHabit(id: dailyHabit.id!)
                                    
                                },
                                onDecrement:{ viewModel.decrementHabit(id: dailyHabit.id!) }
                            ){
                                
                            }
                        }
                    }
                    .padding()
                }
                .listRowInsets(EdgeInsets())
            }
            .toolbar{
                Button{
                    showSheet = true
                }label:{
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showSheet){
                SheetView(viewModel: viewModel)
            }
            .navigationTitle("Routine")
            .listStyle(.plain)
        }
        
    }
}



#Preview {
    let context = PersistenceController.preview.container.viewContext
    HomeView(context: context)
}
