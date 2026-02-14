//
//  MapViewCustom.swift
//  Acht
//
//  Created by TranHoangThanh on 12/29/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import MapKit
import LBTATools

class MapViewCustom: UIView {
    @IBOutlet weak var contentView: UIView!
    private(set) lazy var pinsManager: MapPinsManager = { [unowned self] in
        let pinsManager = MapPinsManager(mapView: self.mapView)
        return pinsManager
    }()
    let mapView = MKMapView()
    var events = [Event]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        comonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        comonInit()
    }
    private func comonInit() {
        Bundle(for: type(of: self)).loadNibNamed("MapViewCustom" , owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        contentView.addSubview(mapView)
        
        mapView.fillSuperview()
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        setBorderView([contentView, mapView])
    }
    
    func setBorderView(_ views: [UIView]){
        views.forEach { view in
            view.layer.cornerRadius = 8
            view.layer.masksToBounds = true
        }
    }
    
    func setMapView(gpsLatitude: Double , gpsLongitude : Double) {
        let centerCoordinate = CLLocationCoordinate2D(latitude: gpsLatitude, longitude: gpsLongitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        mapView.setRegion(region, animated: false)
    }
    func setMapView2(_ latitude: Double, _ longitude: Double, _ eventType : EventType?, _ viewVC: UIViewController){
        print("\(eventType?.toString() ?? "")")
        let coordinate = CLLocationCoordinate2D(latitude: latitude != 0 ? latitude : ConstantMK.locationHN.latitude, longitude: longitude != 0 ? longitude : ConstantMK.locationHN.longitude).correctedForChina()
        let dicts: Dictionary<String, Any> = [
            "gpsLongitude": longitude,
            "gpsLatitude": latitude,
            "eventType": eventType?.toString() ?? "",
        ]
        if let data = try? JSONSerialization.data(withJSONObject: dicts, options: []),
           let event = try? JSONDecoder().decode(Event.self, from: data) {
            let annotation = EventAnnotation(event: event)
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            mapView.showsUserLocation = latitude != 0 ? false : true
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    func setMapView3(_ latitude: Double, _ longitude: Double, _ state : Vehicle.State?, _ viewVC: UIViewController){
        print("\(state!)")
        var type = ""
        if (state == .driving){
            type = "driving"
        }else if (state == .parking){
            type = "parking"
        }else{
            type = "offline"
        }
        let coordinate = CLLocationCoordinate2D(latitude: latitude != 0 ? latitude : ConstantMK.locationHN.latitude, longitude: longitude != 0 ? longitude : ConstantMK.locationHN.longitude).correctedForChina()
        
        let dicts: Dictionary<String, Any> = [
            "gpsLongitude": longitude,
            "gpsLatitude": latitude,
            "eventType": type,
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: dicts, options: []),
           let event = try? JSONDecoder().decode(Event.self, from: data) {
            let annotation = EventAnnotation(event: event)
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            mapView.showsUserLocation = latitude != 0 ? false : true
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
}
extension MapViewCustom: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let view = view as? PickupLocationAnnotationView {
            view.addCallout(delegate: self)
        }
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let view = view as? PickupLocationAnnotationView {
            view.removeCallout()
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return pinsManager.mapView(mapView, viewFor: annotation)
    }
}
// the delegate conformance so view controller can know when the callout button was tapped
extension MapViewCustom: CalloutViewDelegate {
    func startVideo() {
        
        //        let vc = PlayerVideoNotiViewController(nibName: "PlayerVideoNotiViewController", bundle: nil)
        //        vc.url = model.url ?? ""
        //        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    func calloutTapped(for annotation: MKAnnotation) {
        print("action cần tap")
        //        self.startVideo()
    }
}
