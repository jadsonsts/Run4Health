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
    
    private var workouts: WorkoutsModel?
    let manager = CLLocationManager()
    
    
    private var isKmSelected = true
    
    //variables for the timer
    private var timer = Timer()
    private var seconds = 0
    private var timerCounting: Bool = false
    //var unitChosen: Measurement<UnitLength>?
    private var distance = Measurement(value: 0, unit: UnitLength.meters) //meter as default
    private var locationList: [CLLocation] = []
    private var paceChosen = UnitSpeed.minutesPerKilometer //km as default
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthStatus()
        configureView()

    }
    
    func configureView() {
        stopButton.isEnabled = false
        //timeLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
        hideLabels()
        mapView.layer.opacity = 0.8
        mapView.layer.cornerRadius = self.mapView.frame.height / 5
    }
    
    func hideLabels() {
        distanceLabel.isHidden = true
        timeLabel.isHidden = true
        paceLabel.isHidden = true
    }
    
    func eachSecond(){
        seconds += 1
        updateDisplay()
    }
    
    private func updateDisplay() {
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance, seconds: seconds, outputUnit: paceChosen)
        
        distanceLabel.text = String(formattedDistance)
        timeLabel.text = String(formattedTime)
        paceLabel.text = String(formattedPace)
    }
    
    private func startLocationUpdates() {
      manager.activityType = .fitness
      manager.distanceFilter = 10
      manager.startUpdatingLocation()
    }
    
    @IBAction func startPauseTapped(sender: RoundButton) {
        
        manager.startUpdatingLocation()
        if(timerCounting)
        {
            timerCounting = false
            timer.invalidate()
            manager.stopUpdatingLocation()
            startPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        else
        {
            timerCounting = true
            startPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            startRun()
            stopButton.isEnabled = true
            distanceLabel.isHidden = false
            timeLabel.isHidden = false
            paceLabel.isHidden = false
            distanceMetricButton.isEnabled = false
        }
    }
    
    func startRun() {
        startLocationUpdates()
        mapView.removeOverlays(mapView.overlays)
        
        locationList.removeAll()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            self.eachSecond()
        })
    }
    
    func stopRun() {
        seconds = 0
        hideLabels()
        stopButton.isEnabled = false
        distanceMetricButton.isEnabled = true
        startPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        manager.stopUpdatingLocation()
    }
    
    func saveRun() {
        //let newRun = WorkoutsModel(workouts: <#[Runs]#>)
        
    }
    
    @IBAction func stopTapped(sender: RoundButton) {
        let alert = UIAlertController(title: "Stop Workout?", message: "Are you sure you would like to stop your workout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel))
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (_) in
            self.stopRun()
            self.seconds = 0
            self.timer.invalidate()
            self.performSegue(withIdentifier: K.goToFinishRunDetails, sender: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func metricTapped(sender: RoundButton) {
        if isKmSelected {
            isKmSelected = false
            distance = Measurement(value: 0, unit: UnitLength.meters)
            paceChosen = UnitSpeed.minutesPerKilometer
            self.distanceMetricButton.setImage(UIImage(named: "kmBtn"), for: .normal)
        } else {
            isKmSelected = true
            distance = Measurement(value: 0, unit: UnitLength.miles)
            paceChosen = UnitSpeed.minutesPerMile
            self.distanceMetricButton.setImage(UIImage(named: "milesBtn"), for: .normal)

        }
    }
    
    @IBAction func resetMapLocation(sender: RoundButton){
        guard let coordinate = LocationService.instance.currentLocation else {return}
        centerMapUserLocation(coordinate: coordinate)
    }
    
}

//MARK: - User Location Delegate
extension RunViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                
                //TODO: - CHANGE IT TO BE DYNAMIC (METER AND MILE)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
                
                let coordinates = [lastLocation.coordinate, newLocation.coordinate]
                mapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
                let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                mapView.setRegion(region, animated: true)
            }
            locationList.append(newLocation)
            
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("error: \(error.localizedDescription)")
    }
}

//MARK: - Request User Location
extension RunViewController: MKMapViewDelegate {
    func checkLocationAuthStatus() {
        if manager.authorizationStatus == .authorizedAlways {
            self.mapView.showsUserLocation = true
            manager.allowsBackgroundLocationUpdates = true
        } else {
            manager.requestAlwaysAuthorization()
        }
    }
    
    func centerMapUserLocation(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .systemPink
        renderer.lineWidth = 4
        renderer.alpha = 0.7
        return renderer
    }

}


//MARK: - perform segue to details
extension RunViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let runDetails = segue.destination as? DetailsRunViewController {
            runDetails.workouts = workouts
        }
    }
}
