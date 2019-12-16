//
//  PollutionAnnotation.swift
//  SingaporePSI
//
//  Created by Krishna Singana on 10/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import MapKit

class PollutionAnnotation: NSObject, MKAnnotation {
    let title: String?
    let pollutionDetails: NSMutableAttributedString
    let coordinate: CLLocationCoordinate2D

    init(title: String, pollutionDetails: NSMutableAttributedString, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.pollutionDetails = pollutionDetails
        self.coordinate = coordinate

        super.init()
    }
}
