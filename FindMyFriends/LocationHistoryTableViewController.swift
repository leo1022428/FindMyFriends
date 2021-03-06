//
//  LocationHistoryTableViewController.swift
//  FindMyFriends
//
//  Created by Che-wei LIU on 2018/7/8.
//  Copyright © 2018 Che-wei LIU. All rights reserved.
//

import UIKit
import MapKit

class LocationHistoryTableViewController: UITableViewController {
    
    var userLocations = [CLLocation]()
    var logManager = LogManager.shared
    private let reuseIdentifier = "historyCell"
    
    let LOCATIONS_ON_VIEW = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let starIndex: Int = {
            var result = logManager.totalLocations - LOCATIONS_ON_VIEW
            if result < 20 {
                result = 0
            }
            return result
        }()
        for i in 0..<(logManager.totalLocations - starIndex) {
            guard let location = logManager.getLocaiton(at: i + starIndex) else {
                assertionFailure("Fail to get location.")
                continue
            }
            userLocations.append(location)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userLocations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        let location = userLocations[indexPath.row]
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        cell.textLabel?.text = "Lat: \(lat), Lon: \(lon)"
        cell.detailTextLabel?.text = "TimeStamp: \(location.timestamp)"

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
