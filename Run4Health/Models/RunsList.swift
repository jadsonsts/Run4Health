//
//  RunsList.swift
//  Run4Health
//
//  Created by Jadson on 4/06/22.
//

import Foundation

class RunsList {
    static let instance = RunsList()
    
    var runs = [Runs]()
    
    func addRun(run: Runs) {
        let currentRun = Runs(duration: run.duration, distance: run.distance, pace: run.pace, date: run.date, locations: run.locations)
        runs.append(currentRun)
    }
}
