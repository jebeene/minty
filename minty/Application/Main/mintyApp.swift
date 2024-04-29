//
//  mintyApp.swift
//  minty
//
//  Created by Jacob Beene on 1/11/24.
//

import SwiftUI

@main
struct mintyApp: App {
    
    init() {
//        DatabaseManager.instance.clearDatabase()
        DatabaseManager.instance.initializeTables()
        DatabaseManager.instance.createIndexes()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
