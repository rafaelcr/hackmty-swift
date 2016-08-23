//
//  VenueDetail.swift
//  VenueMap
//
//  Created by Rafael Cardenas on 8/20/16.
//  Copyright © 2016 Rafael Cardenas. All rights reserved.
//

import UIKit

class VenueDetailController: UITableViewController {
  
  var venue: Venue?
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    title = venue?.name
  }
  
  // MARK: UITableViewController
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
    
    if indexPath.row == 0 {
      cell.textLabel?.text = "Name"
      cell.detailTextLabel?.text = venue?.name
    }
    if indexPath.row == 1 {
      cell.textLabel?.text = "Phone"
      cell.detailTextLabel?.text = venue?.phone
    }
    
    return cell
  }
  
}
