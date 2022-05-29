//
//  ShareViewController.swift
//  Run4Health
//
//  Created by Jadson on 24/05/22.
//

import UIKit
import MapKit

class DetailsRunViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    
    var workouts: WorkoutsModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    

    private func configureView() {
        //let distance = Measurement(value: workouts., unit: <#T##Unit#>)
    }

}
