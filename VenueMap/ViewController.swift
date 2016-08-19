//
//  ViewController.swift
//  VenueMap
//
//  Created by Rafael Cardenas on 8/18/16.
//  Copyright © 2016 Rafael Cardenas. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {

  let locationManager: CLLocationManager = CLLocationManager()
  @IBOutlet var mapView: MKMapView? = nil
  @IBOutlet var button: UIButton? = nil

  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.requestWhenInUseAuthorization()
    locationManager.delegate = self
  }

  // MARK: Button
  
  @IBAction func buttonPressed() {
    
  }

  // MARK: CLLocationManagerDelegate
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    manager.requestLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations.last!
    
    var region = MKCoordinateRegion()
    region.center = location.coordinate
    region.span = MKCoordinateSpanMake(0.05, 0.05)
    
    mapView?.setRegion(region, animated: true)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: NSError) {
    print(error)
  }

}

