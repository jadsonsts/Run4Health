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
    var time: String
    var distance: String
    var screenShot: UIImage
}
