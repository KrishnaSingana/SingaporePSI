//
//  PollutionDetails.swift
//  SingaporePSI
//
//  Created by Krishna Singana on 10/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import Foundation

struct PollutionDetails: Codable {
    var regionsMetadata: [PSIMetaData]
    var items: [PSIItem]
    var appInfo: AppInfo
    
    private enum CodingKeys: String, CodingKey {
        case regionsMetadata = "region_metadata"
        case items = "items"
        case appInfo = "api_info"
    }
}

struct PSIMetaData: Codable {
    var direction: String
    var location: PSILocation

    private enum CodingKeys: String, CodingKey {
        case direction = "name"
        case location = "label_location"
    }
}

struct PSILocation: Codable {
    var latitude: Double
    var longitude: Double
}

struct PSIItem: Codable {
    var timeStamp: String?
    var updateTimeStamp: String?
    var psiReadings: PSIReading

    private enum CodingKeys: String, CodingKey {
        case timeStamp = "timestamp"
        case updateTimeStamp = "update_timestamp"
        case psiReadings = "readings"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        timeStamp = try container.decodeIfPresent(String.self, forKey: .timeStamp)
        updateTimeStamp = try container.decodeIfPresent(String.self, forKey: .updateTimeStamp)
        psiReadings = try container.decode(PSIReading.self, forKey: .psiReadings)
    }
}

struct PSIReading: Codable {
    var o3_sub_index: PSISubReading
    var pm10_twenty_four_hourly: PSISubReading
    var pm10_sub_index: PSISubReading
    var co_sub_index: PSISubReading
    var pm25_twenty_four_hourly: PSISubReading
    var so2_sub_index: PSISubReading
    var co_eight_hour_max: PSISubReading
    var no2_one_hour_max: PSISubReading
    var so2_twenty_four_hourly: PSISubReading
    var pm25_sub_index: PSISubReading
    var psi_twenty_four_hourly: PSISubReading
    var o3_eight_hour_max: PSISubReading
}

struct PSISubReading: Codable {
    var west: Double
    var national: Double
    var east: Double
    var central: Double
    var south: Double
    var north: Double
}

struct AppInfo: Codable {
    var status: String
}
