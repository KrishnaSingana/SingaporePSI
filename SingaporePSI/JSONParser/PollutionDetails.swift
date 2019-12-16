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

struct AppInfo: Codable {
    var status: String
}
