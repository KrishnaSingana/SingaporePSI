//
//  PSIViewController.swift
//  SingaporePSI
//
//  Created by Krishna Singana on 10/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import UIKit
import MapKit

enum CardinalDirections: String {
    case west
    case national
    case east
    case central
    case south
    case north
}

class PSIViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblAppStatus: UILabel!
    @IBOutlet weak var btnNationalDetails: UIButton!
    @IBOutlet weak var nationalDetailsView: UIView!
    @IBOutlet weak var lblNationalDetails: UILabel!
    @IBOutlet weak var nationalDetailsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nationalDetailsViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var nationalDetailsViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var nationalDetailsViewBottomConstraint: NSLayoutConstraint!

    fileprivate let regionRadius: CLLocationDistance = 60000
    fileprivate let baseURL = "https://api.data.gov.sg/v1/environment/psi"
    fileprivate var nationalMetaDataDetails = ("", "")

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setViewsToTheirStates()

        // set initial location to Singapore
        let initialLocationOnMap = CLLocation(latitude: 1.35735, longitude: 103.85)
        self.centerMapOnLocation(location: initialLocationOnMap)
        mapView.delegate = self

        let dateTimeString = self.getSingaporeDateTimeFromDate(date: Date())
        self.getPollutionDetailsFor(dateTime: dateTimeString)
    }

    private func setViewsToTheirStates() {
        lblAppStatus.isHidden = true
        btnNationalDetails.isHidden = true
        nationalDetailsView.isHidden = true
        nationalDetailsViewWidthConstraint.constant = 0
        nationalDetailsViewHeightConstraint.constant = 0
        self.nationalDetailsViewBottomConstraint.constant = -4
        nationalDetailsView.bringSubviewToFront(btnNationalDetails)
    }

    //This methods converts date to a string in Singapore timezone.
    func getSingaporeDateTimeFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "SGT")
        var dateTimeString = dateFormatter.string(from: date)
        dateTimeString = dateTimeString.replacingOccurrences(of: " ", with: "T")
        return dateTimeString
    }

    fileprivate func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    fileprivate func updateAppStatus(with appHealth: String) {

        let statusAttributedString = NSMutableAttributedString(
            string: "App Status:- ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        let healthyColor = appHealth == "healthy" ? UIColor.green : UIColor.orange
        statusAttributedString.append(
            NSAttributedString(string: appHealth,
                               attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                                            NSAttributedString.Key.foregroundColor: healthyColor]))
        DispatchQueue.main.async {[unowned self] in
            self.lblAppStatus.alpha = 0
            self.lblAppStatus.isHidden = false
            self.lblAppStatus.attributedText = statusAttributedString

            UIView.animate(withDuration: 1.5, delay: 1.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.lblAppStatus.alpha = 1
                self.view.layoutIfNeeded()
            }, completion: nil)

        }
    }

    fileprivate func createAnnotationsForAllCardinalDirectionsWith(_ pollutionDetails: PollutionDetails) {
        var annotationsArray = [PollutionAnnotation]()
        for index in 0..<pollutionDetails.regionsMetadata.count {
            let psiMetaData = pollutionDetails.regionsMetadata[index]
            let psiReading = pollutionDetails.items[0].psiReadings
            if psiMetaData.direction != "national" {
                let detailsTouple = self.getMetaDataStringWith(psiReading, with: psiMetaData.direction)
                let pollutionAnnotation = PollutionAnnotation(title: detailsTouple.direction,
                                                              pollutionDetails: detailsTouple.metaData,
                                      coordinate: CLLocationCoordinate2D(
                                        latitude: psiMetaData.location.latitude,
                                        longitude: psiMetaData.location.longitude))
                annotationsArray.append(pollutionAnnotation)
            } else {
                nationalMetaDataDetails = self.getMetaDataStringWith(psiReading, with: psiMetaData.direction)
                DispatchQueue.main.async {[unowned self] in
                    self.btnNationalDetails.isHidden = false
                }
            }
        }
        DispatchQueue.main.async {[unowned self] in
            self.mapView.addAnnotations(annotationsArray)
        }
    }

    fileprivate func getMetaDataStringWith(_ psiReading: PSIReading,
                                           with direction: String) -> (direction: String, metaData: String) {
        var metaDataString = ""
        var directionStr = ""
        switch direction {
        case CardinalDirections.north.rawValue:
            directionStr = "North"
            metaDataString = "o3SubIndex:\t\t\t\t \(psiReading.o3SubIndex.north)\n"
            metaDataString.append("pm10TwentyFourHourly:\t \(psiReading.pm10TwentyFourHourly.north)\n")
            metaDataString.append("pm10SubIndex:\t\t\t \(psiReading.pm10SubIndex.north)\n")
            metaDataString.append("coSubIndex:\t\t\t\t \(psiReading.coSubIndex.north)\n")
            metaDataString.append("pm25TwentyFourHourly:\t \(psiReading.pm25TwentyFourHourly.north)\n")
            metaDataString.append("so2SubIndex:\t\t\t\t \(psiReading.so2SubIndex.north)\n")
            metaDataString.append("coEightHourMax:\t\t\t \(psiReading.coEightHourMax.north)\n")
            metaDataString.append("no2OneHourMax:\t\t\t \(psiReading.no2OneHourMax.north)\n")
            metaDataString.append("so2TwentyFourHourly:\t \(psiReading.so2TwentyFourHourly.north)\n")
            metaDataString.append("pm25SubIndex:\t\t\t \(psiReading.pm25SubIndex.north)\n")
            metaDataString.append("psiTwentyFourHourly:\t\t \(psiReading.psiTwentyFourHourly.north)\n")
            metaDataString.append("o3EightHourMax:\t\t\t \(psiReading.o3EightHourMax.north)")
        case CardinalDirections.south.rawValue:
            directionStr = "South"
            metaDataString = "o3SubIndex:\t\t\t\t \(psiReading.o3SubIndex.south)\n"
            metaDataString.append("pm10TwentyFourHourly:\t \(psiReading.pm10TwentyFourHourly.south)\n")
            metaDataString.append("pm10SubIndex:\t\t\t \(psiReading.pm10SubIndex.south)\n")
            metaDataString.append("coSubIndex:\t\t\t\t \(psiReading.coSubIndex.south)\n")
            metaDataString.append("pm25TwentyFourHourly:\t \(psiReading.pm25TwentyFourHourly.south)\n")
            metaDataString.append("so2SubIndex:\t\t\t\t \(psiReading.so2SubIndex.south)\n")
            metaDataString.append("coEightHourMax:\t\t\t \(psiReading.coEightHourMax.south)\n")
            metaDataString.append("no2OneHourMax:\t\t\t \(psiReading.no2OneHourMax.south)\n")
            metaDataString.append("so2TwentyFourHourly:\t \(psiReading.so2TwentyFourHourly.south)\n")
            metaDataString.append("pm25SubIndex:\t\t\t \(psiReading.pm25SubIndex.south)\n")
            metaDataString.append("psiTwentyFourHourly:\t\t \(psiReading.psiTwentyFourHourly.south)\n")
            metaDataString.append("o3EightHourMax:\t\t\t \(psiReading.o3EightHourMax.south)")
        case CardinalDirections.east.rawValue:
            directionStr = "East"
            metaDataString = "o3SubIndex:\t\t\t\t \(psiReading.o3SubIndex.east)\n"
            metaDataString.append("pm10TwentyFourHourly:\t \(psiReading.pm10TwentyFourHourly.east)\n")
            metaDataString.append("pm10SubIndex:\t\t\t \(psiReading.pm10SubIndex.east)\n")
            metaDataString.append("coSubIndex:\t\t\t\t \(psiReading.coSubIndex.east)\n")
            metaDataString.append("pm25TwentyFourHourly:\t \(psiReading.pm25TwentyFourHourly.east)\n")
            metaDataString.append("so2SubIndex:\t\t\t\t \(psiReading.so2SubIndex.east)\n")
            metaDataString.append("coEightHourMax:\t\t\t \(psiReading.coEightHourMax.east)\n")
            metaDataString.append("no2OneHourMax:\t\t\t \(psiReading.no2OneHourMax.east)\n")
            metaDataString.append("so2TwentyFourHourly:\t \(psiReading.so2TwentyFourHourly.east)\n")
            metaDataString.append("pm25SubIndex:\t\t\t \(psiReading.pm25SubIndex.east)\n")
            metaDataString.append("psiTwentyFourHourly:\t\t \(psiReading.psiTwentyFourHourly.east)\n")
            metaDataString.append("o3EightHourMax:\t\t\t \(psiReading.o3EightHourMax.east)")
        case CardinalDirections.west.rawValue:
            directionStr = "West"
            metaDataString = "o3SubIndex:\t\t\t\t \(psiReading.o3SubIndex.west)\n"
            metaDataString.append("pm10TwentyFourHourly:\t \(psiReading.pm10TwentyFourHourly.west)\n")
            metaDataString.append("pm10SubIndex:\t\t\t \(psiReading.pm10SubIndex.west)\n")
            metaDataString.append("coSubIndex:\t\t\t\t \(psiReading.coSubIndex.west)\n")
            metaDataString.append("pm25TwentyFourHourly:\t \(psiReading.pm25TwentyFourHourly.west)\n")
            metaDataString.append("so2SubIndex:\t\t\t\t \(psiReading.so2SubIndex.west)\n")
            metaDataString.append("coEightHourMax:\t\t\t \(psiReading.coEightHourMax.west)\n")
            metaDataString.append("no2OneHourMax:\t\t\t \(psiReading.no2OneHourMax.west)\n")
            metaDataString.append("so2TwentyFourHourly:\t \(psiReading.so2TwentyFourHourly.west)\n")
            metaDataString.append("pm25SubIndex:\t\t\t \(psiReading.pm25SubIndex.west)\n")
            metaDataString.append("psiTwentyFourHourly:\t\t \(psiReading.psiTwentyFourHourly.west)\n")
            metaDataString.append("o3EightHourMax:\t\t\t \(psiReading.o3EightHourMax.west)")
        case CardinalDirections.central.rawValue:
            directionStr = "Central"
            metaDataString = "o3SubIndex:\t\t\t\t \(psiReading.o3SubIndex.central)\n"
            metaDataString.append("pm10TwentyFourHourly:\t \(psiReading.pm10TwentyFourHourly.central)\n")
            metaDataString.append("pm10SubIndex:\t\t\t \(psiReading.pm10SubIndex.central)\n")
            metaDataString.append("coSubIndex:\t\t\t\t \(psiReading.coSubIndex.central)\n")
            metaDataString.append("pm25TwentyFourHourly:\t \(psiReading.pm25TwentyFourHourly.central)\n")
            metaDataString.append("so2SubIndex:\t\t\t\t \(psiReading.so2SubIndex.central)\n")
            metaDataString.append("coEightHourMax:\t\t\t \(psiReading.coEightHourMax.central)\n")
            metaDataString.append("no2OneHourMax:\t\t\t \(psiReading.no2OneHourMax.central)\n")
            metaDataString.append("so2TwentyFourHourly:\t \(psiReading.so2TwentyFourHourly.central)\n")
            metaDataString.append("pm25SubIndex:\t\t\t \(psiReading.pm25SubIndex.central)\n")
            metaDataString.append("psiTwentyFourHourly:\t\t \(psiReading.psiTwentyFourHourly.central)\n")
            metaDataString.append("o3EightHourMax:\t\t\t \(psiReading.o3EightHourMax.central)")
        case CardinalDirections.national.rawValue:
            directionStr = "National"
            metaDataString = "o3SubIndex:\t\t\t\t \(psiReading.o3SubIndex.national)\n"
            metaDataString.append("pm10TwentyFourHourly:\t \(psiReading.pm10TwentyFourHourly.national)\n")
            metaDataString.append("pm10SubIndex:\t\t\t\t \(psiReading.pm10SubIndex.national)\n")
            metaDataString.append("coSubIndex:\t\t\t\t \(psiReading.coSubIndex.national)\n")
            metaDataString.append("pm25TwentyFourHourly:\t \(psiReading.pm25TwentyFourHourly.national)\n")
            metaDataString.append("so2SubIndex:\t\t\t\t \(psiReading.so2SubIndex.national)\n")
            metaDataString.append("coEightHourMax:\t\t\t \(psiReading.coEightHourMax.national)\n")
            metaDataString.append("no2OneHourMax:\t\t\t \(psiReading.no2OneHourMax.national)\n")
            metaDataString.append("so2TwentyFourHourly:\t\t \(psiReading.so2TwentyFourHourly.national)\n")
            metaDataString.append("pm25SubIndex:\t\t\t \(psiReading.pm25SubIndex.national)\n")
            metaDataString.append("psiTwentyFourHourly:\t\t \(psiReading.psiTwentyFourHourly.national)\n")
            metaDataString.append("o3EightHourMax:\t\t\t \(psiReading.o3EightHourMax.national)")
        default:
            metaDataString = ""
            directionStr = ""
        }
        return (directionStr, metaDataString)
    }

    private func nationalDetailsViewCurveEaseOutAnimation() {
        self.nationalDetailsView.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.nationalDetailsViewWidthConstraint.constant = 282
            self.nationalDetailsViewHeightConstraint.constant = 280
            self.nationalDetailsViewLeadingConstraint.constant = 32
            self.nationalDetailsViewBottomConstraint.constant = 16
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    private func nationalDetailsViewCurveEaseInAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.nationalDetailsViewWidthConstraint.constant = 0
            self.nationalDetailsViewHeightConstraint.constant = 0
            self.nationalDetailsViewLeadingConstraint.constant = 56
            self.nationalDetailsViewBottomConstraint.constant = -4
            self.view.layoutIfNeeded()
        }) { (_) in
            self.nationalDetailsView.isHidden = true
        }
    }

    // MARK: - IBAction Methods
    @IBAction func showNationalPollutionDetails(_ sender: UIButton) {
        lblNationalDetails.text = "\(nationalMetaDataDetails.0)\n\(nationalMetaDataDetails.1)"
        if self.nationalDetailsView.isHidden {
            self.nationalDetailsViewCurveEaseOutAnimation()
        } else {
            self.nationalDetailsViewCurveEaseInAnimation()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.nationalDetailsView.isHidden == false {
            self.nationalDetailsViewCurveEaseInAnimation()
        }
    }

}

