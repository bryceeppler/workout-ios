//
//  StatsResponse.swift
//  Onslaught
//
//  Created by Bryce Eppler on 2023-02-13.
//

import Foundation

struct StatsResponse: Decodable {
    let success: Bool
    let users: [UserStats]?
}
