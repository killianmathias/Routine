//
//  ContentView.swift
//  Routine
//
//  Created by Killian Mathias on 03/01/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        HomeView(context: viewContext)
    }
}
