//
//  LibreLinkFollowerDelegate.swift
//  xdrip
//
//  Created by Johan Degraeve on 11/09/2023.
//  Copyright © 2023 Johan Degraeve. All rights reserved.
//

import Foundation

protocol LoopFollowerDelegate: AnyObject {
    
    /// to pass back follower data
    /// - parameters:
    ///     - followGlucoseDataArray : array of FollowGlucoseData, can be empty array, first entry is the youngest
    func loopFollowerInfoReceived(followGlucoseDataArray:inout [GlucoseData])

}
