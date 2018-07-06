//
//  Friend.swift
//  FindMyFriends
//
//  Created by Che-wei LIU on 2018/7/2.
//  Copyright © 2018 Che-wei LIU. All rights reserved.
//

import Foundation

struct Friend: Codable {
    var id: String = ""
    var friendName: String = ""
    var lat: String = ""
    var lon: String = ""
    var lastUpdateDateTime: String = ""
}
