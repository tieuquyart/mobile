//
//  MapViewController.swift
//  Acht
//
//  Created by Chester Shen on 8/13/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    let locationManager = CLLocationManager()
    let annotationId = "vehicle"
    var camera: UnifiedCamera? {
        didSet {
            if isViewLoaded {
                refreshUI()
            }
        }
    }
    
    static func createViewController() -> MapViewController {
        let vc = MapViewController(nibName: "MapViewController", bundle: nil)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Location", comment: "Location")
        mapView.delegate = self
//        locationManager.delegate = self
        locationView.backgroundColor = UIColor.semanticColor(.background(.senary)).withAlphaComponent(0.95)
        if camera?.location != nil {
            refreshUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.requestWhenInUseAuthorization()
    }

    func refreshUI() {
        if let address = camera?.location?.address?.fullAddress, !address.isEmpty {
            locationLabel.text = address
        } else {
            locationLabel.text = camera?.location?.description
        }
        guard let coordinate = camera?.location?.correctedCoordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        mapView.annotations.forEach { (annotation) in
            if annotation is MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            }
        }
        let point = MKPointAnnotation()
        point.coordinate = coordinate
        point.title = camera?.name
        mapView.addAnnotation(point)
    }
    
    @IBAction func onOpenMap(_ sender: Any) {
        guard let coordinate = camera?.location?.correctedCoordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.02))
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)]
        mapItem.name = camera?.name
        mapItem.openInMaps(launchOptions: options)
    }
    
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationId)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationId)
                annotationView?.image = #imageLiteral(resourceName: "icon_map_marker")
                annotationView?.centerOffset = CGPoint(x: 0, y: -25)
            } else {
                annotationView?.annotation = annotation
            }
            annotationView?.canShowCallout = true
            return annotationView
        }
        return nil
    }
}
