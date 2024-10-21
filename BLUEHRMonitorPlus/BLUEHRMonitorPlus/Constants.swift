//
//  Constants.swift
//  BLUEHRMonitorPlus
//
//  Created by Mario Andres Heberthardt Marchant on 1/10/24.
//

import Foundation

enum Constants {
    
    static var bodySensorLocationCBUUID = "2A38"
    static var heartRateMeasurementCBUUID = "2A37"
    static var serviceTypeCBUUID = "180D"
    
    enum bodySensorLocation {
        static var locationValues = ["Other",
                                     "Chest",
                                     "Wrist",
                                     "Finger",
                                     "Eand",
                                     "Ear Lobe",
                                     "Foot",
                                     "Reserved for future use"]
    }
}
