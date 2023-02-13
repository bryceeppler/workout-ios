//
//  OnslaughtApp.swift
//  Onslaught
//
//  Created by Bryce Eppler on 2023-02-12.
//

import SwiftUI

@main
struct OnslaughtApp: App {
    @StateObject private var workoutService = WorkoutService()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(workoutService)
        }
    }
}
