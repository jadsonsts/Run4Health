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
    var runs: Runs!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    

    private func configureView() {
        let distance = Measurement(value: runs.distance, unit: UnitLength.meters)
        let seconds = runs.duration
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedDate = FormatDisplay.date(runs.date)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance,
                                               seconds: seconds,
                                               outputUnit: UnitSpeed.minutesPerKilometer)
        
        distanceLabel.text = "Distance: \(formattedDistance)"
        dateLabel.text = formattedDate
        timeLabel.text = "Time: \(formattedTime)"
        paceLabel.text = "Pace: \(formattedPace)"
        
        loadMap()
        
    }
    
    private func mapRegion() -> MKCoordinateRegion? {
        let locations = runs.locations,
            _ = locations.count > 0
        
        let latitudes = locations.map { location -> Double in
//            let location = location
            return location.coordinate.latitude
        }
        let longitudes = locations.map { location -> Double in
//            let location = location
            return location.coordinate.longitude
        }
        
        let maxLat = latitudes.max()!
        let minLat = latitudes.min()!
        let maxLong = longitudes.max()!
        let minLong = longitudes.min()!
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLong + maxLong) / 2)
        
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3,
                                    longitudeDelta: (maxLong - minLong) * 1.3)
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    private func polyLine() -> MKPolyline {
         let locations = runs.locations
        
        let coords: [CLLocationCoordinate2D] = locations.map { location in
            return CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        return MKPolyline(coordinates: coords, count: coords.count)
    }
    
    private func loadMap() {
        let locations = runs.locations
        _ = locations.count > 0
        guard let region = mapRegion() else {return}
        
        mapView.setRegion(region, animated: true)
        mapView.addOverlay(polyLine())
    }

}

extension DetailsRunViewController: MKMapViewDelegate {
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
