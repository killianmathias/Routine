//
//  ViewModel.swift
//  Routine
//
//  Created by Killian Mathias on 02/01/2026.
//

import Foundation
import Combine
import CoreData
import SwiftUI

class ViewModel: ObservableObject {
    @Published var habits: [HabitEntity]
    @Published var dailyHabits: [DailyHabitEntity]
    let context: NSManagedObjectContext
    func addHabit(
        name: String,
        frequency: Int16,
        objective: Double,
        type: Type,
        unit: Unit,
        reminderDate : Date?
    ) {
        let newHabit = HabitEntity(context: self.context)
        newHabit.name = name
        newHabit.frequency = frequency
        newHabit.objective = objective
        newHabit.id = UUID()
        newHabit.type = type.rawValue
        newHabit.unit = unit.rawValue
        newHabit.reminderDate = reminderDate
        
        habits.append(newHabit)
        addHabitForToday(habit: newHabit)
        
        try? context.save()
        
        if reminderDate != nil{
            scheduleNotification(for: newHabit)
        }
    }
    
    func addHabitForToday(habit: HabitEntity) {
        let newDailyHabit = DailyHabitEntity(context: self.context)
        newDailyHabit.completion = 0.0
        newDailyHabit.id = UUID()
        newDailyHabit.habit = habit
        newDailyHabit.day = Date()
        
        dailyHabits.append(newDailyHabit)
        
        try? context.save()
    }
    
    func deleteHabit(at offsets: IndexSet) {
        offsets.forEach { index in
            let habit = habits[index]
            context.delete(habit)
            let relatedDailyHabits = dailyHabits.filter { $0.habit == habit }
            relatedDailyHabits.forEach { context.delete($0) }

            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habit.id?.uuidString ?? ""])
        }
    
        habits.remove(atOffsets: offsets)
        
        try? context.save()
        
        let dailyHabitsRequest = NSFetchRequest<DailyHabitEntity>(entityName: "DailyHabitEntity")
        self.dailyHabits = (try? context.fetch(dailyHabitsRequest)) ?? []
    }
    
    func toggleHabit(id: UUID) {
        if let index = dailyHabits.firstIndex(where: { $0.id == id }) {
            
            if dailyHabits[index].habit?.computedType == .boolean {
                self.objectWillChange.send()
                
                if dailyHabits[index].completion == 0 {
                    dailyHabits[index].completion = 1.0
                } else {
                    dailyHabits[index].completion = 0.0
                }
            }
            
            if let habit = dailyHabits[index].habit {
                updateSmartNotification(
                    for: habit,
                    completion: dailyHabits[index].completion,
                    objective: habit.objective
                )
            }
        }
        try? self.context.save()
    }
    
    func decrementHabit(id: UUID) {
        if let index = dailyHabits.firstIndex(where: { $0.id == id }) {
            let step = dailyHabits[index].habit?.computedUnit.defaultStep ?? 1.0
            
            if dailyHabits[index].completion > 0 {
                self.objectWillChange.send()
                dailyHabits[index].completion -= step
                
                if dailyHabits[index].completion < 0 { dailyHabits[index].completion = 0 }
            }
            
            if let habit = dailyHabits[index].habit {
                updateSmartNotification(
                    for: habit,
                    completion: dailyHabits[index].completion,
                    objective: habit.objective
                )
            }
        }
        try? self.context.save()
    }
    
    func incrementHabit(id: UUID) {
        if let index = dailyHabits.firstIndex(where: { $0.id == id }) {
            guard let habit = dailyHabits[index].habit else { return }
            
            let step = habit.computedUnit.defaultStep
            
            if dailyHabits[index].completion < habit.objective {
                self.objectWillChange.send()
                dailyHabits[index].completion += step
            }
            
            if let habit = dailyHabits[index].habit {
                updateSmartNotification(
                    for: habit,
                    completion: dailyHabits[index].completion,
                    objective: habit.objective
                )
            }
        }
        try? self.context.save()
    }
    
    func checkDailyHabits() {
        for habit in self.habits {
            let filteredDailyHabits = dailyHabits.filter { $0.habit == habit }
            
            if filteredDailyHabits.isEmpty {
                addHabitForToday(habit: habit)
                continue
            }
            
            let sortedDailyHabits = filteredDailyHabits.sorted { $0.day! > $1.day! }
            let lastDate = sortedDailyHabits.first?.day ?? Date()
            
            let difference = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            
            if difference >= habit.frequency {
                addHabitForToday(habit: habit)
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Permission acceptée !")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    func updateSmartNotification(for habit: HabitEntity, completion: Double, objective: Double) {
        guard let id = habit.id?.uuidString else { return }
        
        if completion >= objective {
            print("Objectif atteint pour \(habit.name ?? "") : Suppression notif")
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        } else {
            print("Objectif non atteint : Reprogrammation notif")
            scheduleNotification(for: habit, currentCompletion: completion)
        }
    }

    func scheduleNotification(for habit: HabitEntity, currentCompletion: Double = 0.0) {
        guard let reminderDate = habit.reminderDate, let id = habit.id?.uuidString else { return }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        
        let content = UNMutableNotificationContent()
        content.title = "Rappel : \(habit.name ?? "Habitude")"
        content.sound = .default
        
        let remaining = habit.objective - currentCompletion
        let unitName = habit.computedUnit.rawValue
        
        if habit.computedType == .boolean {
            content.body = "Tu n'as pas encore validé ton objectif du jour ! 🎯"
        } else {
            content.body = "Courage ! Il te reste encore \(remaining.formatted()) \(unitName) pour atteindre ton but aujourd'hui. 💪"
        }
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    

    func updateHabit(habit: HabitEntity, name: String, frequency: Int16, objective: Double, reminderDate: Date?, hasReminder: Bool) {
        habit.name = name
        habit.frequency = frequency
        habit.objective = objective
        
        if hasReminder {
            habit.reminderDate = reminderDate
        } else {
            habit.reminderDate = nil
        }
        
        try? context.save()
        
        if let id = habit.id?.uuidString {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        }
        
        if hasReminder, let reminderDate = reminderDate {
            let request = NSFetchRequest<DailyHabitEntity>(entityName: "DailyHabitEntity")
            request.predicate = NSPredicate(format: "habit == %@ AND day >= %@", habit, Calendar.current.startOfDay(for: Date()) as NSDate)
            
            let todaysDaily = (try? context.fetch(request))?.first
            let currentCompletion = todaysDaily?.completion ?? 0
            
            if currentCompletion < objective {
                scheduleNotification(for: habit, currentCompletion: currentCompletion)
                print("Habitude modifiée : Notification reprogrammée ✅")
            } else {
                print("Habitude modifiée : Déjà fini pour aujourd'hui, rappel demain zzz 😴")
            }
        }
    }
    init(context: NSManagedObjectContext) {
        self.context = context
                
        let habitsRequest = NSFetchRequest<HabitEntity>(entityName: "HabitEntity")
        self.habits = (try? context.fetch(habitsRequest)) ?? []
        
        let dailyHabitsRequest = NSFetchRequest<DailyHabitEntity>(entityName: "DailyHabitEntity")
        self.dailyHabits = (try? context.fetch(dailyHabitsRequest)) ?? []
        
        requestNotificationPermission()
        checkDailyHabits()
    }
}