// MARK: - MapKit Delegate methods
extension PSIViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PollutionAnnotation else { return nil }
        let annotationViewIdentifier = "annotationViewIdentifier"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewIdentifier)
            as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationViewIdentifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
        }

         let subTitleLabel = UILabel()
         subTitleLabel.text = annotation.pollutionDetails

         view.detailCalloutAccessoryView = subTitleLabel
        view.animatesDrop = true
         let widthConstraint = NSLayoutConstraint(item: subTitleLabel,
                                                  attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil,
                                                  attribute: .notAnAttribute, multiplier: 1, constant: 250)
         let heightConstraint = NSLayoutConstraint(item: subTitleLabel,
                                                   attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil,
                                                   attribute: .notAnAttribute, multiplier: 1, constant: 0)

         subTitleLabel.numberOfLines = 0
         subTitleLabel.addConstraints([widthConstraint, heightConstraint])

        return view
    }
}

// MARK: - Api calls
extension PSIViewController {

    //This method is used for generating pollutionApi URL String
    private func generatePollutionApiURL(with dateTime: String) -> String {
        let endPointURL = "?date_time=\(dateTime)"
        let hostURL = "\(baseURL)\(endPointURL)"
        return hostURL
    }

    //This method is used for getting pollutionApi URLRequest
    func getPollutionApiRequest(with dateTime: String) -> URLRequest? {
        if let request: URLRequest = self.baseRequestForURL(url:
            self.generatePollutionApiURL(with: dateTime), method: "GET") {
            return request
        }
        return nil
    }

    //This method is used to provide basic common information required while creating URLRequest.
    private func baseRequestForURL(url: String, contentType: String? = nil, httpBody: [String: Any]? = nil,
                                   method: String) -> URLRequest? {
        if let url = URL(string: url) {
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = method
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let body = httpBody as? [String: String], method == "POST" || method == "PUT" {
                let jsonData = try? JSONSerialization.data(withJSONObject: body)
                request.httpBody = jsonData
            }
            return request as URLRequest
        } else {
            return nil
        }
    }

    //This method is used for getting pollution details from API
    fileprivate func getPollutionDetailsFor(dateTime: String) {
        let defaultSession = URLSession(configuration: .default)

        let dataTask = defaultSession.dataTask(with: self.getPollutionApiRequest(with: dateTime)!) { [unowned self] data, response, error in
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                guard let pollutionData = data else { return }
                do {
                    let pollutionDetails = try JSONDecoder().decode(PollutionDetails.self, from: pollutionData)
                    self.updateAppStatus(with: pollutionDetails.appInfo.status)
                    self.createAnnotationsForAllCardinalDirectionsWith(pollutionDetails)
                } catch {
                    print("JSON Data Parsing Error : \(error)")
                }

            } else {

            }
        }
        dataTask.resume()
    }

}
