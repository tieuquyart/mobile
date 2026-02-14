//
//  DMSFaceIDList.swift
//  Acht
//
//  Created by gliu on 1/5/20.
//  Copyright © 2020 waylens. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox


class DMSFaceIDList : NSObject, TSClientConnectionDelegate, DMSClientDelegate,
UITableViewDelegate, UITableViewDataSource {

    var tabView : UITableView?
    var dmsClient : DMSClient?

    var superView : UIView?
    var superViewController : UIViewController?

    var inited = false

    var faceList = Array<Dictionary<AnyHashable, Any>>()

    public init(superview: UIView, vc: UIViewController, camera: CameraDevice) {
        super.init()
        tabView = UITableView(frame: superview.bounds, style: .grouped)
        superView = superview
        superViewController = vc
        if (self.dmsClient == nil) {
            self.dmsClient = DMSClient.init(iPv4: camera.getIPV4(), iPv6: nil, port: 1368, carrier: nil)
        }
    }

    deinit {
        dmsClient?.dmsDelegate = nil
        dmsClient?.pConnectionDelegate = nil
        dmsClient?.disconnect()
        dmsClient = nil
        tabView?.removeFromSuperview()
        tabView?.dataSource = nil
        tabView?.delegate = nil
        tabView = nil
    }

    func update() {
        tabView?.delegate = self
        tabView?.dataSource = self
        self.dmsClient?.pConnectionDelegate = self
        self.dmsClient?.dmsDelegate = self
        if dmsClient?.isConnected() == false {
            self.dmsClient?.connect()
        }
        if tabView?.superview == nil {
            superView?.addSubview(tabView!)
            tabView?.reloadData()
        }
    }

    private func showError() {
        let alert = UIAlertController.init(title: "Opration Failed!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: { (action) in
        }))
        superViewController?.present(alert, animated: true, completion: nil)
    }

    private func showDisconnect() {
        let alert = UIAlertController.init(title: "DMS is not Connected!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Connect", style: .cancel, handler: { (action) in
            self.dmsClient?.connect()
        }))
        superViewController?.present(alert, animated: true, completion: nil)
    }

    // MARK - TSClientConnectionDelegate
    func onConnected(_ client: Any!) {
        if (client as? DMSClient == dmsClient) {
            dmsClient?.getVersion()
            dmsClient?.getAllFaces()
        }
    }
    // MARK - DMSClientDelegate
    func onDisconnected(_ client: Any!, withErr err: Error!) {
        //
    }

    func onGetFaceList(_ list: [[AnyHashable : Any]]!) {
        NSLog("onGetFaceList get: %d", list.count);
        inited = true
        faceList.removeAll()
        faceList.append(contentsOf: list)
        tabView?.reloadData()
    }

    func onAddFaceResult(_ result: Int32) {
        if result != 0 {
            showError()
        } else {
            usleep(500000)
            dmsClient?.getAllFaces()
            //tabView?.reloadData()
        }
    }

    func onRemoveFaceResult(_ result: Int32) {
        if result != 0 {
            showError()
        } else {
            usleep(200000)
            dmsClient?.getAllFaces()
            //tabView?.reloadData()
        }
    }

    func onRemoveAllFaceResult(_ result: Int32) {
        if result != 0 {
            showError()
        } else {
            usleep(200000)
            dmsClient?.getAllFaces()
            //tabView?.reloadData()
        }
    }

    func onCalibResult(_ result: Int32) {
        if result != 0 {
            showError()
        } else {
            let alert = UIAlertController.init(title: "Calib Done!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: { (action) in
            }))
            superViewController?.present(alert, animated: true, completion: nil)
        }
    }

    // MARK - DMSClientDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        if dmsClient?.vendor == 2 { // VENDOR_EYESIGHT
            return 4
        } else {
            return 3
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return faceList.count
        case 1, 2:
            return 1
        case 3:
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: do {
            if faceList.count == 0 {
                return inited ? "No Faces" : "Loading..."
            } else {
                return "Click to Remove."
            }
        }
        case 2:
            return "press the FACE button again to hide this page."
        default:
            break
        }
        return ""
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: do {
            let cell = UITableViewCell.init(style: .value1, reuseIdentifier: "DMSFaceIDListCell")
            let dict = self.faceList[indexPath.row]
            cell.textLabel?.text = (dict["name"] as? String) ?? "--"
            cell.detailTextLabel?.text = "\(dict["faceid_lo"] as? Int32 ?? 0)"
            return cell
            }
        case 1: do {
            let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "DMSFaceIDListAddCell")
            cell.textLabel?.text = "Click to add new Face"
            return cell
            }
        case 2: do {
            let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "DMSFaceIDListRemovAllCell")
            cell.textLabel?.text = "Click to Remove All Faces"
            return cell
            }
        case 3: do {
            let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "DMSFaceIDCalibCell")
            cell.textLabel?.text = "Click to Calib the DMS Camera"
            return cell
            }
        default:
            return UITableViewCell.init(style: .subtitle, reuseIdentifier: "DMSFaceIDListRemovNULLCell")
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.inited == false {
            return
        }
        if (dmsClient?.isConnected() ?? false == false) {
            showDisconnect()
            return
        }
        switch indexPath.section {
        case 0: do {
            let dict = self.faceList[indexPath.row]
            var faceid = UInt64(0)
            faceid = UInt64(dict["faceid_lo"] as? Int32 ?? 0) + UInt64(dict["faceid_hi"] as? Int32 ?? 0) * UInt64(0x100000000)
            let alert = UIAlertController.init(title: "Remove " + (dict["name"] as! String) + "?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { (action) in
                self.inited = false
                tableView.reloadData()
                self.dmsClient?.removeFace(withID: faceid)
            }))
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (action) in
            }))
            superViewController?.present(alert, animated: true, completion: nil)
        }
            break
        case 1: do {
            let alert = UIAlertController.init(title: nil, message: "Make sure your face is clear", preferredStyle: .alert)
            alert.addTextField { (textfeild) in
                textfeild.placeholder = "Please Enter a Name"
                textfeild.returnKeyType = .done
            }
            alert.addAction(UIAlertAction.init(title: "Add Face", style: .default, handler: { (action) in
                if alert.textFields?[0].text != nil &&
                    alert.textFields![0].text! != "" {
                    self.inited = false
                    tableView.reloadData()
                    var currentMax = UInt64(0)
                    for dict in self.faceList {
                        let faceid = UInt64(dict["faceid_lo"] as? Int32 ?? 0) + UInt64(dict["faceid_hi"] as? Int32 ?? 0) * UInt64(0x100000000)
                        if currentMax < faceid {
                            currentMax = faceid
                        }
                    }
                    self.dmsClient?.addFace(withID: currentMax + UInt64(1), name: alert.textFields![0].text!)
                }
            }))
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (action) in
            }))
            superViewController?.present(alert, animated: false, completion: {
                alert.view.center.y += alert.view.bounds.height/2
            })
        }
            break
        case 2: do {
            let alert = UIAlertController.init(title: "Remove All Faces?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { (action) in
                self.inited = false
                tableView.reloadData()
                self.dmsClient?.removeAllFaces()
            }))
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (action) in
            }))
            superViewController?.present(alert, animated: true, completion: nil)
        }
            break
        case 3: do {
            let alert = UIAlertController.init(title: "What type is your vehicle?", message: "After select vehicle type, please sit properly and look straight ahead at the road in the next 3 seconds", preferredStyle: .actionSheetOrAlertOnPad)
            alert.addAction(UIAlertAction.init(title: "Small/Middle Car", style: .default, handler: { (action) in
                self.doCalibWith(x: 105, y: -38, z: 88)
            }))
            alert.addAction(UIAlertAction.init(title: "Large Car", style: .default, handler: { (action) in
                self.doCalibWith(x: 120, y: -42, z: 90)
            }))
            alert.addAction(UIAlertAction.init(title: "Small/Middle SUV", style: .default, handler: { (action) in
                self.doCalibWith(x: 115, y: -40, z: 110)
            }))
            alert.addAction(UIAlertAction.init(title: "Large SUV", style: .default, handler: { (action) in
                self.doCalibWith(x: 125, y: -42, z: 110)
            }))
            alert.addAction(UIAlertAction.init(title: "Pickup/Commercial Truck", style: .default, handler: { (action) in
                self.doCalibWith(x: 115, y: -45, z: 130)
            }))
            alert.addAction(UIAlertAction.init(title: "Manuall Input", style: .default, handler: { (action) in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200)) {
                    let alertM = UIAlertController.init(title: "Please input Driver Position", message: "input x, y, z location the vehicle’s coordinate system.\n" +
                        "X: Centimeter behind the wing mirror.\n" +
                        "Y: Centimeter of the Center-Left distance.\n" +
                        "Z: Centimeter of eye height from the wheel axle.\n\n" +
                "After Action, please sit properly and look straight ahead at the road in the next 3 seconds", preferredStyle: .alert)
                    alertM.addTextField { (textField) in
                        textField.clearButtonMode = .always
                        textField.placeholder = NSLocalizedString("X", comment: "X")
                        textField.keyboardType = .numberPad
                        textField.returnKeyType = .next
                    }
                    alertM.addTextField { (textField) in
                        textField.clearButtonMode = .always
                        textField.placeholder = NSLocalizedString("Y", comment: "Y")
                        textField.keyboardType = .numberPad
                        textField.returnKeyType = .next
                    }
                    alertM.addTextField { (textField) in
                        textField.clearButtonMode = .always
                        textField.placeholder = NSLocalizedString("Z", comment: "Z")
                        textField.keyboardType = .numberPad
                        textField.returnKeyType = .done
                    }
                    alertM.addAction(UIAlertAction.init(title: "Action", style: .default, handler: { (action) in
                        self.doCalibWith(x: (alertM.textFields![0].text! as NSString).floatValue,
                                         y: (alertM.textFields![1].text! as NSString).floatValue,
                                         z: (alertM.textFields![2].text! as NSString).floatValue)
                    }))
                    alertM.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (action) in
                    }))
                    self.superViewController?.present(alertM, animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (action) in
            }))
            superViewController?.present(alert, animated: true, completion: nil)
        }
            break
        default:
            break
        }
    }

    func doCalibWith(x: Float, y: Float, z: Float) {
        if (dmsClient?.isConnected() ?? false == false) {
            showDisconnect()
            return
        }
        let soundPath = Bundle.main.path(forResource: "countdown_3s", ofType: "m4a")

        var soundID:SystemSoundID = 0
        let baseURL = NSURL(fileURLWithPath: soundPath!)
        AudioServicesCreateSystemSoundID(baseURL, &soundID)

        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        AudioServicesAddSystemSoundCompletion(soundID, nil, nil, {
            (soundID, inClientData) -> Void in
            let mySelf = Unmanaged<DMSFaceIDList>.fromOpaque(inClientData!)
                .takeUnretainedValue()
            mySelf.audioServicesPlaySystemSoundCompleted(soundID: soundID)
        }, observer)

        AudioServicesPlayAlertSound(soundID)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(3200)) {
            self.dmsClient?.doCalibWith(x: x, y: y, z: z)
        }
    }

    func audioServicesPlaySystemSoundCompleted(soundID: SystemSoundID) {
        AudioServicesRemoveSystemSoundCompletion(soundID)
        AudioServicesDisposeSystemSoundID(soundID)
    }
}
