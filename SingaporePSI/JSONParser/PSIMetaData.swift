//
//  PSIMetaData.swift
//  SingaporePSI
//
//  Created by Krishna Singana on 13/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import Foundation

struct PSIMetaData: Codable {
    var direction: String
    var location: PSILocation

    private enum CodingKeys: String, CodingKey {
        case direction = "name"
        case location = "label_location"
    }
}
