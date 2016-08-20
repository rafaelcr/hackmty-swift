//
//  Foursquare.swift
//  VenueMap
//
//  Created by Rafael Cardenas on 8/19/16.
//  Copyright © 2016 Rafael Cardenas. All rights reserved.
//

import CoreLocation
import Foundation
import MapKit

/// A single venue in Foursquare.
struct Venue {
  var name: String
  var coordinate: CLLocationCoordinate2D
  var phone: String?
}

class Foursquare {
  
  // https://developer.foursquare.com/docs/venues/search
  static let venueSearchURL = "https://api.foursquare.com/v2/venues/search"
  
  static let clientID = "M3RZ1CRW3SJM13T0VISARWCYCZ3FJRZF5JCFXEVCYRHKWFUE"
  static let clientSecret = "KAWMKB3EBXUQPVEZQGGICYY3YBD3SIIRBLYQXCWEFA354JFM"
  
  class func searchVenuesAroundLocation(_ location: CLLocation,
                                        callback: @escaping (Array<Venue>) -> Void) {
    let urlString = String(format: "%@?ll=%f,%f&client_id=%@&client_secret=%@&v=20160819",
                           venueSearchURL,
                           location.coordinate.latitude, location.coordinate.longitude,
                           clientID, clientSecret)
    let url = URL(string: urlString)
    
    let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
      if error != nil {
        print(error)
        callback([])
      }
      
      do {
        if data != nil {
          // Parse JSON response.
          let json = try JSONSerialization.jsonObject(with: data!)
            as? Dictionary<String, AnyObject>
          let jsonResponse = json?["response"] as? Dictionary<String, AnyObject>
          let jsonVenues = jsonResponse?["venues"] as? Array<Dictionary<String, AnyObject>>
          
          // Create a Venue for each response[venues] item.
          var venues = Array<Venue>()
          for item in jsonVenues! {
            let jsonName = item["name"] as! String
            
            let jsonLocation = item["location"] as! Dictionary<String, AnyObject>
            let jsonLat = jsonLocation["lat"] as? NSNumber as! Double
            let jsonLng = jsonLocation["lng"] as? NSNumber as! Double
            
            let jsonContact = item["contact"] as! Dictionary<String, AnyObject>
            let jsonPhone = jsonContact["formattedPhone"] as? String
            
            let venue = Venue(name: jsonName,
                              coordinate: CLLocationCoordinate2D(latitude: jsonLat,
                                                                 longitude: jsonLng),
                              phone: jsonPhone)
            venues.append(venue)
          }
          callback(venues)
        } else {
          callback([])
        }
      } catch {
        print("json error")
        callback([])
      }
    }
    task.resume()
  }
  
}
