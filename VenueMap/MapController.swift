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

class MapController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

  let locationManager: CLLocationManager = CLLocationManager()
  
  var currentLocation: CLLocation? = nil
  var selectedVenue: Venue? = nil
  
  @IBOutlet var mapView: MKMapView? = nil
  @IBOutlet var button: UIButton? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.requestWhenInUseAuthorization()
    locationManager.delegate = self
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Pass the selected Venue to the detail controller.
    if let detailController = segue.destination as? VenueDetailController {
      detailController.venue = selectedVenue
    }
  }
  
  // MARK: Buttons
  
  @IBAction func getVenuesButtonPressed() {
    // Send a request to Foursquare asking for venues around the current location.
    Foursquare.searchVenuesAroundLocation(currentLocation!) { (venues) in
      var annotations = Array<VenueAnnotation>()
      for venue in venues {
        let annotation = VenueAnnotation()
        annotation.coordinate = venue.coordinate
        annotation.title = venue.name
        annotation.venue = venue
        annotations.append(annotation)
      }
      
      DispatchQueue.main.async {
        self.mapView?.addAnnotations(annotations)
      }
    }
  }
  
  func venueDetailButtonPressed() {
    performSegue(withIdentifier: "VenueDetail", sender: self)
  }

  // MARK: CLLocationManagerDelegate
  
  func locationManager(_ manager: CLLocationManager,
                       didChangeAuthorization status: CLAuthorizationStatus) {
    manager.requestLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations.last!
    currentLocation = location
    
    var region = MKCoordinateRegion()
    region.center = location.coordinate
    region.span = MKCoordinateSpanMake(0.005, 0.005)
    
    mapView?.setRegion(region, animated: true)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
  
  // MARK: MKMapViewDelegate
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation === mapView.userLocation {
      return nil
    }
    
    // Create a pin annotation.
    let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
    annotationView.animatesDrop = true
    annotationView.canShowCallout = true
    
    // Add the detail button to the right of the callout bubble when the pin is pressed.
    let detailButton = UIButton(type: .detailDisclosure)
    detailButton.addTarget(self,
                           action: #selector(MapController.venueDetailButtonPressed),
                           for: .touchUpInside)
    annotationView.rightCalloutAccessoryView = detailButton
    
    return annotationView
  }
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    // Keep a reference to the selected Venue so we can use it later.
    if let venueAnnotation = view.annotation as? VenueAnnotation {
      selectedVenue = venueAnnotation.venue
    }
  }

}

class VenueAnnotation: MKPointAnnotation {
  var venue: Venue? = nil
}
