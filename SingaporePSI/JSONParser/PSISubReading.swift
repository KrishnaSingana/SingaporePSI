//
//  PSISubReading.swift
//  SingaporePSI
//
//  Created by Krishna Singana on 13/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import Foundation

struct PSISubReading: Codable {
    var west: Double
    var national: Double
    var east: Double
    var central: Double
    var south: Double
    var north: Double
}
