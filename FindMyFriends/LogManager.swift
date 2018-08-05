//
//  LogManager.swift
//  FindMyFriends
//
//  Created by Che-wei LIU on 2018/7/8.
//  Copyright © 2018 Che-wei LIU. All rights reserved.
//

import Foundation
import SQLite
import MapKit

 let ID_KEY = "id"
 let LOCATION_TABLE_NAME = "location"
 let LATITUDE_KEY = "Latitude"
 let LONGITUDE_KEY = "Longitude"
 let TIMESTAMP_KEY = "LastUpdateDateTime"

class LogManager {
    
    var locations = [Int64]()
    
    var db: Connection!
    var locationTable = Table(LOCATION_TABLE_NAME)
    var idColumn = Expression<Int64>(ID_KEY)
    var latColumn = Expression<Double>(LATITUDE_KEY)
    var lonColumn = Expression<Double>(LONGITUDE_KEY)
    var timeStampColumn = Expression<Date>(TIMESTAMP_KEY)
    
    var totalLocations: Int {
        return locations.count
    }    
    static let shared = LogManager()
    
    private init() {
        
        let filemanager = FileManager.default
        guard let cachesURL = filemanager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            assertionFailure("Fail to get cachesDirectory.")
            return
        }
        
        let finalFullPath = cachesURL.appendingPathComponent("\(LOCATION_TABLE_NAME).sqlite").path
        var isNewDB = false
        if !filemanager.fileExists(atPath: finalFullPath) {
            isNewDB = true
        }
        
        do {
            db = try Connection(finalFullPath)
        } catch {
            assertionFailure("Connection dataBase fail.")
            return
        }
        
        if isNewDB {
            do {
                let command = locationTable.create { (builder) in
                    builder.column(idColumn, primaryKey: true)
                    builder.column(latColumn)
                    builder.column(lonColumn)
                    builder.column(timeStampColumn)
                }
                try db.run(command)
            } catch {
                assertionFailure("Fail to crate database : \(error)")
            }
        } else {
            do {
                for location in try db.prepare(locationTable) {
                    locations.append(location[idColumn])
                }
            } catch {
                assertionFailure("Fail to execute command : \(error)")
            }
            print("Total \(locations.count) locations in database.")
        }
    }
    
    func append(location: CLLocation) {
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let timeStamp = location.timestamp
        
        let command = locationTable.insert(latColumn <- lat,
                                           lonColumn <- lon,
                                           timeStampColumn <- timeStamp)
        
        do {
            let locationID = try db.run(command)
            locations.append(locationID)
        } catch {
            assertionFailure("Fail to insert location \(error)")
        }
    }
    
    func getLocaiton(at: Int) -> CLLocation? {
        
        guard at >= 0, at <= locations.count else {
            assertionFailure("Invalid index.")
            return nil
        }
        
        let result = locationTable.filter(idColumn == locations[at])
        
        do {
            guard let location = try db.pluck(result) else {
                assertionFailure("Fail to get result")
                return nil
            }
            
            return CLLocation(coordinate: CLLocationCoordinate2D(latitude: location[latColumn], longitude: location[lonColumn]), altitude: 0.0, horizontalAccuracy: 0.0, verticalAccuracy: 0.0, course: 0.0, speed: 0.0, timestamp: location[timeStampColumn])
        } catch {
            assertionFailure("Fail to get location : \(error)")
        }
        return nil
    }
    
    
}


