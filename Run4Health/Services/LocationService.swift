//
//  LocationService.swift
//  Run4Health
//
//  Created by Jadson on 24/05/22.
//

import Foundation
import CoreLocation

protocol CustomUserLocationDelegate {
    func userLocationUpdated(locacation: CLLocation)
}

class LocationService: NSObject, CLLocationManagerDelegate {
    static let instance = LocationService()
    
    //var customUserLocationDelegate: CustomUserLocationDelegate?
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 50
        self.locationManager.startUpdatingLocation()
    }
    

}
