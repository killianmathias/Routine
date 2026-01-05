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
    @State private var objective : Double = 1
    @State private var type : Type = .boolean
    @State private var unit : Unit = .count
    @State private var notification : Bool = false
    @State private var reminderDate : Date = Date()
    
    @State private var duration : Int16 = 5
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
                        Picker("Type", selection: $type){
                            ForEach(Type.allCases, id: \.self){ type in
                                Text("\(type.rawValue)")
                            }
                        }
                    
                    
                        Picker("Fréquence", selection: $frequency){
                            ForEach(frequencyOptions, id: \.value){ option in
                                Text(option.label).tag(option.value)
                            }
                        }
                    
                    if (type == .count || type == .duration){
                        Picker("Unité", selection: $unit){
                            ForEach(Unit.allCases.filter{ $0.belongsTo == type }, id:\.self){ unit in
                                Text("\(unit.rawValue)")
                            }
                        }
                        CustomStepper(
                            value: $objective,
                            step: unit.defaultStep,
                            unit : unit.rawValue
                        )
                    }
                }
                Section("Rappels") {
                    Toggle("Activer les rappels", isOn: $notification)
                    if notification {
                        DatePicker("Heure", selection: $reminderDate, displayedComponents: .hourAndMinute)
                    }
                }
                
                Button("Valider"){
                    viewModel
                        .addHabit(
                            name: name,
                            frequency: frequency,
                            objective: objective,
                            type: type,
                            unit:unit,
                            reminderDate : notification ? reminderDate : nil
                        )
                    dismiss()
                }
            }
            .background(.primary)
            .onChange(of: type) { oldValue, newValue in
                if let firstCompatibleUnit = Unit.allCases.first(where: { $0.belongsTo == newValue }) {
                    unit = firstCompatibleUnit
                }
                if type == .duration{
                    objective = 5
                }else{
                    objective = 1
                }
            }
        }
        
        
    }
}

