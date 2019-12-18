//
//  PSILocation.swift
//  SingaporePSI
//
//  Created by Krishna Singana on 13/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import Foundation

struct PSILocation: Codable {
    var latitude: Double?
    var longitude: Double?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
    }

}
