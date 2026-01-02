//
//  Habit.swift
//  Routine
//
//  Created by Killian Mathias on 02/01/2026.
//

import Foundation

struct Habit : Identifiable{
    let id = UUID()
    var name : String
    var frequency : Int
    var objective : Int
}

struct HabitDay : Identifiable{
    let id = UUID()
    let day = Date()
    let habit : Habit
    var completion : Int
}
