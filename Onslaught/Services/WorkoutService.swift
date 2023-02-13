//
//  WorkoutService.swift
//  Onslaught
//
//  Created by Bryce Eppler on 2023-02-13.
//

import Foundation

enum WorkoutError: Error {
    case custom(String)
}

@MainActor
class WorkoutService: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var userStats: [UserStats] = []
    func getWorkoutList() async throws {
        let (data, _) = try await URLSession.shared.data(from: URL(string:
                                                                  "http://10.0.0.101:3000/workouts/")!)
        
        let workoutListResponse = try JSONDecoder().decode(WorkoutListResponse.self, from: data)
        if workoutListResponse.success {
            if let workoutList = workoutListResponse.workouts {
                self.workouts = workoutList
            }
            print("success in workoutlist")
        } else {
            throw WorkoutError.custom("Error in WorkoutService.swift")
        }
        
    }
    func getUserStatsList() async throws {
        let (data, _) = try await URLSession.shared.data(from: URL(string:
                                                                  "http://10.0.0.101:3000/user/stats/")!)
        
        let userStatsResponse = try JSONDecoder().decode(StatsResponse.self, from: data)
        if userStatsResponse.success {
            if let users = userStatsResponse.users {
                self.userStats = users
            }
            print("success in statslist")
        } else {
            throw WorkoutError.custom("Error in WorkoutService.swift")
        }
        
    }
    
}
