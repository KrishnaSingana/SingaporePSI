//
//  PSIItem.swift
//  SingaporePSI
//
//  Created by Krishna Singana on 13/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import Foundation

struct PSIItem: Codable {
    var timeStamp: String?
    var updateTimeStamp: String?
    var psiReadings: PSIReading?

    private enum CodingKeys: String, CodingKey {
        case timeStamp = "timestamp"
        case updateTimeStamp = "update_timestamp"
        case psiReadings = "readings"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        timeStamp = try container.decodeIfPresent(String.self, forKey: .timeStamp)
        updateTimeStamp = try container.decodeIfPresent(String.self, forKey: .updateTimeStamp)
        psiReadings = try container.decodeIfPresent(PSIReading.self, forKey: .psiReadings)
    }
}
