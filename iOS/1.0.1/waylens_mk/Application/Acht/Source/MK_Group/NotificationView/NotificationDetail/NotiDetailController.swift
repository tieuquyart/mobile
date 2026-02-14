//
//  NotiDetailController.swift
//  Acht
//
//  Created by TranHoangThanh on 8/16/22.
//  Copyright © 2022 waylens. All rights reserved.
//

import UIKit
import AlamofireImage
import BMPlayer
import LBTATools
import MapKit
import SwiftyJSON





class NotiDetailController: BaseViewController {
    
    @IBOutlet weak var viewContainerInfo: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var fleetNameLabel: UILabel!
    @IBOutlet weak var cameraSnLabel: UILabel!
    @IBOutlet weak var plateNoLabel: UILabel!
    @IBOutlet weak var gpsLongitudeLabel: UILabel!
    @IBOutlet weak var gpsLatitudeLabel: UILabel!
    @IBOutlet weak var gpsAltitudeLabel: UILabel!
    @IBOutlet weak var gpsHdopLabel: UILabel!
    @IBOutlet weak var gpsHeadingLabel: UILabel!
    @IBOutlet weak var gpsSpeedLabel: UILabel!
    @IBOutlet weak var gpsTimeLabel: UILabel!
    @IBOutlet weak var createTimeLabel: UILabel!
    @IBOutlet weak var gpsVdopLabel: UILabel!
    @IBOutlet weak var eventTypeLabel: UILabel!
    @IBOutlet weak var simchangeStatus: UILabel!
    @IBOutlet weak var player: BMCustomPlayer!
    
    @IBOutlet weak var subscriptionNameLabel: UILabel!
    
    var model : NotiItem!
    
    
    @IBOutlet weak var containerVideo: UIView!
    
    @IBOutlet weak var containerImage: UIView!
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var containerMap: UIView!
    
    @IBOutlet weak var deviceLabel: UILabel!
    let mapView = MKMapView()
    let hudContainer = UIView(backgroundColor: .white)
    
    var phoneTextField : UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Nội dung thông báo"
        config()
        	
        if model.markRead == false  {
            readNotification()
        }
        
        containerMap.addSubview(mapView)
        mapView.fillSuperview()
        mapView.showsUserLocation = true
        mapView.delegate = self

        if model.eventType?.toString().lowercased() == "SIMCARDINFOCHANGED".lowercased()  {
            if let phoneUpdate  = model.statusUpdatePhone {
                if !phoneUpdate {
                    customAlert()
                }
                
            }
           
        }

        setBorderView(view: self.viewContainerInfo)
      
      
        self.navigationItem.setHidesBackButton(true, animated: false)
        let newBackButton = UIBarButtonItem(image:UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: Notification.Name.ReloadNotiList.reload, object: nil,userInfo: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func updatePhone( phone  : String) {
        let param : JSON = [
            "serial" : model.cameraSn!,
            "phone": phone,
            "notificationId" : model.id!
        ]
        
        NotificationServiceMK.shared.updateMobile(pr: param){ (result) in
            switch result {
            case .success(let value):

                ConstantMK.parseJson(dict: value, handler: {success, msg in
                    if success{
                        if let data = value["data"] as? Bool {
                            if data {
                                self.showAlert(title: "", message: "Cập nhật thành công")
                            } else  {
                                self.showAlert(title: "", message: "Cập nhật thất bại")
                            }

                        }
                    }else{
                        self.showErrorResponse(msg: msg)
                    }
                })
            case .failure(let err):
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self.navigationController)
            }
        }

        
    }
    
    
//    func validate(value: String) -> Bool {
//        let PHONE_REGEX = "(84|0[3|5|7|8|9])+([0-9]{8})"
//        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
//        let result = phoneTest.evaluate(with: value)
//        return result
//    }
    
