//
//  ViewController.swift
//  Theater
//
//  Created by SangRae Kim on 1/15/24.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let theaters = TheaterList().mapAnnotations
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ViewController {
    func checkDeviceLocationAuthorization() {
        if CLLocationManager.locationServicesEnabled() {
            
        }
    }
}
