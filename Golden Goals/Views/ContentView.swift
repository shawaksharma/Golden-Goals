//
//  ContentView.swift
//  Golden Goals
//
//  Created by Shawak Sharma on 02/04/2021.
//

import SwiftUI

struct ContentView: View {
    // Goal Manager
    @ObservedObject var manager = GoalManager()
    
    var body: some View {
        NavigationView {
            List {
                // Today's Goals
                Section(header: HeaderView(title: "Today's Goals")) {
                    if today.isEmpty { // If empty show none view
                        NoneView()
                    }
                    // For each goal in the today array, show its goal row and linked to its goal detail screen
                    ForEach(today) { goal in
                        NavigationLink(destination: GoalDetail(goal: goal, manager: manager)) {
                            GoalRow(goal: goal, manager: manager)
                        }
                    }
                }
                // Week's Goals
                Section(header: HeaderView(title: "This Week's Goals")) {
                    if week.isEmpty { // If empty show none view
                        NoneView()
                    }
                    // For each goal in the today array, show its goal row and linked to its goal detail screen
                    ForEach(week) { goal in
                        NavigationLink(destination: GoalDetail(goal: goal, manager: manager)) {
                            GoalRow(goal: goal, manager: manager)
                        }
                    }
                }
                // Month's Goals
                Section(header: HeaderView(title: "This Month's Goals")) {
                    if month.isEmpty { // If empty show none view
                        NoneView()
                    }
                    // For each goal in the today array, show its goal row and linked to its goal detail screen
                    ForEach(month) { goal in
                        NavigationLink(destination: GoalDetail(goal: goal, manager: manager)) {
                            GoalRow(goal: goal, manager: manager)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(Text("Golden Goals")) // Nav Title
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { // Add New Goal Button
                    NavigationLink(destination: AddNewGoalView(manager: manager)) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(.largeTitle))
                            .foregroundColor(Color("Pink"))
                    }
                }
            }
        }
    }
    
    // Change colour of UI attributes
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(named: "Pink")!]
        UIBarButtonItem.appearance().tintColor = UIColor(named: "Pink")
    }
    
    // Filter goals into daily, weekly and monthly goals
    private var today: [Goal] {
        manager.goals.filter { $0.period == .day }
    }
    
    private var week: [Goal] {
        manager.goals.filter { $0.period == .week }
    }
    
    private var month: [Goal] {
        manager.goals.filter { $0.period == .month }
    }
}

// Headline Text View
struct HeaderView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(Color("Gold"))
    }
}

// 'None' Text View
struct NoneView: View {
    
    var body: some View {
        Text("None")
            .foregroundColor(.secondary)
            .listRowBackground(Color(UIColor.systemGroupedBackground))
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
