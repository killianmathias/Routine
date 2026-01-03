//
//  Unit.swift
//  Routine
//
//  Created by Killian Mathias on 03/01/2026.
//
import Foundation
import CoreData

enum Unit : String, CaseIterable, Identifiable{
    
    case minute = "min"
    case hour = "h"
    
    case glass = "verres"
    case page = "pages"
    case count = "fois"
    
    var id : Self{self}
    
    var belongsTo : Type{
        switch self{
        case .minute, .hour:
            return .duration
        case .glass, .page, .count:
            return .count
        }
    }
    
    var defaultStep : Double{
        switch self{
        case .minute:
            return 5
        case .hour:
            return 5.0/60
        default:
            return 1
        }
    }
}

extension HabitEntity{
    var computedUnit : Unit{
        let unitString = self.unit ?? ""
            
        return Unit(rawValue : unitString) ?? .count
    }

}

