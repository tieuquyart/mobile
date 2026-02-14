//
//  DirectionsController.swift
//  Acht
//
//  Created by TranHoangThanh on 10/17/22.
//  Copyright © 2022 waylens. All rights reserved.
//


import UIKit
import MapKit
import LBTATools



class PlacesController: UIViewController {

    let mapView = MKMapView()

    var model : NotiItem!


//    let hudCategoryLabel = UILabel(text: "Category", font: .boldSystemFont(ofSize: 16))
//    let hudEventTypeLabel = UILabel(text: "EventType", font: .systemFont(ofSize: 16))
//    let hudTypesLabel = UILabel(text: "Types", textColor: .gray)
//    lazy var infoButton = UIButton(type: .infoLight)
    let hudContainer = UIView(backgroundColor: .white)


    let categoryLabel =  UILabel(text: "Phân loại", font: UIFont(name: "BeVietnamPro-Bold", size: 16)!)
    let eventTypeLabel =  UILabel(text: "Hành vi", font: UIFont(name: "BeVietnamPro-Bold", size: 16)!)
    let fleetNameLabel =  UILabel(text: "Tên Fleet", font: UIFont(name: "BeVietnamPro-Bold", size: 16)!)
    let plateNoLabel =  UILabel(text: "Biển số xe", font: UIFont(name: "BeVietnamPro-Bold", size: 16)!)
    let timeLabel =  UILabel(text: "Thời gian", font: UIFont(name: "BeVietnamPro-Bold", size: 16)!)


    func setTitle(label : UILabel , title : String , info : String?) {

        let attributedTextEventType = NSMutableAttributedString(string: "\(title) : " , attributes: [NSAttributedString.Key.font : UIFont(name: "BeVietnamPro-Bold", size: 14)!])

        attributedTextEventType.append(NSAttributedString(string: NSLocalizedString(info ?? "null", comment: info ?? "null")  , attributes: [NSAttributedString.Key.font : UIFont(name: "BeVietnamPro-Bold", size: 14)!]))

        label.attributedText = attributedTextEventType

    }

    func config() {


        setTitle(label: categoryLabel, title: "Phân loại", info: model.category ?? "")
        setTitle(label: eventTypeLabel, title: "Hành vi", info: model.eventType?.description ?? "")
        setTitle(label: fleetNameLabel , title: "Tên Fleet", info: model.fleetName)
        setTitle(label: plateNoLabel, title: "Biển số xe", info: model.plateNo)
        setTitle(label: timeLabel, title: "Thời gian", info: model.createTime)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mapView)
        mapView.fillSuperview()
        mapView.showsUserLocation = true
        mapView.delegate = self

         config()

        if let model = model {
            let strcategory =  (NSLocalizedString(model.category ?? "", comment: ""))
            let streventType =  (NSLocalizedString(model.eventType?.description ?? "", comment: ""))
            if let lat = model.gpsLatitude , let long = model.gpsLongitude {

              //  CLLocationCoordinate2D(latitude: 21.0304737, longitude: 105.783538)
               // let coordinate = CLLocationCoordinate2D(latitude: 21.0304737, longitude: 105.783538)
                  let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        mapView.camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: 1_000, pitch: 0, heading: 0)
                        mapView.register(PickupLocationAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)


//                        let hours = """
////                        \(strcategory)
////                         \(streventType)
//                         """
                let annotation = PickupLocationAnnotation(category: strcategory, eventType:  streventType, url: model.url!)
                        annotation.coordinate = coordinate
                        mapView.addAnnotation(annotation)
            }
        }


//        let coordinate = CLLocationCoordinate2D(latitude: 21.0304737, longitude: 105.783538)
//     //   let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
//                mapView.camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: 1_000, pitch: 0, heading: 0)
//                mapView.register(PickupLocationAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
//
//
//                let hours = """
//                          kakka
//                 """
//                let annotation = PickupLocationAnnotation(hours: hours)
//                annotation.coordinate = coordinate
//                mapView.addAnnotation(annotation)

       setupSelectedAnnotationHUD()

    }



    fileprivate func setupRegionForMap() {
        let centerCoordinate = CLLocationCoordinate2D(latitude: 21.0304737, longitude: 105.783538)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }



    fileprivate func setupSelectedAnnotationHUD() {
        view.addSubview(hudContainer)
        hudContainer.layer.cornerRadius = 5
        hudContainer.setupShadow(opacity: 0.2, radius: 5, offset: .zero, color: .darkGray)
        hudContainer.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .allSides(16), size: .init(width: 0, height: 125))


        let topRow = UIView()

        topRow.stack(categoryLabel,eventTypeLabel,fleetNameLabel,plateNoLabel,timeLabel)

        hudContainer.stack(topRow).withMargins(.allSides(8))

//        topRow.hstack(hudNameLabel, infoButton.withWidth(44))
//
//        hudContainer.hstack(hudContainer.stack(topRow,
//                             hudAddressLabel,
//                             hudTypesLabel, spacing: 8),
//                   alignment: .center).withMargins(.allSides(16))
    }


}

//extension PlacesController :  CLLocationManagerDelegate, MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        let customCalloutContainer = CalloutContainer()
//
//        view.addSubview(customCalloutContainer)
//
//        let widthAnchor = customCalloutContainer.widthAnchor.constraint(equalToConstant: 150)
//        widthAnchor.isActive = true
//        let heightAnchor = customCalloutContainer.heightAnchor.constraint(equalToConstant: 150)
//        heightAnchor.isActive = true
//        customCalloutContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        customCalloutContainer.bottomAnchor.constraint(equalTo: view.topAnchor).isActive = true
//
//        view.setSelected(false, animated: false)
//      //  print("aaaaa")
//
//    }
//
//}


