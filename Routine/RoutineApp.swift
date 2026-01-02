//
//  RoutineApp.swift
//  Routine
//
//  Created by Killian Mathias on 02/01/2026.
//

import SwiftUI
import CoreData

@main
struct RoutineApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
