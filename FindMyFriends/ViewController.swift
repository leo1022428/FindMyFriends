//
//  ViewController.swift
//  FindMyFriend
//
//  Created by Che-wei LIU on 2018/7/2.
//  Copyright © 2018 Che-wei LIU. All rights reserved.
//

import UIKit
import MapKit

var friend: Friend?



class ViewController: UIViewController {
    
    @IBOutlet weak var friendTableView: UIView!
    @IBOutlet weak var mainMapView: MKMapView!
    var updateLocationEnable: Bool = true
    var userLocationEnable: Bool = true
    var userLocations = [CLLocationCoordinate2D]()
    let locationManager = CLLocationManager()
    
    let POLYLINE_WIDTH = 3.0
    let MAX_DISTANCE = 50.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mainMapView.delegate = self
        
        // Request authorization
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        // Prepare locationservice
        guard CLLocationManager.locationServicesEnabled() else {
            // show hint
            print("Please open your locationService")
            return
        }
        
        guard CLLocationManager.authorizationStatus() == .authorizedAlways else {
            // show hint to user
            print("Please open your location authorization for this app")
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        locationManager.distanceFilter = MAX_DISTANCE
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if userLocationEnable {  // Show user location and region
            guard let coordinate = locationManager.location?.coordinate else {
                print("Location is not ready.")
                return
            }
            
            mainMapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            
            // Add TrackingBarButton
            let item = MKUserTrackingBarButtonItem(mapView: mainMapView)
            navigationItem.rightBarButtonItem = item
            
            // Setting region
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mainMapView.setRegion(region, animated: true)
        } else {  // Remove user location and user tracking bar button.
            mainMapView.showsUserLocation = false
            locationManager.stopUpdatingLocation()
            
            // Remove polyline on mainMapView.
            mainMapView.removeOverlays(mainMapView.overlays)
            
            userLocations.removeAll()
            
            
            if let _ = navigationItem.rightBarButtonItem {
                self.navigationItem.rightBarButtonItems?.remove(at: 0)
            }
//            navigationItem.rightBarButtonItems?.remove(at: 0)
        }
    }
    
    @IBAction func unwindSettingSegue(_ segue: UIStoryboardSegue) {
        let controller = segue.source as? SettingTableViewController
        if let controller = controller {
            self.updateLocationEnable = controller.updateLocationSwitch.isOn
            self.userLocationEnable = controller.userLocationSwitch.isOn
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "settingSegue", let controller = segue.destination as? SettingTableViewController {
            controller.updateLocation = updateLocationEnable
            controller.userLocation = userLocationEnable
        }
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let nowLocation = locations.last else {
            assertionFailure("Invalid Location")
            return
        }
        
        let coordinate = nowLocation.coordinate
        print("Coordinate: \(coordinate.latitude, coordinate.longitude)")
        
        userLocations.append(coordinate)

        if updateLocationEnable {
            LocationCommunicator.shared.update(latitude: coordinate.latitude, longitude: coordinate.longitude) { (error, objects) in
                
                if let error = error {
                    print("Error: \(error)")
                    return
                }
            }            
        }
        
        // Add polyline on the map.
        let polyline = MKPolyline(coordinates: userLocations, count: userLocations.count)
        mainMapView.addOverlay(polyline)

    }
    
}

extension ViewController: MKMapViewDelegate {
    
    // Setting polyline's color and shape.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(overlay: polyline)
            renderer.strokeColor = .red
            renderer.lineWidth = CGFloat(POLYLINE_WIDTH)
            return renderer
        } else {
            return MKOverlayRenderer()
        }
    }
    
}


