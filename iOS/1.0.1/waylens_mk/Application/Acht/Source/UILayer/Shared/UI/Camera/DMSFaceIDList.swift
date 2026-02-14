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
import WaylensFoundation
import WaylensCameraSDK
import SwiftAlertView
import SVProgressHUD

struct DataFW : Codable {
    let faceId : String
    let cameraSn : String
    let numberId : String
}


struct DataDelFW : Codable {
   
    let cameraSn : String
   
}

class DMSFaceIDList : NSObject, WLSocketClientConnectionDelegate, WLDmsClientDelegate,
UITableViewDelegate, UITableViewDataSource {
    var cccdTextField: UITextField!
    var tabView : UITableView?
    var dmsClient : WLDmsClient?

    var superView : UIView?
    var superViewController : UIViewController?

    var inited = false

    var faceList = Array<Dictionary<AnyHashable, Any>>()

    private var addFaceTimeoutTimer: Timer?
    
    var cameraUnified: UnifiedCamera?
    
    let config = ApplyCameraConfigMK()
    

    public init(superview: UIView, vc: UIViewController, camera: WLCameraDevice, cameraUnified: UnifiedCamera) {
        super.init()
        self.cameraUnified = cameraUnified
        config.camera = cameraUnified
        print("cameraUnified.sn",cameraUnified.sn)
        tabView = UITableView(frame: superview.bounds, style: .grouped)
        superView = superview
        superViewController = vc
        if (self.dmsClient == nil) {
            self.dmsClient = WLDmsClient.init(iPv4: camera.getIPV4(), iPv6: nil, port: 1368)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceivedaddFaceDataCam), name: NSNotification.Name(rawValue: "addFaceDataCam"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationReceivedremoveFaceDataCam), name: NSNotification.Name(rawValue: "removeFaceDataCam"), object: nil)
        
    }

    var id : UInt64?
    var faceId : UInt64?
    
    @objc func notificationReceivedremoveFaceDataCam(_ notification: Notification) {
        
        self.superViewController?.dismiss(animated: true, completion: {
            if let faceId = self.faceId{
                self.dmsClient?.removeFace(withID: faceId)
            }/*else{
                self.superViewController?.showToast(message: "Không lấy được faceId, Vui lòng thử lại", seconds: 1.0)
            }*/
            return
        })
      
      //  print ("text: \(text)")
    }
    @objc func notificationReceivedaddFaceDataCam(_ notification: Notification) {
      
       
        if  let driverName = notification.userInfo?["driverName"] as? String {
           
           
            self.addCamera(id: self.id!, userName: driverName)
            return
        }
      
      //  print ("text: \(text)")
    }
    
    deinit {
        dmsClient?.dmsDelegate = nil
        dmsClient?.connectionDelegate = nil
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
        self.dmsClient?.connectionDelegate = self
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
    func socketClientDidConnect(_ client: WLSocketClient) {
        if (client as? WLDmsClient == dmsClient) {
            dmsClient?.getVersion()
            dmsClient?.getAllFaces()
        }
    }

    func socketClient(_ client: WLSocketClient, didDisconnectWithError err: Error?) {

    }

    // MARK - WLDmsClientDelegate

    func dmsClient(_ dmsClient: WLDmsClient, didGetFaceList list: [[AnyHashable : Any]]) {
        Log.info("onGetFaceList: \(list)")

        inited = true
        faceList.removeAll()
        faceList.append(contentsOf: list)
        tabView?.reloadData()
    }

    func dmsClient(_ dmsClient: WLDmsClient, didAddFaceWithResult result: Int32) {
        Log.info("didAddFaceWithResult: \(result)")

        addFaceTimeoutTimer?.invalidate()
        addFaceTimeoutTimer = nil

        if result != 0 {
            showError()
        } else {
            dmsClient.getAllFaces()
        }
    }

    func dmsClient(_ dmsClient: WLDmsClient, didRemoveFaceWithResult result: Int32) {
        if result != 0 {
            showError()
        } else {
            usleep(200000)
            dmsClient.getAllFaces()
            //tabView?.reloadData()
        }
    }

    func dmsClient(_ dmsClient: WLDmsClient, didRemoveAllFaceWithResult result: Int32) {
        if result != 0 {
            showError()
        } else {
            usleep(200000)
            dmsClient.getAllFaces()
            //tabView?.reloadData()
        }
    }

    // MARK - WLDmsClientDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
//        if dmsClient?.vendor == 2 { // VENDOR_EYESIGHT
//            return 4
//        } else {
            return 3
//        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return faceList.count
        case 1:
            if  faceList.isEmpty {
                return 1
            }
            return 0
        case 3:
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if inited {
                if faceList.isEmpty {
                    return "No Faces"
                }
                else {
                    return "\(faceList.count) Face(s)"
                }
            }
            else {
                return "Loading..."
            }
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return faceList.isEmpty ? nil : "Tap to Remove."
//        case 2:
//            return "Tap the FACE button again to hide this page."
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: do {
            let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "DMSFaceIDListCell")
            let dict = self.faceList[indexPath.row]
            cell.textLabel?.text = (dict["name"] as? String) ?? "--"

            if let faceId = faceId(in: dict) {
                cell.detailTextLabel?.text = "ID: \(faceId)"
            }
            else {
                cell.detailTextLabel?.text = nil
            }

            return cell
            }
        case 1: do {
            
            let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "DMSFaceIDListAddCell")
            cell.textLabel?.text = "Thêm face mới"
            return cell
            
            }
