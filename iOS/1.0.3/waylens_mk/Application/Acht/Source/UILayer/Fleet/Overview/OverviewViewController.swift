//
//  OverviewViewController.swift
//  Acht
//
//  Created by forkon on 2019/9/24.
//  Copyright © 2019 waylens. All rights reserved.
//

import UIKit
import MapKit
import DropDown
import FirebaseMessaging

private extension OverviewViewController {
    func add(viewController : UIViewController , asChildViewController childController : UIViewController , direction : UIView.AnimationOptions) -> Void {
        viewController.addChild(childController)
        UIView.transition(with: viewController.view, duration: 0.3, options: direction, animations: {
            [viewController] in
            viewController.view.addSubview(childController.view)
        }, completion: nil)
        childController.view.frame = viewController.view.bounds
        childController.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        childController.didMove(toParent: viewController)
    }
    
    func remove(asChildViewController childController: UIViewController) -> Void {
        childController.willMove(toParent: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParent()
    }
}
class OverviewViewController: BaseViewController {
    @IBOutlet weak var imgViewMess: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    private lazy var goBackButton: UIBarButtonItem = { [weak self] in
        let goBackButton = UIBarButtonItem(image: UIImage(named: "navbar_back_n"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self?.goBackButtonTapped))
        goBackButton.imageInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        return goBackButton
    }()
    @IBOutlet weak var viewAlertMessage: UIView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    private(set) lazy var pinsManager: MapPinsManager = { [unowned self] in
        
        let pinsManager = MapPinsManager(mapView: self.mapView)
        return pinsManager
    }()
    
    private(set) lazy var overlayManager: MapOverlayManager = { [unowned self] in
        let overlayManager = MapOverlayManager(mapView: self.mapView)
        return overlayManager
    }()
    
    private(set) lazy var selectionManager: MapSelectionManager = { [unowned self] in
        let selectionManager = MapSelectionManager(mapView: self.mapView)
        return selectionManager
    }()
    
    private(set) lazy var actionCoordinator: MapActionCoordinator = { [weak self] in
        let coordinator = MapActionCoordinator()
        coordinator.overviewViewController = self
        return coordinator
    }()
    
    deinit {
        debugPrint("\(self) deinit")
        NotificationCenter.default.removeObserver(self)
    }
    var isTapProfileSetting = false
    let btn2 = UIButton(type: .custom)
    let lblBadge = UILabel.init(frame: CGRect.init(x: 10, y: 0, width: 30, height: 20))
    var smsBarButton : UIBarButtonItem!
    
