//
//  PSIViewController.swift
//  SingaporePSI
//
//  Created by Krishna Singana on 10/12/19.
//  Copyright © 2019 Krishna Singana. All rights reserved.
//

import UIKit
import MapKit

class PSIViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblAppStatus: UILabel!
    
    fileprivate let regionRadius: CLLocationDistance = 66000
    fileprivate let baseURL = "https://api.data.gov.sg/v1/environment/psi"

    override func viewDidLoad() {
        super.viewDidLoad()

        lblAppStatus.isHidden = true
        
        // set initial location to Singapore
        let initialLocationOnMap = CLLocation(latitude: 1.35735, longitude: 103.82)
        self.centerMapOnLocation(location: initialLocationOnMap)

        mapView.delegate = self

        self.getPollutionDetailsFor(date: "2019-12-10", dateTime: nil)
    }

    fileprivate func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    fileprivate func updateAppStatus(with appHealth : String) {
        
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
}

extension PSIViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PollutionAnnotation else { return nil }
        let annotationViewIdentifier = "annotationViewIdentifier"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewIdentifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationViewIdentifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
        }
        return view
    }
}

// MARK: - Api calls
extension PSIViewController {

    //This method is used for generating pollutionApi URL String
    private func generatePollutionApiURL(with date: String, dateTime: String?) -> String {
        var endPointURL = "?date=\(date)"
        if let dateTimeValue = dateTime {
            endPointURL.append("&date_time=\(dateTimeValue)")
        }
        let hostURL = "\(baseURL)\(endPointURL)"
        return hostURL
    }

    //This method is used for getting pollutionApi URLRequest
    func getPollutionApiRequest(with date: String, dateTime: String?) -> URLRequest? {
        if let request: URLRequest = self.baseRequestForURL(url:
            self.generatePollutionApiURL(with: date, dateTime: dateTime), method: "GET") {
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
    fileprivate func getPollutionDetailsFor(date: String, dateTime: String?) {
        let defaultSession = URLSession(configuration: .default)

        let dataTask = defaultSession.dataTask(with: self.getPollutionApiRequest(with: date, dateTime: dateTime)!)
        { [unowned self] data, response, error in
            if (response as? HTTPURLResponse)?.statusCode == 200 {
                guard let pollutionData = data else { return }
                do {
                    let pollutionDetails = try JSONDecoder().decode(PollutionDetails.self, from: pollutionData)
                    self.updateAppStatus(with: pollutionDetails.appInfo.status)
                } catch {
                    print("JSON Data Parsing Error : \(error)")
                }

            } else {

            }
        }
        dataTask.resume()
    }
}
