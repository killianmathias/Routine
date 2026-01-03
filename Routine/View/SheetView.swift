//
//  SheetView.swift
//  Routine
//
//  Created by Killian Mathias on 03/01/2026.
//

import SwiftUI

struct SheetView : View {
    @Environment(\.dismiss) var dismiss
    @State private var name : String = ""
    @State private var frequency : Int16 = 1
    @State private var objective : Int16 = 1
    let frequencyOptions : [(value:Int16, label : String)] = [
        (1,"Tous les jours"),
        (2, "Tous les 2 jours"),
        (3, "Tous les 3 jours"),
        (7, "Toutes les semaines"),
        (30, "Tous les mois")
    ]
    
    let viewModel : ViewModel
    var body: some View {
        VStack{
            Form{
                Section("Saisissez votre nouvelle habitude"){
                    TextField("Nom", text: $name)
                    Picker("Fréquence", selection: $frequency){
                        ForEach(frequencyOptions, id: \.value){ option in
                            Text(option.label).tag(option.value)
                        }
                    }
                    Stepper("Objectif : \(objective)", onIncrement: {
                        objective += 1
                    }, onDecrement: {
                        if (objective > 0){
                            objective -= 1}})
                }
                
                Button("Valider"){
                    viewModel
                        .addHabit(
                            name: name,
                            frequency: frequency,
                            objective: objective
                        )
                    dismiss()
                }
            }
        }
        
    }
}