//        case 2: do {
//            let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "DMSFaceIDListRemovAllCell")
//            cell.textLabel?.text = "Remove All Faces"
//            return cell
//            }
        case 3: do {
            let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "DMSFaceIDCalibCell")
            cell.textLabel?.text = "Calib the DMS Camera"
            return cell
            }
        default:
            return UITableViewCell.init(style: .subtitle, reuseIdentifier: "DMSFaceIDListRemovNULLCell")
        }
    }
    
    func addCamera(id : UInt64 , userName : String ) {
           //print("self.dmsClient",self.dmsClient)
           self.addFaceTimeoutTimer?.invalidate()
        
           self.addFaceTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { (timer) in
               
               self.dmsClient?.getAllFaces()

               self.addFaceTimeoutTimer?.invalidate()
               self.addFaceTimeoutTimer = nil
               self.tabView?.reloadData()
               self.superViewController?.dismiss(animated: true, completion: nil)
                           
               
                          
                          
            
            })
      
            self.dmsClient!.addFace(withID: id, name: userName)
        
            self.inited = false
            self.superViewController?.showAlert(title: "Thông báo", message: "Gửi lệnh thêm face thành công")
          //  self.tabView?.reloadData()
    }
    
    
    func showloading(maxTime: TimeInterval)  {
        
        let loadingVC = LoadingViewController()

        // Animate loadingVC over the existing views on screen
        loadingVC.modalPresentationStyle = .overCurrentContext

        // Animate loadingVC with a fade in animation
        loadingVC.modalTransitionStyle = .crossDissolve


        self.superViewController?.present(loadingVC, animated: true, completion: {
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + maxTime) {
                
                self.superViewController?.dismiss(animated: true, completion: nil)
                
            }
            
           
        })

    }
    
    func showProgress(val : Bool){
        val ? SVProgressHUD.show() : SVProgressHUD.dismiss()
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

            if let faceId = faceId(in: dict) {
                self.faceId = faceId
                let dialogMessage = UIAlertController.init(title: "Xóa face " + (dict["name"] as! String) + "?", message: nil, preferredStyle: .alert)
                dialogMessage.addColorInTitleAndMessage(color: .brown, titleFontSize: 12, messageFontSize: 12)
                let label = UILabel(frame: CGRect(x: 0, y: 8, width: 270, height:18))
                label.textAlignment = .center
                label.textColor = .red
                label.font = label.font.withSize(12)
                dialogMessage.view.addSubview(label)
                label.isHidden = true

                let Create = UIAlertAction(title: "Đồng ý", style: .default, handler: { (action) -> Void in
                    self.inited = false
                    tableView.reloadData()


                    let val = DataDelFW(cameraSn: self.cameraUnified?.sn ?? "")
                    let jsonEncoder = JSONEncoder()
                    let jsonData = try? jsonEncoder.encode(val)
                    let json = String(data: jsonData!, encoding: String.Encoding.utf8)
                    let dict : [String : Any] = [
                        "content" : json ?? "" ,
                        "url" : "http://103.107.183.97:8600/fms/api/delete/faceid"
                    ]



                   
                    self.config.buildRemoveFace(dict: dict)
                    self.showProgress(val: true)

                })
                let cancel = UIAlertAction(title: "Hủy", style: .default) { (action) -> Void in
                    print("Cancel button tapped")
                }

                //Add OK and Cancel button to dialog message

                dialogMessage.addAction(Create)
                dialogMessage.addAction(cancel)
                // Present dialog message to user
                self.superViewController?.present(dialogMessage, animated: true, completion: nil)
                
            }
        }
            break
        case 1:
            do {
                

                let dialogMessage = UIAlertController(title: "Vui lòng nhìn vào DMS và đảm bảo khuôn mặt của bạn có thể quan sát rõ ràng.", message: nil, preferredStyle: .alert)
                dialogMessage.addColorInTitleAndMessage(color: .darkText, titleFontSize: 12, messageFontSize: 12)
                let label = UILabel(frame: CGRect(x: 0, y: 8, width: 270, height:18))
                label.textAlignment = .center
                label.textColor = .red
                label.font = label.font.withSize(12)
                dialogMessage.view.addSubview(label)
                label.isHidden = true

                let Create = UIAlertAction(title: "Thêm", style: .default, handler: { (action) -> Void in
                    if let cccdInput = self.cccdTextField!.text {
                        if cccdInput == "" {
                            label.text = "Hãy nhập thông tin Số CCCD"
                            label.isHidden = false
                            self.superViewController?.present(dialogMessage, animated: true, completion: nil)
                            
                        } else if cccdInput.count != 12 {
                         
                            label.text = "Độ dài CCCD là 12 số"
                            label.isHidden = false
                            self.superViewController?.present(dialogMessage, animated: true, completion: nil)
                                                                          }
                        else{
                            print("Create button success block called do stuff here....")
                            
                            
                                       self.id = self.generateFaceId()
                      
                            let val = DataFW(faceId: "\(self.id!)", cameraSn: self.cameraUnified?.sn ?? "", numberId: cccdInput)
                          
                                      let jsonEncoder = JSONEncoder()
                            let jsonData = try? jsonEncoder.encode(val)
                            let json = String(data: jsonData!, encoding: String.Encoding.utf8)
                                      let dict : [String : Any] = [
                                        "content" : json ?? "" ,
                                         "url" : "http://103.107.183.97:8600/fms/api/update/faceid",
                                      ]
                      
                                      self.config.buildAddFace(dict: dict)
//                                      self.showloading(maxTime: 10)
                            self.showProgress(val: true)

                      
                      
                                      self.inited = false
                        }

                    }
                })
                let cancel = UIAlertAction(title: "Hủy", style: .default) { (action) -> Void in
                    print("Cancel button tapped")
                }

                //Add OK and Cancel button to dialog message

                dialogMessage.addAction(Create)
                dialogMessage.addAction(cancel)
                // Add Input TextField to dialog message
                dialogMessage.addTextField { (textField) -> Void in
                    
                    self.cccdTextField = textField
                    self.cccdTextField.keyboardType = .numberPad
                    self.cccdTextField?.placeholder = "Vui lòng nhập CCCD."
                }

                // Present dialog message to user
                self.superViewController?.present(dialogMessage, animated: true, completion: nil)
    

          }
            break
