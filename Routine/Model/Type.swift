//
//  Type.swift
//  Routine
//
//  Created by Killian Mathias on 03/01/2026.
//
import Foundation
import CoreData

enum Type : String, CaseIterable {
    case boolean = "Booléen"
    case count = "Compteur"
    case duration = "Durée"
    case mesure = "Mesure"
 }

extension HabitEntity{
    var computedType : Type{
        let typeString = self.type ?? ""
        
        return Type(rawValue : typeString) ?? .boolean
    }
}
