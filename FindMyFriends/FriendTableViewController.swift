//
//  FriendTableViewController.swift
//  FindMyFriend
//
//  Created by Che-wei LIU on 2018/7/2.
//  Copyright © 2018 Che-wei LIU. All rights reserved.
//

import UIKit
import MapKit

class FriendTableViewController: UITableViewController {

    private let reuseIdentifier = "friendCell"
    var friends = [Friend]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        refreshFriendLocations()
        
    }
    
    func refreshFriendLocations() {
        
        LocationCommunicator.shared.download { (error, objects) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let objects = objects {
                self.friends = objects
            }

            // Remove self location from tableView
            for i in 0...self.friends.count-1 {
                if self.friends[i].friendName == USERNAME {
                    self.friends.remove(at: i)
                    self.tableView.reloadData()
                    return
                }
            }
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friends.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? FriendTableViewCell
        
        friend = friends[indexPath.row]
        
        if let cell = cell, let friend = friend {
            cell.nameLabel.text = friend.friendName
            cell.locationLabel.text = "Lat: \(friend.lat), Lon: \(friend.lon)"
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        friend = friends[indexPath.row]
        
        guard let friend = friend,let lat = Double(friend.lat), let lon = Double(friend.lon) else {
            assertionFailure("Fail to cast to lat/lon.")
            return
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = friend.friendName
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        // Get parent controller
        let controller = self.parent as? ViewController
        if let controller = controller {
            controller.mainMapView.addAnnotation(annotation)
            controller.mainMapView.setRegion(region, animated: true)
        }
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//        }
//
//    }
    

}
