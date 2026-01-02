//
//  ViewModel.swift
//  Routine
//
//  Created by Killian Mathias on 02/01/2026.
//

import Foundation
import Combine

class ViewModel : ObservableObject{
    @Published var habits :[Habit]
    @Published var dailyHabits : [HabitDay]
    
    func addHabit(name: String, frequency : Int, objective : Int){
        habits
            .append(
                Habit(name: name, frequency: frequency, objective: objective)
            )
    }
    
    func deleteHabit(at offsets : IndexSet){
        
    }
    
    func toggleHabit(id:UUID){
        if let index = dailyHabits.firstIndex(where: {$0.id == id}){
            if dailyHabits[index].habit.objective == 1{
                dailyHabits[index].completion = Int(dailyHabits[index].completion + 1) % 2
            }
        }
    }
    
    func decrementHabit(id:UUID){
        if let index = dailyHabits.firstIndex(where: {$0.id == id}){
            if dailyHabits[index].habit.objective != 1 && dailyHabits[index].completion > 0{
                dailyHabits[index].completion -= 1
            }
        }
    }
    
    func incrementHabit(id:UUID){
        if let index = dailyHabits.firstIndex(where: {$0.id == id}){
            if dailyHabits[index].habit.objective != 1 && dailyHabits[index].completion < dailyHabits[index].habit.objective{
                dailyHabits[index].completion += 1
            }
        }
    }
    init() {
        let waterHabit = Habit(name: "Boire de l'eau", frequency: 1, objective: 1)
        let waterHabit2 = Habit(name: "Boire de l'eau", frequency: 1, objective: 10)
        self.habits = [waterHabit]
        self.dailyHabits = [
            HabitDay(habit: waterHabit, completion: 0),
            HabitDay(habit: waterHabit2, completion: 0)
        ]
    }
}
