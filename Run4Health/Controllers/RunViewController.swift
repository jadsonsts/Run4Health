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
    
    
    private var runs: Runs?
    private let locationManager = LocationService.shared
    private var currentLocation: CLLocationCoordinate2D?
    
    
    private var isKmSelected = true
    
    //variables for the timer
    private var timer = Timer()
    private var seconds = 0
    private var timerCounting: Bool = false
    
    
    private var unitMeter = Measurement(value: 0, unit: UnitLength.meters)
    private var unitMile = Measurement(value: 0, unit: UnitLength.miles)
    private var distance: Measurement<UnitLength>!
    
    private var locationList: [CLLocation] = []
    private var paceChosen = UnitSpeed.minutesPerKilometer //km as default
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthStatus()
        configureView()
        mapView.delegate = self
        distance = unitMeter //meter as default
    }
    
    func configureView() {
        stopButton.isEnabled = false
        hideLabels()
        mapView.layer.opacity = 0.7
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
        LocationService.shared.delegate = self
        LocationService.shared.activityType = .fitness
        LocationService.shared.distanceFilter = 10
        LocationService.shared.startUpdatingLocation()
    }
    
    @IBAction func startPauseTapped(sender: RoundButton) {
        if(timerCounting)
        {
            timerCounting = false
            timer.invalidate()
            LocationService.shared.stopUpdatingLocation()
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
    
    private func startRun() {
        startLocationUpdates()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            self.eachSecond()
        })
    }
    
    private func stopRun() {
        seconds = 0
        LocationService.shared.stopUpdatingLocation()
        //TODO: - CHANGE IT DO BE DYNAMIC
        distance = Measurement(value: 0, unit: UnitLength.meters)
        timer.invalidate()
        hideLabels()
        locationList.removeAll() // it was on start run
        mapView.removeOverlays(mapView.overlays) // it was on startRun
        distanceMetricButton.isEnabled = true
        stopButton.isEnabled = false
        startPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        removeOverlays()
    }
    
    private func saveRun() {
        let distance = distance.value
        let duration = seconds
        let pace = paceLabel.text
        let time = Date()
        
        let run = Runs(duration: duration, distance: distance, pace: pace!, date: time, locations: locationList)
        runs = run
        RunsList.instance.addRun(run: run)
        
    }
    
    @IBAction func stopTapped(sender: RoundButton) {
        let alert = UIAlertController(title: "Finish Workout?", message: "Do you wish to end your workout?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            self.saveRun()
            self.stopRun()
            self.timer.invalidate()
            self.performSegue(withIdentifier: K.goToFinishRunDetails, sender: nil)
        }))
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { _ in self.stopRun() }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func metricTapped(sender: RoundButton) {
        if isKmSelected {
            isKmSelected = false
            distance = unitMeter
            paceChosen = UnitSpeed.minutesPerKilometer
            self.distanceMetricButton.setImage(UIImage(named: "kmBtn"), for: .normal)
        } else {
            isKmSelected = true
            distance = unitMile
            paceChosen = UnitSpeed.minutesPerMile
            self.distanceMetricButton.setImage(UIImage(named: "milesBtn"), for: .normal)

        }
    }
    
    @IBAction func resetMapLocation(sender: RoundButton){
        guard let coordinate = currentLocation else {
            let stringR = " fail to get user location "
            return debugPrint(stringR)}
        centerMapUserLocation(coordinate: coordinate)
    }
    
}

//MARK: - User Location Delegate
extension RunViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location?.coordinate
        userLocationUpdated(location: locations.first!)
        
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
    
    func userLocationUpdated(location: CLLocation) {
        centerMapUserLocation(coordinate: location.coordinate)
    }
}

//MARK: - Request User Location
extension RunViewController: MKMapViewDelegate {
    func checkLocationAuthStatus() {
        if locationManager.authorizationStatus == .authorizedAlways {
            self.mapView.showsUserLocation = true
            LocationService.shared.allowsBackgroundLocationUpdates = true
        } else {
            LocationService.shared.requestAlwaysAuthorization()
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
        return renderer
    }
    
    func removeOverlays() {
        self.mapView.overlays.forEach { self.mapView.removeOverlay($0)}
    }
}


//MARK: - perform segue to details
extension RunViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let runDetails = segue.destination as? DetailsRunViewController {
            runDetails.runs = runs
        }
    }
}
