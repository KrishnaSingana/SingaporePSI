//
//  PSISubReading.swift
//  SingaporePSI
//
//  Created by Krishna Singana on 13/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import Foundation

struct PSISubReading: Codable {
    var west: Double?
    var national: Double?
    var east: Double?
    var central: Double?
    var south: Double?
    var north: Double?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        west = try container.decodeIfPresent(Double.self, forKey: .west)
        national = try container.decodeIfPresent(Double.self, forKey: .national)
        east = try container.decodeIfPresent(Double.self, forKey: .east)
        central = try container.decodeIfPresent(Double.self, forKey: .central)
        south = try container.decodeIfPresent(Double.self, forKey: .south)
        north = try container.decodeIfPresent(Double.self, forKey: .north)
    }
}
