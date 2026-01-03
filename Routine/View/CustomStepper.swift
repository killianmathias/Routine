//
//  CustomStepper.swift
//  Routine
//
//  Created by Killian Mathias on 03/01/2026.
//
import SwiftUI

struct CustomStepper: View{
    @Binding var value : Int16
    let step : Int16
    let unit : String
    var body : some View{
        Stepper(
            "Objectif : \(value) \(unit)",
            onIncrement: increment,
            onDecrement: decrement
        )
    }
    
    func decrement(){
        if ((value - step) >= 0){
            value -= step
        }
    }
    
    func increment(){
        value += step
    }
}
