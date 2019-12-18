//
//  PSIReading.swift
//  SingaporePSI
//
//  Created by Krishna Singana on 13/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import Foundation

struct PSIReading: Codable {
    var o3SubIndex: PSISubReading?
    var pm10TwentyFourHourly: PSISubReading?
    var pm10SubIndex: PSISubReading?
    var coSubIndex: PSISubReading?
    var pm25TwentyFourHourly: PSISubReading?
    var so2SubIndex: PSISubReading?
    var coEightHourMax: PSISubReading?
    var no2OneHourMax: PSISubReading?
    var so2TwentyFourHourly: PSISubReading?
    var pm25SubIndex: PSISubReading?
    var psiTwentyFourHourly: PSISubReading?
    var o3EightHourMax: PSISubReading?

    private enum CodingKeys: String, CodingKey {
        case o3SubIndex = "o3_sub_index"
        case pm10TwentyFourHourly = "pm10_twenty_four_hourly"
        case pm10SubIndex = "pm10_sub_index"
        case coSubIndex = "co_sub_index"
        case pm25TwentyFourHourly = "pm25_twenty_four_hourly"
        case so2SubIndex = "so2_sub_index"
        case coEightHourMax = "co_eight_hour_max"
        case no2OneHourMax = "no2_one_hour_max"
        case so2TwentyFourHourly = "so2_twenty_four_hourly"
        case pm25SubIndex = "pm25_sub_index"
        case psiTwentyFourHourly = "psi_twenty_four_hourly"
        case o3EightHourMax = "o3_eight_hour_max"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        o3SubIndex = try container.decodeIfPresent(PSISubReading.self, forKey: .o3SubIndex)
        pm10TwentyFourHourly = try container.decodeIfPresent(PSISubReading.self, forKey: .pm10TwentyFourHourly)
        pm10SubIndex = try container.decodeIfPresent(PSISubReading.self, forKey: .pm10SubIndex)
        coSubIndex = try container.decodeIfPresent(PSISubReading.self, forKey: .coSubIndex)
        pm25TwentyFourHourly = try container.decodeIfPresent(PSISubReading.self, forKey: .pm25TwentyFourHourly)
        so2SubIndex = try container.decodeIfPresent(PSISubReading.self, forKey: .so2SubIndex)
        coEightHourMax = try container.decodeIfPresent(PSISubReading.self, forKey: .coEightHourMax)
        no2OneHourMax = try container.decodeIfPresent(PSISubReading.self, forKey: .no2OneHourMax)
        so2TwentyFourHourly = try container.decodeIfPresent(PSISubReading.self, forKey: .so2TwentyFourHourly)
        pm25SubIndex = try container.decodeIfPresent(PSISubReading.self, forKey: .pm25SubIndex)
        psiTwentyFourHourly = try container.decodeIfPresent(PSISubReading.self, forKey: .psiTwentyFourHourly)
        o3EightHourMax = try container.decodeIfPresent(PSISubReading.self, forKey: .o3EightHourMax)
    }
}