// the selecting and deselecting of annotation views

extension PlacesController: MKMapViewDelegate {
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
}

// the delegate conformance so view controller can know when the callout button was tapped

extension PlacesController: CalloutViewDelegate {

    func startVideo() {

        let vc = PlayerVideoNotiViewController(nibName: "PlayerVideoNotiViewController", bundle: nil)
        vc.url = model.url ?? ""
        self.navigationController?.pushViewController(vc, animated: true)

    }


    func calloutTapped(for annotation: MKAnnotation) {
        print("action cần tap")
        self.startVideo()

    }
}

//import SwiftUI
//import LBTATools
//import MapKit
//
//
//class PlacesController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
//
//    let mapView = MKMapView()
//    let locationManager = CLLocationManager()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.addSubview(mapView)
//        mapView.fillSuperview()
//        mapView.delegate = self
//        mapView.showsUserLocation = true
//        locationManager.delegate = self
//
//        requestForLocationAuthorization()
//    }
//
//    let client = GMSPlacesClient()
//
//    fileprivate func findNearbyPlaces() {
//        client.currentPlace { [weak self] (likelihoodList, err) in
//            if let err = err {
//                print("Failed to find current place:", err)
//                return
//            }
//
//            likelihoodList?.likelihoods.forEach({  (likelihood) in
//                print(likelihood.place.name ?? "")
//
//                let place = likelihood.place
//
//                let annotation = PlaceAnnotation(place: place)
//                annotation.title = place.name
//                annotation.coordinate = place.coordinate
//
//                self?.mapView.addAnnotation(annotation)
//            })
//
//            self?.mapView.showAnnotations(self?.mapView.annotations ?? [], animated: false)
//        }
//    }
//
//    class PlaceAnnotation: MKPointAnnotation {
//        let place: GMSPlace
//        init(place: GMSPlace) {
//            self.place = place
//        }
//    }
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if !(annotation is PlaceAnnotation) { return nil }
//
//        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
//        annotationView.canShowCallout = true
//
//        if let placeAnnotation = annotation as? PlaceAnnotation {
//            let types = placeAnnotation.place.types
//            if let firstType = types?.first {
//                if firstType == "bar" {
//                    annotationView.image = #imageLiteral(resourceName: "bar")
//                } else if firstType == "restaurant" {
//                    annotationView.image = #imageLiteral(resourceName: "restaurant")
//                } else {
//                    annotationView.image = #imageLiteral(resourceName: "tourist")
//                }
//            }
////            print(placeAnnotation.place.types)
////            if placeAnnotation.place.types
////            annotationView.image = #imageLiteral(resourceName: "restaurant")
//        }
//
//        return annotationView
//    }
//
//    var currentCustomCallout: UIView?
//
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        currentCustomCallout?.removeFromSuperview()
//
//        let customCalloutContainer = UIView(backgroundColor: .red)
//
////        customCalloutContainer.frame = .init(x: 0, y: 0, width: 100, height: 200)
//
//        view.addSubview(customCalloutContainer)
//
//        customCalloutContainer.translatesAutoresizingMaskIntoConstraints = false
//
//        customCalloutContainer.widthAnchor.constraint(equalToConstant: 100).isActive = true
//        customCalloutContainer.heightAnchor.constraint(equalToConstant: 200).isActive = true
//        customCalloutContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
////        customCalloutContainer.
//        customCalloutContainer.bottomAnchor.constraint(equalTo: view.topAnchor).isActive = true
//
//        currentCustomCallout = customCalloutContainer
//    }
//
//    fileprivate func requestForLocationAuthorization() {
//        locationManager.requestWhenInUseAuthorization()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .authorizedWhenInUse {
//            locationManager.startUpdatingLocation()
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let first = locations.first else { return }
//        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//        let region = MKCoordinateRegion(center: first.coordinate, span: span)
//        mapView.setRegion(region, animated: false)
//
//        findNearbyPlaces()
//    }
//}



//class  PlacesController: UIViewController {
//    let mapView = MKMapView()
//    var model : NotiItem!
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.addSubview(mapView)
//              mapView.fillSuperview()
//            mapView.showsUserLocation = true
//        mapView.delegate = self
//       ////        mapView.showsUserLocation = true
//       ////        locationManager.delegate = self
//
//        let coordinate = CLLocationCoordinate2D(latitude: 37.332693, longitude: -122.03071)
//        mapView.camera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: 1_000, pitch: 0, heading: 0)
//        mapView.register(PickupLocationAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
//
//        let hours = """
//            Mon to Thu 10am-7pm
//            Fri 12pm-9pm
//            Sat 10am-11pm
//            """
//        let annotation = PickupLocationAnnotation(hours: hours)
//        annotation.coordinate = coordinate
//        mapView.addAnnotation(annotation)
//    }
//}
//
//// the selecting and deselecting of annotation views
//
//extension PlacesController: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        if let view = view as? PickupLocationAnnotationView {
//            view.addCallout(delegate: self)
//        }
//    }
//
//    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//        if let view = view as? PickupLocationAnnotationView {
//            view.removeCallout()
//        }
//    }
//}
//
//// the delegate conformance so view controller can know when the callout button was tapped
//
//extension PlacesController: CalloutViewDelegate {
//    func calloutTapped(for annotation: MKAnnotation) {
//        print(#function)
//    }
//}
