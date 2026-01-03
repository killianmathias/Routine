//
//  ViewModel.swift
//  Routine
//
//  Created by Killian Mathias on 02/01/2026.
//

import Foundation
import Combine
import CoreData

class ViewModel : ObservableObject{
    @Published var habits :[HabitEntity]
    @Published var dailyHabits : [DailyHabitEntity]
    let context : NSManagedObjectContext
    
    func addHabit(name: String, frequency : Int16, objective : Int16){
        let newHabit = HabitEntity(context: self.context)
        newHabit.name = name
        newHabit.frequency = frequency
        newHabit.objective = objective
        newHabit.id = UUID()
        habits.append(newHabit)
        addHabitForToday(habit: newHabit)
       
        try? context.save()
    }
    
    func addHabitForToday(habit:HabitEntity){
        let newDailyHabit = DailyHabitEntity(context: self.context)
        newDailyHabit.completion = 0
        newDailyHabit.id = UUID()
        newDailyHabit.habit = habit
        newDailyHabit.day = Date()
        
        dailyHabits.append(newDailyHabit)
        
        try? context.save()
    }
    
    func deleteHabit(at offsets : IndexSet){
        
    }
    
    func toggleHabit(id:UUID){
        if let index = dailyHabits.firstIndex(where: {$0.id == id}){
            if dailyHabits[index].habit!.objective == 1{
                self.objectWillChange.send()
                dailyHabits[index].completion = Int16(dailyHabits[index].completion + 1) % 2
            }
        }
        try? self.context.save()
    }
    
    func decrementHabit(id:UUID){
        if let index = dailyHabits.firstIndex(where: {$0.id == id}){
            if dailyHabits[index].habit!.objective != 1 && dailyHabits[index].completion > 0{
                self.objectWillChange.send()
                dailyHabits[index].completion -= 1
            }
        }
        try? self.context.save()
    }
    
    func incrementHabit(id:UUID){
        if let index = dailyHabits.firstIndex(where: {$0.id == id}){
            if dailyHabits[index].habit!.objective != 1 && dailyHabits[index].completion < dailyHabits[index].habit!.objective{
                self.objectWillChange.send()
                dailyHabits[index].completion += 1
            }
        }
        try? self.context.save()
    }
    
    func checkDailyHabits(){
        for habit in self.habits {
            let filteredDailyHabits = dailyHabits.filter{ $0.habit == habit }
            if(filteredDailyHabits.isEmpty){
                addHabitForToday(habit: habit)
                continue
            }
            let sortedDailyHabits = filteredDailyHabits.sorted{ $0.day! > $1.day! }
            let lastDate = sortedDailyHabits.first?.day ?? Date()
            let difference = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            
            if (difference >= habit.frequency){
                addHabitForToday(habit: habit)
            }
            
        }
    }
    init(context : NSManagedObjectContext) {
        self.context = context
        
        let habitsRequest = NSFetchRequest<HabitEntity>(entityName: "HabitEntity")
        self.habits = (try? context.fetch(habitsRequest)) ?? []
        
        let dailyHabitsRequest = NSFetchRequest<DailyHabitEntity>(
            entityName: "DailyHabitEntity"
        )
        self.dailyHabits = (try? context.fetch(dailyHabitsRequest)) ?? []
        
        checkDailyHabits()
        
    }
}
