//
//  TestResponse.swift
//  Onslaught
//
//  Created by Bryce Eppler on 2023-02-13.
//

import Foundation

struct TestResponse: Decodable {
    let success: Bool
    let message: String?
}
