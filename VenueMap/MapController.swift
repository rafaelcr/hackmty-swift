//
//  MapController.swift
//  VenueMap
//
//  Created by Rafael Cardenas on 8/18/16.
//  Copyright © 2016 Rafael Cardenas. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

class MapController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

  let locationManager = CLLocationManager()
  
  var currentLocation: CLLocation?
  var selectedVenue: Venue?
  
  @IBOutlet var mapView: MKMapView?
  @IBOutlet var button: UIButton?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
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
      if let mapView = self.mapView {
        var annotations = Array<VenueAnnotation>()
        for venue in venues {
          let annotation = VenueAnnotation()
          annotation.coordinate = venue.coordinate
          annotation.title = venue.name
          annotation.venue = venue
          annotations.append(annotation)
        }

        DispatchQueue.main.async {
          mapView.removeAnnotations(mapView.annotations)
          mapView.addAnnotations(annotations)
        }
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
    currentLocation = locations.last!
    
    // Zoom the map view around the current location.
    var region = MKCoordinateRegion()
    region.center = currentLocation!.coordinate
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

/// A pin annotation that holds a reference to a `Venue`.
class VenueAnnotation: MKPointAnnotation {
  var venue: Venue? = nil
}
