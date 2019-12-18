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
    @IBOutlet weak var btnInformation: UIButton!
    @IBOutlet weak var informationDetailsView: UIView!
    @IBOutlet weak var lblInformationDetails: UILabel!
    @IBOutlet weak var informationViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var informationViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var informationViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var informationViewBottomConstraint: NSLayoutConstraint!

    fileprivate let regionRadius: CLLocationDistance = 60000
    fileprivate let baseURL = "https://api.data.gov.sg/v1/environment/psi"
    fileprivate var nationalMetaDataDetails = ("", NSMutableAttributedString())

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setViewsToTheirStates()
        self.customiseNavigationBar()

        // set initial location to Singapore
        let initialLocationOnMap = CLLocation(latitude: 1.35735, longitude: 103.85)
        self.centerMapOnLocation(location: initialLocationOnMap)
        mapView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        let dateTimeString = self.getSingaporeDateTimeFromDate(date: Date())
        self.getPollutionDetailsFor(dateTime: dateTimeString)
    }

    //  Setting up view's position to support animation
    private func setViewsToTheirStates() {
        lblAppStatus.isHidden = true
        btnNationalDetails.isHidden = true
        nationalDetailsView.isHidden = true
        nationalDetailsViewWidthConstraint.constant = 0
        nationalDetailsViewHeightConstraint.constant = 0
        nationalDetailsViewBottomConstraint.constant = -4
        btnInformation.isHidden = true
        informationDetailsView.isHidden = true
        informationViewWidthConstraint.constant = 0
        informationViewHeightConstraint.constant = 0
        informationViewBottomConstraint.constant = -4
    }

    // This is used for customising navigation bar
    fileprivate func customiseNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.53, green: 0.53, blue: 0.53, alpha: 0.7)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }

    //  This methods converts date to a string in Singapore timezone.
    func getSingaporeDateTimeFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "SGT")
        var dateTimeString = dateFormatter.string(from: date)
        dateTimeString = dateTimeString.replacingOccurrences(of: " ", with: "T")
        return dateTimeString
    }

    //  This method is used for showing complete singapore map on screen.
    fileprivate func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    //  This method is used for updating Enviornment status after fetching info from api.
    fileprivate func updateAppStatus(with appHealth: String) {
        let statusAttributedString = NSMutableAttributedString(
            string: "Enviornment Status:- ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
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

    //  This is used for creating Pin Annonations based on Location points that fetched from api.
    fileprivate func createAnnotationsForAllCardinalDirectionsWith(_ pollutionDetails: PollutionDetails) {
        var annotationsArray = [PollutionAnnotation]()
        let count = pollutionDetails.regionsMetadata?.count ?? 0
        for index in 0..<count {
            let psiMetaData = pollutionDetails.regionsMetadata?[index]
            let psiReading = pollutionDetails.items?[0].psiReadings
            if psiMetaData?.direction != "national" {
                let detailsTouple = self.getMetaDataStringWith(psiReading, with: psiMetaData?.direction ?? "")
                let pollutionAnnotation = PollutionAnnotation(title: "",
                                                              pollutionDetails: detailsTouple.metaData,
                                      coordinate: CLLocationCoordinate2D(
                                        latitude: psiMetaData?.location?.latitude ?? 0.0,
                                        longitude: psiMetaData?.location?.longitude ?? 0.0))
                annotationsArray.append(pollutionAnnotation)
            } else {
                nationalMetaDataDetails = self.getMetaDataStringWith(psiReading, with: psiMetaData?.direction ?? "")
                DispatchQueue.main.async {[unowned self] in
                    self.btnNationalDetails.isHidden = false
                    self.btnInformation.isHidden = false
                }
            }
        }
        DispatchQueue.main.async {[unowned self] in
            if count <= 0 {
                self.showUnableToLoadDataAlert()
            } else {
                self.mapView.addAnnotations(annotationsArray)
            }
        }
    }

    //  This method is used for generating complete Attributed string with respective pollution data for
    //  different cordinal directions.
    fileprivate func getMetaDataStringWith(_ psiReading: PSIReading?,
                                           with direction: String) ->
        (direction: String, metaData: NSMutableAttributedString) {
            guard let psiReading = psiReading else {
                return ("", NSMutableAttributedString())
            }
        var metaDataString = NSMutableAttributedString()
        var directionStr = ""
        switch direction {
        case CardinalDirections.north.rawValue:
            self.getTitleAttributedStringWith(dataStr: "PSI Readings: North\n", attributedStr: &metaDataString)
            self.getCompleteAttributedMetaDataStringForNorth(psiReadings: psiReading, metaDataString: &metaDataString)
        case CardinalDirections.south.rawValue:
            self.getTitleAttributedStringWith(dataStr: "PSI Readings: South\n", attributedStr: &metaDataString)
            self.getCompleteAttributedMetaDataStringForSouth(psiReadings: psiReading, metaDataString: &metaDataString)
        case CardinalDirections.east.rawValue:
            self.getTitleAttributedStringWith(dataStr: "PSI Readings: East\n", attributedStr: &metaDataString)
            self.getCompleteAttributedMetaDataStringForEast(psiReadings: psiReading, metaDataString: &metaDataString)
        case CardinalDirections.west.rawValue:
            self.getTitleAttributedStringWith(dataStr: "PSI Readings: West\n", attributedStr: &metaDataString)
            self.getCompleteAttributedMetaDataStringForWest(psiReadings: psiReading, metaDataString: &metaDataString)
        case CardinalDirections.central.rawValue:
            self.getTitleAttributedStringWith(dataStr: "PSI Readings: Central\n", attributedStr: &metaDataString)
            self.getCompleteAttributedMetaDataStringForCentral(psiReadings: psiReading, metaDataString: &metaDataString)
        case CardinalDirections.national.rawValue:
            self.getTitleAttributedStringWith(dataStr: "PSI Readings: National\n", attributedStr: &metaDataString)
            self.getCompleteAttributedMetaDataStringForNational(psiReadings: psiReading, metaDataString: &metaDataString)
        default:
            directionStr = ""
        }
        return (directionStr, metaDataString)
    }

    //  This method is used for adding attributes for title message
    internal func getTitleAttributedStringWith(dataStr: String, attributedStr : inout NSMutableAttributedString) {
        attributedStr = NSMutableAttributedString(attributedString:
            NSAttributedString(string: dataStr, attributes:
                [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                 NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]))
    }

    //  This method is used for generating Attributed string for North.
    private func getCompleteAttributedMetaDataStringForNorth(psiReadings: PSIReading?,
                                                             metaDataString: inout NSMutableAttributedString) {
        guard let psiReading = psiReadings else {
            return
        }
        self.combineStringsIntoAttributedStringWith(dataStr: "\(psiTwentyFourHourly):\t\t\t",
            valueStr: " \(psiReading.psiTwentyFourHourly?.north ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(o3SubIndex):\t\t\t",
            valueStr: " \(psiReading.o3SubIndex?.north ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(o3EightHourMax):\t\t",
            valueStr: " \(psiReading.o3EightHourMax?.north ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm10SubIndex):\t\t\t",
            valueStr: " \(psiReading.pm10SubIndex?.north ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm10TwentyFourHourly):\t\t",
            valueStr: " \(psiReading.pm10TwentyFourHourly?.north ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm25SubIndex):\t\t\t",
            valueStr: " \(psiReading.pm25SubIndex?.north ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm25TwentyFourHourly):\t\t",
            valueStr: " \(psiReading.pm25TwentyFourHourly?.north ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(coSubIndex):\t\t\t\t",
            valueStr: " \(psiReading.coSubIndex?.north ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(coEightHourMax):\t\t",
            valueStr: " \(psiReading.coEightHourMax?.north ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(so2SubIndex):\t\t\t",
            valueStr: " \(psiReading.so2SubIndex?.north ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(so2TwentyFourHourly):\t\t\t",
            valueStr: " \(psiReading.so2TwentyFourHourly?.north ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(no2OneHourMax):\t\t\t",
            valueStr: " \(psiReading.no2OneHourMax?.north ?? 0)\n", attributedString: &metaDataString)
    }

    //  This method is used for generating Attributed string for South.
    private func getCompleteAttributedMetaDataStringForSouth(psiReadings: PSIReading?,
                                                             metaDataString: inout NSMutableAttributedString) {
        guard let psiReading = psiReadings else {
            return
        }
        self.combineStringsIntoAttributedStringWith(dataStr: "\(psiTwentyFourHourly):\t\t\t",
            valueStr: " \(psiReading.psiTwentyFourHourly?.south ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(o3SubIndex):\t\t\t",
            valueStr: " \(psiReading.o3SubIndex?.south ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(o3EightHourMax):\t\t",
            valueStr: " \(psiReading.o3EightHourMax?.south ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm10SubIndex):\t\t\t",
            valueStr: " \(psiReading.pm10SubIndex?.south ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm10TwentyFourHourly):\t\t",
            valueStr: " \(psiReading.pm10TwentyFourHourly?.south ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm25SubIndex):\t\t\t",
            valueStr: " \(psiReading.pm25SubIndex?.south ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm25TwentyFourHourly):\t\t",
            valueStr: " \(psiReading.pm25TwentyFourHourly?.south ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(coSubIndex):\t\t\t\t",
            valueStr: " \(psiReading.coSubIndex?.south ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(coEightHourMax):\t\t",
            valueStr: " \(psiReading.coEightHourMax?.south ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(so2SubIndex):\t\t\t",
            valueStr: " \(psiReading.so2SubIndex?.south ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(so2TwentyFourHourly):\t\t\t",
            valueStr: " \(psiReading.so2TwentyFourHourly?.south ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(no2OneHourMax):\t\t\t",
            valueStr: " \(psiReading.no2OneHourMax?.south ?? 0)\n", attributedString: &metaDataString)
    }

    //  This method is used for generating Attributed string for West.
    private func getCompleteAttributedMetaDataStringForWest(psiReadings: PSIReading?,
                                                            metaDataString: inout NSMutableAttributedString) {
        guard let psiReading = psiReadings else {
            return
        }
        self.combineStringsIntoAttributedStringWith(dataStr: "\(psiTwentyFourHourly):\t\t\t",
            valueStr: " \(psiReading.psiTwentyFourHourly?.west ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(o3SubIndex):\t\t\t",
            valueStr: " \(psiReading.o3SubIndex?.west ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(o3EightHourMax):\t\t",
            valueStr: " \(psiReading.o3EightHourMax?.west ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm10SubIndex):\t\t\t",
            valueStr: " \(psiReading.pm10SubIndex?.west ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm10TwentyFourHourly):\t\t",
            valueStr: " \(psiReading.pm10TwentyFourHourly?.west ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm25SubIndex):\t\t\t",
            valueStr: " \(psiReading.pm25SubIndex?.west ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm25TwentyFourHourly):\t\t",
            valueStr: " \(psiReading.pm25TwentyFourHourly?.west ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(coSubIndex):\t\t\t\t",
            valueStr: " \(psiReading.coSubIndex?.west ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(coEightHourMax):\t\t",
            valueStr: " \(psiReading.coEightHourMax?.west ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(so2SubIndex):\t\t\t",
            valueStr: " \(psiReading.so2SubIndex?.west ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(so2TwentyFourHourly):\t\t\t",
            valueStr: " \(psiReading.so2TwentyFourHourly?.west ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(no2OneHourMax):\t\t\t",
            valueStr: " \(psiReading.no2OneHourMax?.west ?? 0)\n", attributedString: &metaDataString)
    }

    //  This method is used for generating Attributed string for East.
    private func getCompleteAttributedMetaDataStringForEast(psiReadings: PSIReading?,
                                                            metaDataString: inout NSMutableAttributedString) {
        guard let psiReading = psiReadings else {
            return
        }
        self.combineStringsIntoAttributedStringWith(dataStr: "\(psiTwentyFourHourly):\t\t\t",
            valueStr: " \(psiReading.psiTwentyFourHourly?.east ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(o3SubIndex):\t\t\t",
            valueStr: " \(psiReading.o3SubIndex?.east ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(o3EightHourMax):\t\t",
            valueStr: " \(psiReading.o3EightHourMax?.east ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm10SubIndex):\t\t\t",
            valueStr: " \(psiReading.pm10SubIndex?.east ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm10TwentyFourHourly):\t\t",
            valueStr: " \(psiReading.pm10TwentyFourHourly?.east ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm25SubIndex):\t\t\t",
            valueStr: " \(psiReading.pm25SubIndex?.east ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm25TwentyFourHourly):\t\t",
            valueStr: " \(psiReading.pm25TwentyFourHourly?.east ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(coSubIndex):\t\t\t\t",
            valueStr: " \(psiReading.coSubIndex?.east ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(coEightHourMax):\t\t",
            valueStr: " \(psiReading.coEightHourMax?.east ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(so2SubIndex):\t\t\t",
            valueStr: " \(psiReading.so2SubIndex?.east ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(so2TwentyFourHourly):\t\t\t",
            valueStr: " \(psiReading.so2TwentyFourHourly?.east ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(no2OneHourMax):\t\t\t",
            valueStr: " \(psiReading.no2OneHourMax?.east ?? 0)\n", attributedString: &metaDataString)
    }

    //  This method is used for generating Attributed string for Central.
    private func getCompleteAttributedMetaDataStringForCentral(psiReadings: PSIReading?,
                                                               metaDataString: inout NSMutableAttributedString) {
        guard let psiReading = psiReadings else {
            return
        }
        self.combineStringsIntoAttributedStringWith(dataStr: "\(psiTwentyFourHourly):\t\t\t",
            valueStr: " \(psiReading.psiTwentyFourHourly?.central ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(o3SubIndex):\t\t\t",
            valueStr: " \(psiReading.o3SubIndex?.central ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(o3EightHourMax):\t\t",
            valueStr: " \(psiReading.o3EightHourMax?.central ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm10SubIndex):\t\t\t",
            valueStr: " \(psiReading.pm10SubIndex?.central ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm10TwentyFourHourly):\t\t",
            valueStr: " \(psiReading.pm10TwentyFourHourly?.central ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm25SubIndex):\t\t\t",
            valueStr: " \(psiReading.pm25SubIndex?.central ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm25TwentyFourHourly):\t\t",
            valueStr: " \(psiReading.pm25TwentyFourHourly?.central ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(coSubIndex):\t\t\t\t",
            valueStr: " \(psiReading.coSubIndex?.central ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(coEightHourMax):\t\t",
            valueStr: " \(psiReading.coEightHourMax?.central ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(so2SubIndex):\t\t\t",
            valueStr: " \(psiReading.so2SubIndex?.central ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(so2TwentyFourHourly):\t\t\t",
            valueStr: " \(psiReading.so2TwentyFourHourly?.central ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(no2OneHourMax):\t\t\t",
            valueStr: " \(psiReading.no2OneHourMax?.central ?? 0)\n", attributedString: &metaDataString)
    }

    //  This method is used for generating Attributed string for National.
    private func getCompleteAttributedMetaDataStringForNational(psiReadings: PSIReading?,
                                                                metaDataString: inout NSMutableAttributedString) {
        guard let psiReading = psiReadings else {
            return
        }
        self.combineStringsIntoAttributedStringWith(dataStr: "\(psiTwentyFourHourly):\t\t\t",
            valueStr: " \(psiReading.psiTwentyFourHourly?.national ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(o3SubIndex):\t\t\t",
            valueStr: " \(psiReading.o3SubIndex?.national ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(o3EightHourMax):\t\t",
            valueStr: " \(psiReading.o3EightHourMax?.national ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm10SubIndex):\t\t\t",
            valueStr: " \(psiReading.pm10SubIndex?.national ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm10TwentyFourHourly):\t\t",
            valueStr: " \(psiReading.pm10TwentyFourHourly?.national ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm25SubIndex):\t\t\t",
            valueStr: " \(psiReading.pm25SubIndex?.national ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(pm25TwentyFourHourly):\t\t",
            valueStr: " \(psiReading.pm25TwentyFourHourly?.national ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(coSubIndex):\t\t\t\t",
            valueStr: " \(psiReading.coSubIndex?.national ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(coEightHourMax):\t\t\t",
            valueStr: " \(psiReading.coEightHourMax?.national ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(so2SubIndex):\t\t\t\t",
            valueStr: " \(psiReading.so2SubIndex?.national ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(so2TwentyFourHourly):\t\t\t",
            valueStr: " \(psiReading.so2TwentyFourHourly?.national ?? 0)\n", attributedString: &metaDataString)
        self.combineStringsIntoAttributedStringWith(dataStr: "\(no2OneHourMax):\t\t\t",
            valueStr: " \(psiReading.no2OneHourMax?.national ?? 0)\n", attributedString: &metaDataString)
    }

    //  This method is used for combining data and value strings and appending it to attrinutrd string
    internal func combineStringsIntoAttributedStringWith(
        dataStr: String, valueStr: String, attributedString metaDataStr : inout NSMutableAttributedString) {
        metaDataStr.append(NSMutableAttributedString(
            string: dataStr, attributes: [NSAttributedString.Key.backgroundColor: UIColor.clear]))
        metaDataStr.append(NSMutableAttributedString(string: valueStr,
            attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                         NSAttributedString.Key.backgroundColor: UIColor.clear]))

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
        metaDataStr.addAttribute(NSAttributedString.Key.paragraphStyle,
                                 value: paragraphStyle, range: NSRange(location: 0, length: metaDataStr.length))
    }

    //  This method is used for creating attributed string with string full forms that showed on click of info button.
    fileprivate func getCompleteInformationAttributedString(with infoAttributedStr : inout NSMutableAttributedString) {
        self.combineInformationStringsIntoAttributedStringWith(
            dataStr: "PSI:-\t ", valueStr: "Pollutant Standards Index\n", attributedString: &infoAttributedStr)
        self.combineInformationStringsIntoAttributedStringWith(
            dataStr: "PM10:-\t ", valueStr: "10 micrometer Particulate Matter\n", attributedString: &infoAttributedStr)
        self.combineInformationStringsIntoAttributedStringWith(
            dataStr: "PM25:-\t ", valueStr: "2.5 micrometer Particulate Matter\n", attributedString: &infoAttributedStr)
        self.combineInformationStringsIntoAttributedStringWith(
            dataStr: "CO:-\t ", valueStr: "Carbon monooxide\n", attributedString: &infoAttributedStr)
        self.combineInformationStringsIntoAttributedStringWith(
            dataStr: "SO2:-\t ", valueStr: "Sulfur dioxide\n", attributedString: &infoAttributedStr)
        self.combineInformationStringsIntoAttributedStringWith(
            dataStr: "NO2:-\t ", valueStr: "Nitrogen oxide\n", attributedString: &infoAttributedStr)
    }

    //  This method is used for combining data & value string and adding attributes to attributed string.
    private func combineInformationStringsIntoAttributedStringWith(
        dataStr: String, valueStr: String, attributedString metaDataStr : inout NSMutableAttributedString) {
        metaDataStr.append(NSMutableAttributedString(
            string: dataStr, attributes: [NSAttributedString.Key.backgroundColor: UIColor.clear,
                                          NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13)]))
        metaDataStr.append(NSMutableAttributedString(string: valueStr,
            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
                         NSAttributedString.Key.backgroundColor: UIColor.clear]))

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 // Whatever line spacing you want in points
        metaDataStr.addAttribute(NSAttributedString.Key.paragraphStyle,
                                 value: paragraphStyle, range: NSRange(location: 0, length: metaDataStr.length))
    }

    internal func nationalDetailsViewCurveEaseOutAnimation() {
        self.nationalDetailsView.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.nationalDetailsViewWidthConstraint.constant = 282
            self.nationalDetailsViewHeightConstraint.constant = 330
            self.nationalDetailsViewLeadingConstraint.constant = 32
            self.nationalDetailsViewBottomConstraint.constant = 16
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    internal func nationalDetailsViewCurveEaseInAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.nationalDetailsViewWidthConstraint.constant = 0
            self.nationalDetailsViewHeightConstraint.constant = 0
            self.nationalDetailsViewLeadingConstraint.constant = 56
            self.nationalDetailsViewBottomConstraint.constant = -4
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.nationalDetailsView.isHidden = true
        })
    }

    internal func informationViewCurveEaseOutAnimation() {
        self.informationDetailsView.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.informationViewWidthConstraint.constant = 300
            self.informationViewHeightConstraint.constant = 150
            self.informationViewTrailingConstraint.constant = 32
            self.informationViewBottomConstraint.constant = 16
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    internal func informationViewCurveEaseInAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.informationViewWidthConstraint.constant = 0
            self.informationViewHeightConstraint.constant = 0
            self.informationViewTrailingConstraint.constant = 56
            self.informationViewBottomConstraint.constant = -4
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.informationDetailsView.isHidden = true
        })
    }

    fileprivate func deSelectAnnotationViews() {
        let annonations = mapView.annotations
        for index in 0..<annonations.count {
            mapView.deselectAnnotation(annonations[index], animated: true)
        }
    }

    // MARK: - IBAction Methods
    @IBAction func showNationalPollutionDetails(_ sender: UIButton) {
        lblNationalDetails.attributedText = nationalMetaDataDetails.1
        if self.nationalDetailsView.isHidden {
            self.nationalDetailsViewCurveEaseOutAnimation()
        } else {
            self.nationalDetailsViewCurveEaseInAnimation()
        }

        if self.informationDetailsView.isHidden == false {
            self.informationViewCurveEaseInAnimation()
        }
        self.deSelectAnnotationViews()
    }

    @IBAction func showInformation(_ sender: UIButton) {
        var infoAttributesStr = NSMutableAttributedString()
        self.getCompleteInformationAttributedString(with: &infoAttributesStr)
        lblInformationDetails.attributedText = infoAttributesStr
        if self.informationDetailsView.isHidden {
            self.informationViewCurveEaseOutAnimation()
        } else {
            self.informationViewCurveEaseInAnimation()
        }

        if self.nationalDetailsView.isHidden == false {
            self.nationalDetailsViewCurveEaseInAnimation()
        }
        self.deSelectAnnotationViews()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.nationalDetailsView.isHidden == false {
            self.nationalDetailsViewCurveEaseInAnimation()
        } else if self.informationDetailsView.isHidden == false {
            self.informationViewCurveEaseInAnimation()
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
         subTitleLabel.attributedText = annotation.pollutionDetails

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

        let dataTask = defaultSession.dataTask(
        with: self.getPollutionApiRequest(with: dateTime)!) { [unowned self] data, response, error in
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                guard let pollutionData = data else { return }
                do {
                    let pollutionDetails = try JSONDecoder().decode(PollutionDetails.self, from: pollutionData)
                    self.updateAppStatus(with: pollutionDetails.appInfo?.status ?? "")
                    self.createAnnotationsForAllCardinalDirectionsWith(pollutionDetails)
                } catch {
                    print("JSON Data Parsing Error : \(error)")
                    DispatchQueue.main.async {[unowned self] in
                        self.showUnableToLoadDataAlert()
                    }
                }
            } else {
                DispatchQueue.main.async {[unowned self] in
                    self.showUnableToLoadDataAlert()
                }
            }
        }
        dataTask.resume()
    }

    private func showUnableToLoadDataAlert() {
        let errorAlert = UIAlertController(title: "", message: alertMessageString, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in

        }
        errorAlert.addAction(okAction)
        self.present(errorAlert, animated: true)
    }
}
