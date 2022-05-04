//
//  ManualEntryView.swift
//  Golden Goals
//
//  Created by Shawak Sharma on 09/05/2021.
//

import SwiftUI

struct ManualEntryView: View {
    
    // Goal using the manual add with
    @ObservedObject var goal: Goal
    
    // Goal Manager to call save function
    @ObservedObject var manager: GoalManager
    
    // Presentation mode to return to previous screen
    @Environment(\.presentationMode) var presentationMode
    
    // Amount entered
    @State private var input = String()
    
    // Alert if amount is invalid or empty
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                // Input for Manual Add
                TextField("Amount", text: $input)
            }
            .navigationBarTitle("Add Amount")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Add Button
                    Button("Add") {
                        let numbers = NSCharacterSet.decimalDigits
                        let numbersRange = input.rangeOfCharacter(from: numbers)
                        // Check if input contains anything but numbers or is empty show alert
                        if input.isEmpty || numbersRange == nil {
                            showingAlert = true
                        }
                        // Else add the value
                        else {
                            goal.performManualAdd(amount: input)
                            manager.save()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        // Alert is defined
        .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Amount entered is empty or invalid."), message: Text("Please enter a valid amount."), dismissButton: .default(Text("Okay")))
                }
        
    }
}
