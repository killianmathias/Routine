//
//  HabitDetailView.swift
//  Routine
//
//  Created by Killian Mathias on 03/01/2026.
//

import SwiftUI

struct HabitView: View {
    @ObservedObject var habit: HabitEntity // L'habitude qu'on modifie
    @ObservedObject var viewModel: ViewModel // Pour appeler l'update
    @Environment(\.dismiss) var dismiss // Pour fermer la page
    
    // États locaux pour le formulaire
    @State private var name: String = ""
    @State private var frequency: Int16 = 1
    @State private var objective: Double = 1.0
    
    // États pour les notifications
    @State private var hasReminder: Bool = false
    @State private var reminderDate: Date = Date()
    
    let frequencyOptions: [(value: Int16, label: String)] = [
        (1, "Tous les jours"),
        (2, "Tous les 2 jours"),
        (3, "Tous les 3 jours"),
        (7, "Toutes les semaines"),
        (30, "Tous les mois")
    ]
    
    var body: some View {
        Form {
            Section("Informations") {
                TextField("Nom", text: $name)
                
                Picker("Fréquence", selection: $frequency) {
                    ForEach(frequencyOptions, id: \.value) { option in
                        Text(option.label).tag(option.value)
                    }
                }
                
                // On affiche le Type et l'Unité à titre informatif (non modifiable pour éviter les bugs)
                HStack {
                    Text("Type")
                    Spacer()
                    Text(habit.computedType.rawValue)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Section Objectif (Uniquement si ce n'est pas un booléen)
            if habit.computedType != .boolean {
                Section("Objectif") {
                    CustomStepper(
                        value: $objective,
                        step: habit.computedUnit.defaultStep,
                        unit: habit.computedUnit.rawValue
                    )
                }
            }
            
            Section("Rappels") {
                Toggle("Activer les rappels", isOn: $hasReminder)
                if hasReminder {
                    DatePicker("Heure", selection: $reminderDate, displayedComponents: .hourAndMinute)
                }
            }
            
            Section {
                Button("Enregistrer les modifications") {
                    saveChanges()
                }
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Modifier")
        .navigationBarTitleDisplayMode(.inline)
        // 👇 C'est ici qu'on charge les données de Core Data dans le formulaire
        .onAppear {
            loadData()
        }
    }
    
    func loadData() {
        name = habit.name ?? ""
        frequency = habit.frequency
        objective = habit.objective
        
        if let date = habit.reminderDate {
            hasReminder = true
            reminderDate = date
        } else {
            hasReminder = false
        }
    }
    
    func saveChanges() {
        viewModel.updateHabit(
            habit: habit,
            name: name,
            frequency: frequency,
            objective: objective,
            reminderDate: hasReminder ? reminderDate : nil,
            hasReminder: hasReminder
        )
        dismiss()
    }
}
