//
//  WorkoutListResponse.swift
//  Onslaught
//
//  Created by Bryce Eppler on 2023-02-13.
//

import Foundation

struct WorkoutListResponse: Decodable {
    let success: Bool
    let workouts: [Workout]?
}
