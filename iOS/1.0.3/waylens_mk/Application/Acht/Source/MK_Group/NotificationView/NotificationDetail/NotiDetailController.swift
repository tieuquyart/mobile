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
    @IBOutlet weak var fleetNameLabel: UILabel!
    @IBOutlet weak var plateNoLabel: UILabel!
    @IBOutlet weak var createTimeLabel: UILabel!
    @IBOutlet weak var eventTypeLabel: UILabel!
    @IBOutlet weak var simchangeStatus: UILabel!
    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var subscriptionNameLabel: UILabel!
    
    var model : NotiItem!
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
        newBackButton.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
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

                ConstantMK.parseJson(dict: value, handler: {success, msg, code in
                    if success{
                        if let data = value["data"] as? Bool {
                            if data {
                                self.alert(title: "", message: "Cập nhật thành công")
                            } else  {
                                self.alert(title: "", message: "Cập nhật thất bại")
                            }

                        }
                    }else{
                        self.showErrorResponse(code: code)
                    }
                })
            case .failure(let err):
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self.navigationController)
            }
        }

        
    }
    
    
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
        
        let attributedTextEventType = NSMutableAttributedString(string: "\(title) :" , attributes: [NSAttributedString.Key.font : UIFont(name: "BeVietnamPro-Bold", size: 14)!])
        
        attributedTextEventType.append(NSAttributedString(string: NSLocalizedString(info ?? "null", comment: info ?? "null")  , attributes: [NSAttributedString.Key.font : UIFont(name: "BeVietnamPro-Bold", size: 14)!]))
        
        if let _ = info {
            label.isHidden = false
            label.attributedText = attributedTextEventType
        } else {
            label.isHidden = true
        }
        
        
    }

    func setBorderView(view : UIView) {
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.backgroundColor = UIColor.white
        view.layer.borderColor = UIColor.white.cgColor
    }
    

    func config() {
        setTitle(label: categoryLabel, title: "Phân loại", info: model.category ?? "")
        setTitle(label: eventTypeLabel, title: "Hành vi", info: model.eventType?.description ?? "")
        setTitle(label: fleetNameLabel , title: "Tên Fleet", info: model.fleetName)
        setTitle(label: plateNoLabel, title: "Biển số xe", info: model.plateNo)
        setTitle(label: createTimeLabel, title: "Thời gian", info: (model.eventTime ?? "").replacingOccurrences(of: "T", with: " "))
        setTitle(label: subscriptionNameLabel, title: "Sản phẩm", info: model.subscriptionName)
        
        setTitle(label: deviceLabel, title: "Thiết bị", info: model.cameraSn)
        
        if model.eventType?.toString().lowercased() == "SIMCARDINFOCHANGED".lowercased() {
            self.simchangeStatus.isHidden = false
            setTitle(label: simchangeStatus, title: "Trạng thái", info: model.statusUpdatePhone ?? false ? "Đã cập nhật" : "Chưa cập nhật")
        }else{
            self.simchangeStatus.isHidden = true
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
}
