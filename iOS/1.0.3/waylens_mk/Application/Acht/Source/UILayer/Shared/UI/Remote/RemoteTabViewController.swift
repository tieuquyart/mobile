//
//  RemoteTabViewController.swift
//  Acht
//
//  Created by gliu on 8/23/16.
//  Copyright © 2016 waylens. All rights reserved.
//

import UIKit
import MapKit
import Mixpanel
import CoreLocation

class RemoteTabViewController: UIViewController,
    MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource,
    RemoteCamerasModelDelegate {

    var annotations = Array<MKAnnotation>()
    var selectCamera : RemoteCamera? = nil
    var locationManager = CLLocationManager()

    @IBOutlet weak var cameraList: UITableView!
    @IBOutlet weak var noCamera: UIView!
    @IBOutlet weak var map: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = 100
        map.showsUserLocation = true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if CLLocationManager.locationServicesEnabled() == false {
            let alert = UIAlertController.init(title: "Location Service is Disabled!", message:"Please open in Settings->Privacy->Location Services", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"OK",style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            if  CLLocationManager.authorizationStatus() == .notDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            } else if  CLLocationManager.authorizationStatus() == .denied {
                let alert = UIAlertController.init(title: "Location Service is Disabled!", message:"Please enable location service for Waylens 360", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Enable", style: .destructive, handler: { (alert : UIAlertAction) in
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }))
                alert.addAction(UIAlertAction(title:"OK",style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        Mixpanel.mainInstance().track(event: "Enter Remote Tab")
        super.viewDidAppear(animated)
        map.showsUserLocation = true
//#if DEBUG && FOO
        WaylensClientS.remoteCameraModel.reloadCameraList()
//#endif

        let currentRegion : MKCoordinateRegion = MKCoordinateRegion(center: map.centerCoordinate,
                                                                    span: MKCoordinateSpanMake(0.01, 0.01))
        map.setRegion(currentRegion, animated: false)

        self.navigationController?.navigationBar.isTranslucent = true
        self.tabBarController?.title = "My 360Cam"

        WaylensClientS.remoteCameraModel.delegate = self
        self.cameraListUpdated(err: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        WaylensClientS.remoteCameraModel.delegate = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil

        setLatitude(Float(map.userLocation.coordinate.latitude))
        setLongitude(Float(map.userLocation.coordinate.longitude))
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        map.showsUserLocation = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func onAlertButton() {
        let alertVC = UIStoryboard.init(name: "Alert", bundle: nil).instantiateViewController(withIdentifier: "AlertListViewController")
        self.tabBarController?.show(alertVC, sender: self)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func onAccountButton() {
        let accountVC =  UIStoryboard.init(name: "Account", bundle: nil).instantiateViewController(withIdentifier: "AccountViewController")
        self.tabBarController?.show(accountVC, sender: self)
    }

    func cameraListUpdated(err: Error?) {
        if err != nil {
            let alert = UIAlertController.init(title: "Get Camera List Failed!", message: err!.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"OK",style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.onGetCameraList(WaylensClientS.remoteCameraModel.cameraList)
        }
    }
    func onGetCameraList(_ list : Array<RemoteCamera>?) {
        map.removeAnnotations(annotations)
        annotations.removeAll()
        NSLog("\(String(describing: list))")
        if (list != nil) {
            var index = 0
            for cam in list! {
                let point = MKPointAnnotation()
                point.title = cam.nickName
                point.subtitle = cam.cameraID
                point.coordinate = cam.location!
                map.addAnnotation(point)
                annotations.append(point)
                NSLog("add pin: \(point.coordinate.latitude), \(point.coordinate.longitude), \(String(describing: point.title))")
                index += 1
            }
        }
        if annotations.count > 0 {
            map.selectAnnotation(annotations[0], animated: true)
        }
        self.cameraList.reloadData()
        self.noCamera.isHidden = (WaylensClientS.remoteCameraModel.numOfCameras() != 0)
    }

    // MARK: - Table view delegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 32
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delAction = UITableViewRowAction.init(style: .destructive, title: "Unbind") { (action, ip) in
            // Delete the row from the data source
            let cam = WaylensClientS.remoteCameraModel.getCameraAtIndex(indexPath.row)
            let alert = UIAlertController.init(title: "Unbind Camera \(cam!.nickName)?", message: "Camera ID:\(String(describing: cam?.cameraID))", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Unbind", style: .default, handler: { (action) in
                WaylensClientS.shared.doUnbindCamera(cam!.cameraID, success: { (result) in
                }, failed: { (error) in
                    let alert = UIAlertController.init(title: "Unbind Camera \(cam!.nickName) failed!", message: "Error:\((error !=  nil) ? error!.description : "" )", preferredStyle: .alert)
                    alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)

                })
            }))
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        return [delAction]
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Add New Camera From the 2nd Tab \"In Car\""
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WaylensClientS.remoteCameraModel.numOfCameras()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CameraListCell", for: indexPath) as! CameraListCell
        let cam = WaylensClientS.remoteCameraModel.getCameraAtIndex(indexPath.row)
        cell.setCam(cam: cam!)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let annotation = annotations[indexPath.row]
        if (selectCamera?.cameraID == annotation.subtitle!) {
            map.setCenter((selectCamera?.location)!, animated: true)
        } else {
            map.selectAnnotation(annotations[indexPath.row], animated: true)
        }
    }

    // MARK : - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let resueID = "RemoteTabViewControllerPin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: resueID) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation : annotation, reuseIdentifier: resueID)
        }
        pinView?.isSelected = true
        pinView?.canShowCallout = true
        pinView?.animatesDrop = false
//        NSLog("annotation.subtitle: \(annotation.subtitle)")
        let cam = WaylensClientS.remoteCameraModel.getCameraWithID(annotation.subtitle)
        if cam == nil {
            //my location
            pinView?.canShowCallout = true
            pinView?.pinTintColor = .green
            pinView?.rightCalloutAccessoryView = nil
            return nil
        }
        pinView?.pinTintColor = (cam?.isOnline == true) ? .blue : .darkGray
        if (cam?.isOnline == true) {
            let btn = UIButton.init(type: .infoLight)
            btn.addTarget(self, action: #selector(self.onClickAnnotation), for: .touchUpInside)
            pinView?.rightCalloutAccessoryView = btn
        } else {
            pinView?.rightCalloutAccessoryView = nil
        }
        return pinView
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pin = view.annotation
        let cam = WaylensClientS.remoteCameraModel.getCameraWithID(pin!.subtitle)
        if  cam == nil {
            return
        }
        selectCamera = cam
    }
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            view.isSelected = true
        }
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        let pin = view.annotation
        let cam = WaylensClientS.remoteCameraModel.getCameraWithID(pin!.subtitle)
        if  cam != nil {
            view.isSelected = true
            mapView.selectAnnotation(view.annotation!, animated: false)
        }
    }

    // MARK : - private
    func onClickAnnotation(_ btn : UIButton) {
        NSLog("on Click \(String(describing: selectCamera?.cameraID))")
        self.performSegue(withIdentifier: "showRemoteCamera", sender: self)
    }
    @IBAction func onClickTitle() {
        if (selectCamera != nil && (selectCamera!.isOnline)) {
            NSLog("on Click \(String(describing: selectCamera?.cameraID))")
            self.performSegue(withIdentifier: "showRemoteCamera", sender: self)
        }
    }

    @IBAction func onClickAdd() {
        if (DeviceManager.pInstance().getDeviceList().count == 0) {
            let alert = UIAlertController.init(title: "Please Connect to Camera AP", message:nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "I See", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController.init(title: "Please Bind Camera From 2nd Tab", message:nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "I See", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showRemoteCamera" {
            let vc = segue.destination as? RemoteCameraViewController
            vc?.camera = self.selectCamera
        }
        if segue.identifier == "RemoteCameraSettingsVC" {
            let index = self.cameraList.indexPath(for: sender as! UITableViewCell)
            self.selectCamera =  WaylensClientS.remoteCameraModel.getCameraAtIndex(index!.row)
            let vc = segue.destination as? RemoteCameraViewController//RemoteCameraViewDetailController
            vc?.camera = self.selectCamera
        }
    }
}