    func customAlert() {
        let dialogMessage = UIAlertController(title: "Số điện thoại trên camera của quý khách đã thay đổi! Quý khách vui lòng nhập số điện thoại để cập nhật lên FMS", message: nil, preferredStyle: .alert)
        dialogMessage.addColorInTitleAndMessage(color: .brown, titleFontSize: 12, messageFontSize: 12)
        let label = UILabel(frame: CGRect(x: 0, y: 8, width: 270, height:18))
        label.textAlignment = .center
        label.textColor = .red
        label.font = label.font.withSize(12)
        dialogMessage.view.addSubview(label)
        label.isHidden = true

        let Create = UIAlertAction(title: "Đồng ý", style: .default, handler: { (action) -> Void in
            if let phoneInput = self.phoneTextField!.text {
                if phoneInput == "" {
                    label.text = "Hãy nhập Số điện thoại"
                    label.isHidden = false
                    self.present(dialogMessage, animated: true, completion: nil)

                }
                else  if phoneInput.validatePhone() {
                    print("Create button success block called do stuff here....")
                    self.updatePhone(phone: phoneInput)
                } else {
                    label.text = "Lỗi định dạng Số điện thoại"
                    label.isHidden = false
                    self.present(dialogMessage, animated: true, completion: nil)
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

            self.phoneTextField = textField
            self.phoneTextField?.keyboardType = .numberPad
            self.phoneTextField?.placeholder = "Please Enter a Phone."
        }

        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    
    fileprivate func setupRegionForMap() {
        let centerCoordinate = CLLocationCoordinate2D(latitude: 21.0304737, longitude: 105.783538)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }



   
    
    
    var isVideo = false
 
    
    func startVideo(val: String) {
        
        let vc = PlayerVideoNotiViewController(nibName: "PlayerVideoNotiViewController", bundle: nil)
        vc.url = val
        self.navigationController?.pushViewController(vc, animated: true)
      
    }

    func setTitle(label : UILabel , title : String , info : String?) {
        
        let attributedTextEventType = NSMutableAttributedString(string: "\(title) :" , attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        
        attributedTextEventType.append(NSAttributedString(string: NSLocalizedString(info ?? "null", comment: info ?? "null")  , attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)]))
        
        if let _ = info {
            label.isHidden = false
            label.attributedText = attributedTextEventType
        } else {
            label.isHidden = true
        }
        
        
    }
    
//    "id":3572861187630563329,
//    "category":"PAYMENT",
//    "eventType":"SUCCESS",
//    "eventTime":"2022-09-21T13:52:20.285",
//    "eventRemark":null,
//    "fleetId":2,
//    "fleetName":"MK Vision",
//    "createTime":"2022-09-21T13:52:20",
//    "alert":"You Have A Successful Payment Order",
//    "markRead":false,
//    "cameraSn":null,
//    "driverName":null,
//    "driverId":null,
//    "plateNo":null,
//    "clipId":null,
//    "url":null,
//    "clipDuration":null,
//    "gpsLongitude":null,
//    "gpsLatitude":null,
//    "gpsAltitude":null,
//    "gpsHdop":null,
//    "gpsVdop":null,
//    "gpsHeading":null,
//    "gpsSpeed":null,
//    "gpsTime":null,
//    "accountName":null,
//    "success":true,
//    "orderId":null,
//    "errorMsg":null,
//    "subscriptionName":"Combo",
//    "amount":100000,
//    "currency":"VND"
    func setBorderView(view : UIView) {
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.backgroundColor = UIColor.white
        view.layer.borderColor = UIColor.white.cgColor
    }
    

    func config() {
        self.setBorderView(view: self.containerVideo)
        self.setBorderView(view: self.containerMap)
        setTitle(label: idLabel, title: "Id", info: "\(model.id ?? "")")
        setTitle(label: categoryLabel, title: "Phân loại", info: model.category ?? "")
        setTitle(label: eventTypeLabel, title: "Hành vi", info: model.eventType?.description ?? "")
        setTitle(label: fleetNameLabel , title: "Tên Fleet", info: model.fleetName)
       // setTitle(label: fleetNameLabel , title: "Fleet Name", info: model.fleetName)
       // setTitle(label: cameraSnLabel, title: "Camera SN", info: model.cameraSn)
        setTitle(label: plateNoLabel, title: "Biển số xe", info: model.plateNo)
     //   setTitle(label: gpsLongitudeLabel, title: "GPS Longitude", info: "\(model.gpsLongitude ?? 0)")
       // setTitle(label: gpsLatitudeLabel, title: "GPS Latitudude", info: "\(model.gpsLatitude ?? 0)")
      //  setTitle(label: gpsAltitudeLabel , title: "GPS Latitude", info: "\(model.gpsAltitude ?? 0)")
//        setTitle(label: gpsHdopLabel, title: "GPS Hdop", info: "\(model.gpsHdop ?? 0)")
//        setTitle(label: gpsVdopLabel, title: "GPS Vdop", info: "\(model.gpsVdop ?? 0)")
//        setTitle(label: gpsHeadingLabel, title: "GPS Heading", info: "\(model.gpsHeading ?? 0)")
//        setTitle(label: gpsSpeedLabel, title: "GPS Speed", info: "\(model.gpsSpeed ?? 0)")
//        setTitle(label: gpsTimeLabel, title: "GPS Time", info: model.gpsTime )
        setTitle(label: createTimeLabel, title: "Thời gian", info: (model.eventTime ?? "").replacingOccurrences(of: "T", with: " "))
        setTitle(label: subscriptionNameLabel, title: "Sản phẩm", info: model.subscriptionName)
        
        setTitle(label: deviceLabel, title: "Thiết bị", info: model.cameraSn)
        
        if model.eventType?.toString().lowercased() == "SIMCARDINFOCHANGED".lowercased() {
            self.simchangeStatus.isHidden = false
            setTitle(label: simchangeStatus, title: "Trạng thái", info: model.statusUpdatePhone ?? false ? "Đã cập nhật" : "Chưa cập nhật")
        }else{
            self.simchangeStatus.isHidden = true
        }
        
        
        if let id = model.clipId  , id != ""  {
            if let _ = model.gpsLatitude {
                let strcategory =  (NSLocalizedString(model.category ?? "", comment: ""))
                let streventType =  (NSLocalizedString(model.eventType?.description ?? "", comment: ""))
                if let lat = model.gpsLatitude , let long = model.gpsLongitude {
                    
                    containerImage.isHidden = true
                    containerVideo.isHidden = true
                    containerMap.isHidden = false

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
            } else {
                containerImage.isHidden = true
                containerVideo.isHidden = false
                containerMap.isHidden = true
                let asset = BMPlayerResource(url: URL(string: model.url!)!,
                                             name: "",
                                             cover: nil,
                                             subtitle: nil)
                
                player.setVideo(resource: asset)
                
            }
              
        } else {
            
            
            if let url = model.url {
                        containerImage.isHidden = false
                        containerVideo.isHidden = true
                         containerMap.isHidden = true
                        let val = URL(string: url)!
                        imgView.af_setImage(withURL: val)
           } else {
               containerImage.isHidden = true
               containerVideo.isHidden = true
               containerMap.isHidden = true
           }
          
        }
    }
    
    func readNotification() {
      
        NotificationServiceMK.shared.user_notification_read(notificationId: model.id!) { (result) in
            switch result {
            case .success(let value):
                print("mark read noti \(value)")
                AppIconBadge.decrease()
            case .failure(let err):
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self.navigationController)
            }
        }
    }

}


extension NotiDetailController: MKMapViewDelegate {
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

extension NotiDetailController: CalloutViewDelegate {

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





class ViewEmbedder {

class func embed(
    parent:UIViewController,
    container:UIView,
    child:UIViewController,
    previous:UIViewController?){

    if let previous = previous {
        removeFromParent(vc: previous)
    }
    child.willMove(toParent: parent)
    parent.addChild(child)
    container.addSubview(child.view)
    child.didMove(toParent: parent)
    let w = container.frame.size.width;
    let h = container.frame.size.height;
    child.view.frame = CGRect(x: 0, y: 0, width: w, height: h)
}

class func removeFromParent(vc:UIViewController){
    vc.willMove(toParent: nil)
    vc.view.removeFromSuperview()
    vc.removeFromParent()
}

//class func embed(withIdentifier id: UIViewController, parent:UIViewController, container:UIView, completion:((UIViewController)->Void)? = nil){
//  //  let vc = parent.storyboard!.instantiateViewController(withIdentifier: id)
//    let vc = id
//    embed(
//        parent: parent,
//        container: container,
//        child: vc,
//        previous: parent.children.first
//    )
//    completion?(vc)
//}

}
