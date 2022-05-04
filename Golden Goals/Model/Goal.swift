//
//  Goal.swift
//  Golden Goals
//
//  Created by Shawak Sharma on 15/04/2021.
//

import Foundation
import SwiftUI

// Goal
class Goal: ObservableObject, Codable, Identifiable {
    @Published var id: UUID
    @Published var name: String
    @Published var period: Period
    @Published var goalAmount: Double
    @Published var currentAmount: Double
    @Published var quickAdd: Double
    @Published var unit: String
    @Published var logs: [Log]
    
    // Initialise Goal
    init(id: UUID, name: String, period: Period, goalAmount: Double, quickAdd: Double, unit: String) {
        self.id = id
        self.name = name
        self.period = period
        self.goalAmount = goalAmount
        self.currentAmount = 0
        self.quickAdd = quickAdd
        self.unit = unit
        self.logs = []
    }
    
    // Quick Add Button Function
    func performQuickAdd() {
        currentAmount += quickAdd
        let log = Log(amountChanged: quickAdd)
        logs.append(log)
        //manager.save()
    }
    
    // Finish Goal Button Function
    func performFinishGoal() {
        let remainder = toGo
        currentAmount += remainder
        let log = Log(amountChanged: remainder)
        logs.append(log)
    }
    
    // Manual Add Button Function
    func performManualAdd(amount: String) {
        currentAmount += Double(amount)!
        let log = Log(amountChanged: Double(amount)!)
        logs.append(log)
    }
    
    // Working out the remainder of the goal left in specific time period
    var toGo: Double {
        var progress: Double = 0
        switch period {
        
        // Day
        case .day:
            let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
            let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
            progress = self.progress(between: startDate, and: endDate)
        
        // Week
        case .week:
            let startDate = Calendar.current.date(byAdding: .day, value: -1 * 7, to: Date())!
            let endDate = Date()
            progress = self.progress(between: startDate, and: endDate)
        
        // Month
        case .month:
            let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
            let endDate = Date()
            progress = self.progress(between: startDate, and: endDate)
        }
        let toGo = goalAmount - progress
        return toGo
    }
    
    // Work out toGo as a percentage (for progress bars)
    var toGoPercentage: Double {
        (goalAmount - toGo) / goalAmount
    }
    
    // Work out progress between start and end date
    func progress(between startDate: Date, and endDate: Date) -> Double {
        let logs = logs.filter { (startDate...endDate).contains($0.dateTime) }
        return logs.reduce(0, { $0 + $1.amountChanged })
    }
    
    // MARK: - JSON Decoder and Encoder for Goals
    // Being able to edit variables live from a JSON format
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case period
        case goalAmount
        case currentAmount
        case quickAdd
        case unit
        case logs
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        period = try container.decode(Period.self, forKey: .period)
        goalAmount = try container.decode(Double.self, forKey: .goalAmount)
        currentAmount = try container.decode(Double.self, forKey: .currentAmount)
        quickAdd = try container.decode(Double.self, forKey: .quickAdd)
        unit = try container.decode(String.self, forKey: .unit)
        logs = try container.decode([Log].self, forKey: .logs)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(period, forKey: .period)
        try container.encode(goalAmount, forKey: .goalAmount)
        try container.encode(currentAmount, forKey: .currentAmount)
        try container.encode(quickAdd, forKey: .quickAdd)
        try container.encode(unit, forKey: .unit)
        try container.encode(logs, forKey: .logs)
    }
}

// MARK: - Logs

class Log: ObservableObject, Codable, Identifiable {
    var id: UUID
    var amountChanged: Double
    let dateTime: Date
    
    init(amountChanged: Double) {
        self.id = UUID()
        self.amountChanged = amountChanged
        self.dateTime = Date()
    }
    
    // MARK: - JSON Decoder and Encoder for Logs
    // Being able to edit variables live from a JSON format
    private enum CodingKeys: String, CodingKey {
        case id
        case amountChanged
        case dateTime
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        amountChanged = try container.decode(Double.self, forKey: .amountChanged)
        dateTime = try container.decode(Date.self, forKey: .dateTime)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(amountChanged, forKey: .amountChanged)
        try container.encode(dateTime, forKey: .dateTime)
    }
}

// Enum for seperating Daily, Weekly and Monthly Goals
enum Period: Int, Codable, CaseIterable, Hashable, Identifiable {
    case day
    case week
    case month
    
    var name: String {
        switch self {
        case .day:
            return "day"
        case .week:
            return "week"
        case .month:
            return "month"
        }
    }
    
    var namely: String {
        switch self {
        case .day:
            return "Daily"
        case .week:
            return "Weekly"
        case .month:
            return "Monthly"
        }
    }
    
    var id: Int {
        rawValue
    }
}
