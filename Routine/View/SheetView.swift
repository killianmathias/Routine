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
    @State private var type : Type = .boolean
    @State private var unit : Unit = .count
    
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
                    
                    if (type == .count || type == .duration){
                        Picker("Unité de mesure", selection: $unit){
                            ForEach(Unit.allCases.filter{ $0.belongsTo == type }, id:\.self){ unit in
                                Text("\(unit.rawValue)")
                            }
                        }
                    }
                        Picker("Fréquence", selection: $frequency){
                            ForEach(frequencyOptions, id: \.value){ option in
                                Text(option.label).tag(option.value)
                            }
                        }
                    
                    if type == .count{
                        CustomStepper(
                            value: $objective,
                            step: 1,
                            unit : unit.rawValue
                        )
                    }else if type == .duration{
                        CustomStepper(
                            value: $duration,
                            step: 5,
                            unit : unit.rawValue
                        )
                    }
                }
                
                Button("Valider"){
                    viewModel
                        .addHabit(
                            name: name,
                            frequency: frequency,
                            objective: objective,
                            type: type.rawValue
                        )
                    dismiss()
                }
            }
            .background(.primary)
        }
        
    }
}
