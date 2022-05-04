//
//  GoalRow.swift
//  Golden Goals
//
//  Created by Shawak Sharma on 17/04/2021.
//

import SwiftUI

struct GoalRow: View {
    
    // Goal to Show
    @ObservedObject var goal: Goal
    
    // Goal Manager
    @ObservedObject var manager: GoalManager
    
    // Set Manual View to false
    @State private var isManualPresented: Bool = false
    
    var body: some View {
        ZStack {
            HStack {
                // Manual Add Button
                Button(action: {
                    isManualPresented.toggle()
                }, label: {
                    Image(systemName: "plus.square")
                        .padding(.all, 5)
                        .foregroundColor(Color("Pink"))
                })
                .buttonStyle(PlainButtonStyle())
                // Quick Add Button
                Button(action: {
                    withAnimation {
                        goal.performQuickAdd()
                        manager.save()
                    }
                }, label: {
                    Image(systemName: "chevron.up")
                        .padding(.all, 5)
                        .foregroundColor(Color("Pink"))
                })
                .buttonStyle(PlainButtonStyle())
                // Goal Name
                Text(goal.name)
                    .padding()
                    .multilineTextAlignment(.center)
                // Progress Bar
                ProgressView(value: goal.toGoPercentage.clamped(to: 0...1))
                    .padding()
                // Quick Finish Goal Button
                Button(action: {
                    goal.performFinishGoal()
                    manager.save()
                }, label: {
                    Image(systemName: "checkmark.square.fill")
                        .padding(.all, 5)
                        .foregroundColor(Color(hue: 0.371, saturation: 0.951, brightness: 0.686))
                })
                .buttonStyle(PlainButtonStyle())
            }
            .accentColor(Color("Gold"))
        }
        // Manual Add Button Sheet
        .sheet(isPresented: $isManualPresented) {
            ManualEntryView(goal: goal, manager: manager)
        }
    }
}
