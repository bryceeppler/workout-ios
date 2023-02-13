//
//  WorkoutService.swift
//  Onslaught
//
//  Created by Bryce Eppler on 2023-02-13.
//

import Foundation

struct CompletedWorkout: Codable {
    var id: Int
    var userId: Int
    var status: String
    var title: String
}

struct SubmittedActivity: Codable {
    var uid: Int
    var duration: Int
    var date: Date
}

enum WorkoutError: Error {
    case custom(String)
}

@MainActor
class WorkoutService: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var userStats: [UserStats] = []
    func getWorkoutList(userId:Int?) async throws {
        let (data, _) = try await URLSession.shared.data(from: URL(string:
                                                                    "http://10.0.0.101:3000/incompleteworkouts/\(userId ?? 1)")!)
        
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
    func createCompletedWorkout(userId: Int, workoutId: Int, status: String, title: String) async throws {
        let endpoint = "http://10.0.0.101:3000/completeWorkout"
        let workout = CompletedWorkout(id: workoutId, userId: userId, status: status, title: title)
        let jsonEncoder = JSONEncoder()
        let workoutData = try jsonEncoder.encode(workout)
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.httpBody = workoutData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(CompleteWorkoutResponse.self, from: data)
        if response.success {
            print("Workout completed successfully.")
        } else {
            throw WorkoutError.custom("Error in WorkoutService.swift")
        }
    }
    
    func createActivity(userId: Int, duration: Int, date: Date, type: String) async throws {
        var endpoint:String;
        if (type == "Cold Plunge") {
            endpoint = "http://10.0.0.101:3000/createIcePlunge"
        } else {
            endpoint = "http://10.0.0.101:3000/createCardioSession"
        }
        let activity = SubmittedActivity(uid: userId, duration: duration, date: date)
        let jsonEncoder = JSONEncoder()
        let activityData = try jsonEncoder.encode(activity)
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.httpBody = activityData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(CompleteWorkoutResponse.self, from: data)
        if response.success {
            print("Activity added successfully.")
        } else {
            throw WorkoutError.custom("Error in WorkoutService.swift in createIcePlunge")
        }
    }

}
