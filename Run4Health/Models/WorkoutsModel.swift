//
//  WorkoutsModel.swift
//  Run4Health
//
//  Created by Jadson on 24/05/22.
//

import Foundation
import UIKit

struct WorkoutsModel {
    var workouts: [Runs]
    
}

struct Runs {
    var duration: Int
    var distance: Double
    var screenShot: UIImage
    var pace: String
    var date: Date
}

struct Location {
    var latitude = "23"
    var longitude = "324"
}
