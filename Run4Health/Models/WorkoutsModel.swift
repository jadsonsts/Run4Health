//
//  WorkoutsModel.swift
//  Run4Health
//
//  Created by Jadson on 24/05/22.
//

import Foundation
import UIKit
import CoreLocation


struct Runs {
    var duration: Int
    var distance: Double
    var screenShot: UIImage?
    var pace: String
    var date: Date
    var locations: [CLLocation]
}

class Location {
    var latitude: CLLocation
    var longitude: CLLocation
    var time: Date
    
    init(latitude: CLLocation, longitude: CLLocation, time: Date) {
        self.latitude = latitude
        self.longitude = longitude
        self.time = time
    }
    

}