//        case 2: do {
//            let alert = UIAlertController.init(title: "Remove All Faces?", message: nil, preferredStyle: .alert)
//            alert.addAction(UIAlertAction.init(title: "Yes", style: .default, handler: { (action) in
//                self.inited = false
//                tableView.reloadData()
//                self.dmsClient?.removeAllFaces()
//            }))
//            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: { (action) in
//            }))
//            superViewController?.present(alert, animated: true, completion: nil)
//        }
//            break
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
            self.dmsClient?.calibrateWith(x: x, y: y, z: z, completionHandler: { [weak self] success in
                self?.calibrateCompletionHandler(success)
            })
        }
    }

    func audioServicesPlaySystemSoundCompleted(soundID: SystemSoundID) {
        AudioServicesRemoveSystemSoundCompletion(soundID)
        AudioServicesDisposeSystemSoundID(soundID)
    }

    private func calibrateCompletionHandler(_ success: Bool) {
        if success {
            let alert = UIAlertController.init(title: "Calib Done!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: { (action) in
            }))
            superViewController?.present(alert, animated: true, completion: nil)
        } else {
            showError()
        }
    }

}

private extension DMSFaceIDList {

    func faceId(in dict: [AnyHashable : Any]) -> UInt64? {
        guard let high = dict["faceid_hi"] as? UInt64, let low = dict["faceid_lo"] as? UInt64 else {
            return nil
        }
        return UInt64.wl.init((high: high, low: low)).base
    }

    func generateFaceId() -> UInt64 {
        let faceIds = self.faceList.compactMap{ faceId(in: $0) }

        var newFaceId: UInt64
        repeat {
            newFaceId = UInt64.random(in: 1...UInt64.max)
            Log.debug("New Face ID: \(newFaceId)")
        } while faceIds.contains(newFaceId) // If the same ID existed.

        return newFaceId
    }

}





extension UIAlertController{

func addColorInTitleAndMessage(color:UIColor,titleFontSize:CGFloat = 18, messageFontSize:CGFloat = 13){

    let attributesTitle = [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: titleFontSize)]
    let attributesMessage = [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: messageFontSize)]
    let attributedTitleText = NSAttributedString(string: self.title ?? "", attributes: attributesTitle)
    let attributedMessageText = NSAttributedString(string: self.message ?? "", attributes: attributesMessage)

    self.setValue(attributedTitleText, forKey: "attributedTitle")
    self.setValue(attributedMessageText, forKey: "attributedMessage")

}}



