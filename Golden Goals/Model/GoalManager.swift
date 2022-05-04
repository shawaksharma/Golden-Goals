//
//  GoalManager.swift
//  Golden Goals
//
//  Created by Shawak Sharma on 18/04/2021.
//

import Foundation

// Goal Manager to interact with the JSON file
class GoalManager: ObservableObject {
    
    // Filename
    private static let fileName = "Goals.json"
    
    // Goals Array
    @Published var goals: [Goal] = []
    
    // Initialise
    init() {
        load()
    }
    
    // Load JSON file
    private func load() {
        do {
            goals = try Storage.shared.retrieve(GoalManager.fileName, as: [Goal].self, in: .documents)
        } catch {
            print("Unable to load JSON")
        }
    }
    
    // Update and Save JSON file
    func save() {
        do {
            let data = try JSONEncoder().encode(goals)
            Storage.shared.store(data, as: GoalManager.fileName, in: .documents)
        } catch {
            print("Unable to save JSON")
        }
    }
}
