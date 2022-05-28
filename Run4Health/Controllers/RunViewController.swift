//
//  ViewController.swift
//  Run4Health
//
//  Created by Jadson on 21/05/22.
//

import UIKit
import CoreLocation
import MapKit

class RunViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startPauseButton: RoundButton!
    @IBOutlet weak var stopButton: RoundButton!
    @IBOutlet weak var distanceMetricButton: RoundButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    
    let manager = CLLocationManager()
    var workouts: WorkoutsModel?
    
    var isKmSelected = true
    
    //variables for the timer
    var timer: Timer = Timer()
    var count: Int = 0
    var timerCounting: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthStatus()
        configureView()

    }
    
    func configureView() {
        stopButton.isEnabled = false
        timeLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
        hideLabels()
        mapView.layer.opacity = 0.5
    }
    
    func hideLabels() {
        distanceLabel.isHidden = true
        timeLabel.isHidden = true
        paceLabel.isHidden = true
    }
    
    @IBAction func startPauseTapped(sender: RoundButton) {
        manager.startUpdatingLocation()
        if(timerCounting)
        {
            timerCounting = false
            timer.invalidate()
            startPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        else
        {
            timerCounting = true
            startPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            stopButton.isEnabled = true
            distanceLabel.isHidden = false
            timeLabel.isHidden = false
            paceLabel.isHidden = false
            distanceMetricButton.isEnabled = false
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        }
    }
    
    @objc func timerCounter() -> Void
    {
        count = count + 1
        let time = secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        timeLabel.text = timeString
    }
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int)
    {
        return ((seconds / 3600), ((seconds % 3600) / 60),((seconds % 3600) % 60))
    }
    
    func makeTimeString(hours: Int, minutes: Int, seconds : Int) -> String
    {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += " : "
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        return timeString
    }
    
    @IBAction func stopTapped(sender: RoundButton) {
        let alert = UIAlertController(title: "Stop Workout?", message: "Are you sure you would like to stop your workout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel))
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (_) in
            self.count = 0
            self.timer.invalidate()
            self.timeLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
            self.startPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.stopButton.isEnabled = false
            self.distanceMetricButton.isEnabled = true
            self.manager.stopUpdatingLocation()
            self.hideLabels()
            self.performSegue(withIdentifier: K.goToFinishRunDetails, sender: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func metricTapped(sender: RoundButton) {
        if isKmSelected {
            isKmSelected = false
            distanceLabel.text = "0km"
            self.distanceMetricButton.setImage(UIImage(named: "kmBtn"), for: .normal)
        } else {
            self.distanceMetricButton.setImage(UIImage(named: "milesBtn"), for: .normal)
            distanceLabel.text = "0mi"
            isKmSelected = true
            
        }
    }
    
    @IBAction func resetMapLocation(sender: RoundButton){
        guard let coordinate = LocationService.instance.currentLocation else {return}
        centerMapUserLocation(coordinate: coordinate)
    }
    
}

//MARK: - Request User Location
extension RunViewController: MKMapViewDelegate {
    func checkLocationAuthStatus() {
        if manager.authorizationStatus == .authorizedAlways {
            self.mapView.showsUserLocation = true
            LocationService.instance.customUserLocationDelegate = self
            LocationService.instance.locationManager.allowsBackgroundLocationUpdates = true
        } else {
            //LocationService.instance.locationManager.requestWhenInUseAuthorization()
            LocationService.instance.locationManager.requestAlwaysAuthorization()
        }
    }
    
    func centerMapUserLocation(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.mapView.setRegion(region, animated: true)
    }
    
    
}

//MARK: - User Location Delegate
extension RunViewController: CustomUserLocationDelegate {
    func userLocationUpdated(locacation: CLLocation) {
        centerMapUserLocation(coordinate: locacation.coordinate)
    }
}

//MARK: - overlay user run distance
extension RunViewController {
    func getUserDistance (userCoordinates: [CLLocationCoordinate2D]) {
        removeOverlays()
        
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinates.last!))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinates.first!))
        
        let direction = MKDirections(request: request)
        
        direction.calculate { [unowned self] response, error in
            guard let route = response?.routes.first else {return}
            self.mapView.addOverlay(route.polyline)
            
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 200, left: 50, bottom: 50, right: 50), animated: true)
        }
    }
    
    func removeOverlays() {
        self.mapView.overlays.forEach { self.mapView.removeOverlay($0)}
        
    }
}

//MARK: - perform segue
extension RunViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let runDetails = segue.destination as? DetailsRunViewController {
            runDetails.workouts = workouts
        }
    }
}