    func configRightBarButton() {
        
//        var profileImage : UIImage!
//        if let user = UserSetting.current.userProfile?.isVip() {
//            if user {
//                profileImage = UIImage(named: "Avatar")!
//            } else {
//                profileImage = UIImage(named: "AvatarNoVip")!
//            }
//        } else {
//            profileImage = UIImage(named: "AvatarNoVip")!
//        }
//        let new = profileImage.resizedImage(Size: CGSize(width: 30, height: 30))
        
        let smsImage  = UIImage(named: "alerts")!
        let newsmsImage = smsImage.resizedImage(Size: CGSize(width: 25, height: 25))
        let btn1 = UIButton(type: .custom)
//        btn1.setImage(new , for: .normal)
//        btn1.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
//        btn1.addTarget(self, action: #selector(didTapProfileButton(sender:)), for: .touchUpInside)
//        let item1 = UIBarButtonItem(customView: btn1)
        let btn2 = UIButton(type: .custom)
        btn2.setImage(newsmsImage, for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        btn2.addTarget(self, action: #selector(didTapSmSButton(sender:)), for: .touchUpInside)
        smsBarButton = UIBarButtonItem(customView: btn2)
        self.navigationItem.setRightBarButtonItems([smsBarButton], animated: true)
    }
//    @objc func didTapProfileButton(sender: AnyObject){
//        if !isTapProfileSetting  {
//            isTapProfileSetting = true
//            let controller =  ProfileMKSettingVC(nibName: "ProfileMKSettingVC", bundle: nil)
//            controller.tapCloruse = { [weak self] in
//                self?.remove(asChildViewController: controller)
//                self?.isTapProfileSetting = false
//            }
//            self.add(viewController: self, asChildViewController: controller, direction: .allowAnimatedContent)
//        }
//    }
    
    @objc func didTapSmSButton(sender: AnyObject){
        
        let vc = NotiListViewController(nibName: "NotiListViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initHeader(text: NSLocalizedString("Overview" , comment: "Overview"), leftButton: false)
        configRightBarButton()
        imgViewMess.addTapGesture {
            let vc = NotiListViewController(nibName: "NotiListViewController", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        viewAlertMessage.layer.cornerRadius = 5
        viewAlertMessage.layer.masksToBounds = true
        setInfoApp()
        unread_total()
    }
    
    @objc func numberDidChange(){
        NotificationCenter.default.removeObserver(self)
        unread_total()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    func unread_total() {
        print("unread_total: start call")
        let currentDate = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let toDate = df.string(from: currentDate)
        let date3Day = NSCalendar.current.date(byAdding: .day, value: -3, to: Date())!
        let fromDate = df.string(from: date3Day)
        print("unread: from: \(String(describing: fromDate)) -- to:\(toDate)")
        NotificationServiceMK.shared.user_notification_unread_total(fromTime: fromDate, toTime: toDate) { (result) in
            print("unread_total: \(result)")
            switch result {
            case .success(let value):
                ConstantMK.parseJson(dict: value, handler: { success, msg, code in
                    if !success {
                        if let mess = value["message"] as? String {
                            if mess == "Invalid access token." {
                                self.presentInvalidAccessToken()
                            }
                        }
                    } else {
                        if let unreadCount  = value["data"] as? Int {
                            AppIconBadge.reset()
                            //                            AppIconBadge.setNumber(unreadCount)
                            if unreadCount  > 99 {
                                self.smsBarButton.setBadge(text: "99+")
                            } else {
                                self.smsBarButton.setBadge(text: unreadCount < 10 ? "0\(unreadCount)" : "\(unreadCount)")
                            }
                            print("unread_total: set layout finish")
                        }else {
                            //                            AppIconBadge.reset()
                            self.smsBarButton.removeBadge()
                        }
                    }
                })
            case .failure(let err):
                HNMessage.showError(message: err?.localizedDescription ?? NSLocalizedString("Failed to Load", comment: "Failed to Load"), to: self.navigationController)
            }
        }
    }
    
    func setInfoApp() {
        if !ConstantMK.isShowUpdate {
            NotificationServiceMK.shared.infoApp(completion: { (result) in
                switch result {
                case .success(let value):
                    ConstantMK.parseJson(dict: value) { success, msg, code in
                        if success{
                            if let data = value["data"] as? JSON {
                                if let infoData = try? JSONSerialization.data(withJSONObject: data, options: []){
                                    do {
                                        let item = try JSONDecoder().decode(UpdateMK.self, from: infoData)
                                        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
                                        if let buildNumber = Int(build) {
                                            
                                            if  item.versionCode ?? 1 > buildNumber{
                                                
                                                let controller =  AlertNotiCustomViewController(nibName: "AlertNotiCustomViewController", bundle: nil)
                                                controller.item = item
                                                self.add(viewController: self, asChildViewController: controller, direction: .allowAnimatedContent)
                                                ConstantMK.isShowUpdate = true
                                            }
                                        }
                                    } catch let err {
                                        print("err get infoApp",err)
                                    }
                                }
                            }
                            
                        }else{
                            self.showErrorResponse(code: code)
                        }
                    }
                case .failure(let err):
                    self.alert(title: "", message: err?.localizedDescription ?? "")
                }
            })
        }
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                NotificationServiceMK.shared.bindPushDevice(device: "ios", registrationId: token, completion: { (result) in
                    print("result",result)
                })
                print("notificationId thanh",token)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !actionCoordinator.isFloatingPanelAdded {
            actionCoordinator.presentDriverList()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        actionCoordinator.updateFloatingPanelLayout()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        touches.forEach { (touch) in
            if touch.view?.isSubviewOfMapView == true {
                actionCoordinator.handleUserTouchInMapView()
                return
            }
        }
    }
    
    func noteNewMessage() {
        navigationItem.rightBarButtonItem?.showBadgeDot(withOffset: CGPoint(x: -40.0, y: 12.0))
    }
    
    func showGoBackButton() {
        navigationItem.leftBarButtonItem = goBackButton
    }
    
    func hideGoBackButton() {
        navigationItem.leftBarButtonItem = nil
    }
    
}

//MARK: - Actions

extension OverviewViewController {
    
    @objc func goBackButtonTapped(_ sender: Any) {
        actionCoordinator.goBack()
    }
    
    @objc func notificationButtonTapped(_ sender: Any) {
        let vc = NotiListViewController(nibName: "NotiListViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: - MKMapViewDelegate

extension OverviewViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        return pinsManager.mapView(mapView, viewFor: annotation)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return overlayManager.mapView(mapView, rendererFor: overlay)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //        actionCoordinator.mapViewDelegate?.mapView?(mapView, didSelect: view)
    }
    
}

extension UIView {
    
    var isSubviewOfMapView: Bool {
        var possibleMapView = superview
        while !(possibleMapView is MKMapView) {
            possibleMapView = possibleMapView?.superview
            
            if possibleMapView == nil {
                break
            }
        }
        
        return (possibleMapView is MKMapView)
    }
    
}

