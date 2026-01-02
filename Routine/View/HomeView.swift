//
//  HomeView.swift
//  Routine
//
//  Created by Killian Mathias on 02/01/2026.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = ViewModel()
    var body: some View{
        List(viewModel.dailyHabits){ dailyHabit in
            ZStack(alignment: .leading){
                Color.blue
                    .opacity(0.4)
                    .frame(maxHeight:.infinity)
                    .containerRelativeFrame(.horizontal){
         size,
                        axis in
                        size * (
                            Double(dailyHabit.completion) / Double(dailyHabit.habit.objective)
                        )
                    }
                    .animation(.easeInOut, value: dailyHabit.completion)
                HStack{
                    VStack{
                        Text(dailyHabit.habit.name)
                            .font(.headline)
                        Text(dailyHabit.habit.frequency == 1 ? "Tous les jours" : "Autre fréquence")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                    if dailyHabit.habit.objective == 1 {
                        Button{
                            viewModel.toggleHabit(id: dailyHabit.id)
                        }label: {
                            Image(systemName :dailyHabit.completion == 0 ? "checkmark.circle" : "checkmark.circle.fill")
                                .foregroundStyle(
                                    dailyHabit.completion == 1 ? .green
                                    : .blue)
                        }
                        
                    }else{
                        Stepper(
                            onIncrement: {viewModel.incrementHabit(id: dailyHabit.id) },
                            onDecrement:{ viewModel.decrementHabit(id: dailyHabit.id)}
                        ){
                            
                        }
                    }
                }
                
            }
        }
    }
}



#Preview {
    HomeView()
}
