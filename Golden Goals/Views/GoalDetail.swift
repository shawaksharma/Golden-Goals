//
//  GoalDetail.swift
//  Golden Goals
//
//  Created by Shawak Sharma on 14/04/2021.
//

import SwiftUI

struct GoalDetail: View {
    
    // Variables
    @ObservedObject var goal: Goal
    @ObservedObject var manager: GoalManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAlert = false
    @State private var isManualPresented: Bool = false
    
    var body: some View {
        ZStack {
            List {
                VStack {
                    HStack {
                        // Goal Name
                        Text(goal.name)
                            .padding()
                            .font(Font.system(.largeTitle))
                            .foregroundColor(Color("Gold"))
                            .multilineTextAlignment(.center)
                        Spacer()
                        // Manual Add Button
                        Button(action: {
                            isManualPresented.toggle()
                        }, label: {
                            Image(systemName: "plus.square")
                                .padding(.all, 5)
                                .foregroundColor(Color("Pink"))
                                .font(Font.system(.largeTitle))
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
                                .font(Font.system(.largeTitle))
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                    // Progress Bar
                    ProgressView(value: goal.toGoPercentage.clamped(to: 0...1))
                        .padding()
                        .accentColor(Color("Pink"))
                }

                // Creating Graph
                if graphPoints.contains(where: { $0 > 0 }) {
                    HStack(alignment: .bottom) {
                        ForEach(0..<graphBars) { day in
                            VStack(alignment: .center) {
                                ZStack(alignment: .bottom) {
                                    Rectangle()
                                        .fill(Color(UIColor.systemGray6))
                                        .frame(height: graphHeight)
                                        .cornerRadius(5)
                                    Rectangle()
                                        .fill(Color("Pink"))
                                        .frame(height: graphBarHeight(at: day))
                                        .cornerRadius(5)
                                }
                                Text(labels[day])
                                    .multilineTextAlignment(.center)
                                    .font(.footnote)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                else {
                    Text("No Progress")
                        .padding()
                }
                
                // Your goal is to hit... Text
                VStack {
                    HStack {
                        Text("Your goal is to hit \(Int(goal.goalAmount)) \(goal.unit) every \(goal.period.name).")
                            .padding(10)
                        Spacer()
                        if goal.toGo > 0 {
                            Text("\(Int(goal.toGo)) to go!")
                                .foregroundColor(.secondary)
                        }
                        else if goal.toGo == 0 {
                            Text("Goal Reached!")
                                .foregroundColor(.secondary)
                        }
                        else {
                            Text("\(Int(abs(goal.toGo))) more done!")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                
                // Logs
                Section(header: Text("Recent Logs")) {
                    if goal.logs.isEmpty {
                        NoneView()
                    }
                    ForEach(goal.logs.reversed().prefix(10)) { log in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Added \(Int(log.amountChanged)) \(goal.unit)")
                                Spacer()
                                Text("\(log.dateTime, formatter: GoalDetail.dateFormatter)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle(Text("Goal Details"), displayMode: .inline) // Nav Bar Title
            .toolbar {  // Toolbar
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Delete Button
                    Button {
                        showingAlert.toggle()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            // Delete Goal Alert
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Are you sure you want to delete this goal?"),
                    message: Text("This can't be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let index = manager.goals.firstIndex(where: { $0.id == goal.id }) {
                            manager.goals.remove(at: index)
                            manager.save()
                            presentationMode.wrappedValue.dismiss()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        // Manual Add Sheet
        .sheet(isPresented: $isManualPresented) {
            ManualEntryView(goal: goal, manager: manager)
        }
    }
    // Format the date into a shorter date
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    // Create graph bars
    private var graphPoints: [Double] {
        var progress: [Double] = []
        for index in (0..<graphBars).reversed() {
            var startDate = Date()
            var endDate = Date()
            let currentDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
            // Chose startDate and endDate depending on the goal's period
            switch goal.period {
            // Day
            case .day:
                startDate = Calendar.current.date(byAdding: .day, value: -index, to: currentDate)!
                endDate = Calendar.current.date(byAdding: .day, value: -index + 1, to: currentDate)!
            // Week
            case .week:
                startDate = Calendar.current.date(byAdding: .day, value: 7 * -index, to: currentDate)!
                endDate = Calendar.current.date(byAdding: .day, value: 7 * -index + 1, to: currentDate)!
            // Month
            case .month:
                startDate = Calendar.current.date(byAdding: .month, value: -index, to: currentDate)!
                endDate = Calendar.current.date(byAdding: .month, value: -index + 1, to: currentDate)!
            }
            // Set periodProgress depending on the startDate and endDate from case above to progress and return
            let periodProgress = goal.progress(between: startDate, and: endDate)
            progress.append(periodProgress)
        }
        return progress
    }
    
    // Number of bars to display
    private let graphBars = 7
    
    // Set X axis labels
    private var labels: [String] {
        let dateFormatter = DateFormatter()
        var labels: [String] = []
        // Find appropriate labels depending on goal period
        switch goal.period {
        // Day
        case .day:
            dateFormatter.dateFormat = "E"
            for day in (0..<graphBars).reversed() {
                let date = Calendar.current.date(byAdding: .day, value: -day, to: Date())!
                labels.append(dateFormatter.string(from: date))
            }
        // Week
        case .week:
            dateFormatter.dateFormat = "d MMM"
            for week in (0..<graphBars).reversed() {
                let date = Calendar.current.date(byAdding: .day, value: -week * 7, to: Date())!
                labels.append(dateFormatter.string(from: date))
            }
        // Month
        case .month:
            dateFormatter.dateFormat = "MMM"
            for month in (0..<graphBars).reversed() {
                let date = Calendar.current.date(byAdding: .month, value: -month, to: Date())!
                labels.append(dateFormatter.string(from: date))
            }
        }
        
        return labels
    }
    
    // Set graph height
    private let graphHeight: CGFloat = 250
    
    // Set ratio of grey graph bar height to be goal amount
    private func graphBarHeight(at index: Int) -> CGFloat {
        let points = graphPoints
        return CGFloat(points[index] / goal.goalAmount) * graphHeight
    }
}

extension Comparable {
    
    /**
     Returns a copy of this range clamped to the given limiting range.
     - parameter limits: The range to clamp the bounds of this range.
     - returns: A new range clamped to the bounds of `limits`.
     */
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
