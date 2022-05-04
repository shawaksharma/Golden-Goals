//
//  AddNewGoal.swift
//  Golden Goals
//
//  Created by Shawak Sharma on 12/04/2021.
//

import SwiftUI

struct AddNewGoalView: View {
    
    // Goal Manager to add new goal and presentation mode to return to home screen
    @ObservedObject var manager: GoalManager
    @Environment(\.presentationMode) var presentationMode
    
    // Goal variables to change
    @State private var goalAmount = 1
    @State private var quickAdd = 1
    @State private var notif = true
    @State private var period = Period.day
    
    // Goal Strings for TextFields
    @State private var goalName: String = ""
    @State private var unit: String = ""
    
    // Show alert for Goal Name being empty
    @State private var showingAlert = false
    
    var body: some View {
        Form {
            // Title
            TextField("Goal Title", text: $goalName)
            
            // Period
            Picker(selection: $period, label: Text("Period")) {
                ForEach(Period.allCases) { period in
                    Text(period.namely).tag(period)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Goal Amount
            (TextField("Units e.g. minutes", text: $unit))
            Stepper(value: $goalAmount, in: 1...1000) {
                Text("Reach \(goalAmount) \(unit) per \(period.name)")
            }
            
            // Quick Add Value
            Stepper(value: $quickAdd, in: 1...1000) {
                Text("Quick add value \(quickAdd)")
                
            }
            
            // Notifications
            Toggle(isOn: $notif) {
                Text("Notifications")
            }
        }
        .navigationBarTitle(Text("New Goal"), displayMode: .inline) // Nav Title
        // Defines alert
        .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Goal Name cannot be empty."), message: Text("Please give your goal a name."), dismissButton: .default(Text("Okay")))
                }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // Done Button
                Button(action: {
                    // If Goal Name is not empty add the new goal, else show alert
                    if !goalName.isEmpty {
                        let goal = Goal(id: UUID(), name: goalName, period: period, goalAmount: Double(goalAmount), quickAdd: Double(quickAdd), unit: String(unit))
                        manager.goals.append(goal)
                        manager.save()
                        presentationMode.wrappedValue.dismiss()
                    }
                    else {
                        showingAlert = true
                    }
                }, label: {
                    Text("Done")
                })
            }
        }
    }
}
