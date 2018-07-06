//
//  LocationDownloader.swift
//  FindMyFriends
//
//  Created by Che-wei LIU on 2018/7/2.
//  Copyright © 2018 Che-wei LIU. All rights reserved.
//

import Foundation
import MapKit

typealias DoneHandler = (Error?, [Friend]?) -> Void

struct Results: Codable {
    var result: Bool
    var friends: [Friend]?
    var errorCode: Int?
}

let GROUPNAME = "cp101"
let USERNAME = "Leo"


class LocationCommunicator {
    
    static let BASEURL = "http://class.softarts.cc/FindMyFriends/"
    let QUERY_FRIENDLOCATIONS_URL = BASEURL + "queryFriendLocations.php?GroupName=" + GROUPNAME
    let UPDATE_USERLOCATION_URL = BASEURL + "updateUserLocation.php?GroupName=" + GROUPNAME
    
    static let shared = LocationCommunicator()
    private init() {
    }
    
    func download(doneHandler: @escaping DoneHandler) {
        
        guard let url = URL(string: QUERY_FRIENDLOCATIONS_URL) else {
            assertionFailure("Invalid URL string.")
            return
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print("Download Fail: \(error)")
                DispatchQueue.main.async {
                    doneHandler(error, nil)
                }
                return
            }
            
            guard let data = data else {
                print("Data is nil.")
                let error = NSError(domain: "Data is nil.", code: -1, userInfo: nil)
                DispatchQueue.main.async {
                    doneHandler(error, nil)
                }
                return
            }
            
            let decoder = JSONDecoder()
            
            let results = try? decoder.decode(Results.self, from: data)
            
            if let results = results {
                if results.result == true {
                    DispatchQueue.main.async {
                        doneHandler(error, results.friends)
                    }
                } else if let errorCode = results.errorCode {
                    // Print the errorCode.
                    print("ErrorCode: \(errorCode)")
                }
                
            } else {
                let error = NSError(domain: "Parse JSON Fail.", code: -1, userInfo: nil)
                DispatchQueue.main.async {
                    doneHandler(error, nil)
                }
            }
        }
        task.resume()
    }
    
    func update(latitude: Double, longitude: Double, doneHandler: @escaping DoneHandler) {
        
        let updateURL = UPDATE_USERLOCATION_URL + "&UserName=\(USERNAME)&Lat=\(latitude)&Lon=\(longitude)"
        
        guard let url = URL(string: updateURL) else {
            assertionFailure("Invalid URL string.")
            return
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print("Updata Fail: \(error)")
                DispatchQueue.main.async {
                    doneHandler(error, nil)
                }
                return
            }
            
            guard let data = data else {
                print("Data is nil.")
                let error = NSError(domain: "Data is nil.", code: -1, userInfo: nil)
                doneHandler(error, nil)
                return
            }
            
            let decoder = JSONDecoder()
            
            let results = try? decoder.decode(Results.self, from: data)
            
            if let results = results {
                if results.result == true {
                    print("Update location succeed.")
                } else if let errorCode = results.errorCode {
                    // Print the errorCode.
                    print("ErrorCode: \(errorCode)")
                }
                
            } else {
                let error = NSError(domain: "Parse JSON Fail.", code: -1, userInfo: nil)
                DispatchQueue.main.async {
                    doneHandler(error, nil)
                }
            }
        }
        task.resume()
    }
}



