//
//  AppDelegate.swift
//  Acht
//
//  Created by gliu on 8/23/16.
//  Copyright © 2016 waylens. All rights reserved.
//
import IQKeyboardManagerSwift
import UIKit
import Alamofire
#if useMixpanel
import Mixpanel
#endif
//import HockeySDK
//import CocoaLumberjack
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import WaylensFoundation
import WaylensCameraSDK
import FirebaseCore
import NotificationCenter

#if DEBUG
import FLEX
#endif

protocol StatusAppDelegate : AnyObject {
    func willEnterForeground()
    func didEnterBackground()
    func didBecomeActive()
}

let sharedApplication = UIApplication.shared
let sharedAppDelegate = sharedApplication.delegate as! AppDelegate


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var isActive = false
    var window: UIWindow?
    var firstLaunch: FirstLaunch!
    var orientationLock = UIInterfaceOrientationMask.all
    weak var delegate : StatusAppDelegate?
    
#if !FLEET
    private var _guideHelper: GuideHelper?
    var guideHelper: GuideHelper {
        set {
            _guideHelper = newValue
        }
        get {
            if _guideHelper == nil {
                _guideHelper = GuideHelper()
            }
            return _guideHelper!
        }
    }
#endif
    
    
    private lazy var ssidHelper: IOS13SSIDHelper = IOS13SSIDHelper()
    private var currentCameraObservation: NSKeyValueObservation?
    
//    @available(iOS 14.0, *)
    private lazy var localNetworkPermission: LocalNetworkPermission = LocalNetworkPermission { [weak self] (granted) in
        if !granted {
            self?.window?.rootViewController?.topMostViewController.alertLocalNetworkPermissionMessage()
        }
    }
    
    func setRootVC(vc : UIViewController) {
        window = ThemedWindow(lightTheme: LightTheme(), darkTheme: LightTheme())
        window?.frame = UIScreen.main.bounds
        
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    
    
    func setupRootViewController() {
//       let vc = GetLogViewController(nibName: "GetLogViewController", bundle: nil)
//        vc.camera =  UnifiedCameraManager.shared.local
//        self.setRootVC(vc: vc)
      //  rootConfigCamera()
//
       //let vc = MyFleetDependencyContainer().makeMyFleetViewController().embedInNavigationController()
        
//        let vc =  AssetManageViewController()
//        let nav = UINavigationController(rootViewController: vc)
//        self.setRootVC(vc: nav)
        
//
        
        
        let vc = LoginMKViewController(nibName: "LoginMKViewController", bundle: nil)

        let nav = UINavigationController(rootViewController: vc)
        self.setRootVC(vc: nav)
//
//      
//
//        let vc =   DeviceViewController()
//        let nav = UINavigationController(rootViewController: vc)
//        self.setRootVC(vc: nav)
//        let vc = PlacesController()
//        self.setRootVC(vc: vc)
        
        
//
//        window = ThemedWindow(lightTheme: LightTheme(), darkTheme: DarkTheme())
//        window?.frame = UIScreen.main.bounds
//        window?.rootViewController = AppViewControllerManager.createRootViewController()
//        window?.makeKeyAndVisible()

    }
    
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        ConstantMK.isShowUpdate = false
        setupLogger()
        return true
    }
    
    func rootTabBarController() {
      
        let vc = AppViewControllerManager.createTabBarController()
       
        self.setRootVC(vc: vc)
    }
    
    
    let configPushMK = ConfigPush()
    
  


   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     
     //   registerNotification()
        configPushMK.delegate = self
    
        configPushMK.jpushInit(launchOptions ?? [:])
       
        FirebaseApp.configure()
        ConstantMK.initConfig()
       // FirebaseApp.setAnalyticsCollectionEnabled(true)
        IQKeyboardManager.shared.enable = true
        DataRequest.addAcceptableImageContentTypes(["image/jpg"])
        HNMessage.loadStyle()
        //setupCrashReporter()
        setupMixpanel()
        MSAppCenter.start(AppConfig.AccessKeys.appCenterSecret, withServices:[
            MSAnalytics.self,
            MSCrashes.self
        ])
        
        MixpanelHelper.track(event: "Run")
        
        isActive = false
        
        if UserSetting.shared.isLoggedIn, let userId = AccountControlManager.shared.keyChainMgr.userID {
            UserSetting.current = UserSetting(userId)
            
#if useMixpanel
            Mixpanel.mainInstance().identify(distinctId: userId)
            Mixpanel.mainInstance().people.set(properties: ["email": AccountControlManager.shared.keyChainMgr.email ?? ""])
#else
            var prop = Dictionary<String, Any>()
            prop["UserID"] = userId
            prop["email"] = AccountControlManager.shared.keyChainMgr.email ?? ""
            MixpanelHelper.track(event: "Login", properties: prop)
#endif
            
            AccountControlManager.shared.fetchUserProfile()
        } else {
            MixpanelHelper.track(event: "Not logged in")
        }
        
#if FLEET
        WaylensCameraSDKConfig.current.target = .toB
#else
        WaylensCameraSDKConfig.current.target = .toC
#endif
        
        WLBonjourCameraListManager.shared.add(delegate: self)
        
        if #available(iOS 14.0, *) {
            localNetworkPermission.check()
        }
        
#if !FLEET
        WLFirmwareUpgradeManager.shared().server = UserSetting.shared.server.rawValue
      
#endif
        
        subcribeCurrentCamera()
        UnifiedCameraManager.shared.updateRemote()
        
        setupRootViewController()
        
      //  RemoteNotificationController.shared.registerForRemoteNotifications()
        
        checkUpdate()
        subcribeNotifications()
        setupDDAutoTrackerManager()
        
        firstLaunch = FirstLaunch(userDefaults: .standard, key: "com.waylens.Acht.FirstLaunch.WasLaunchedBefore")
        
    
        
        if #available(iOS 13.0, *) {
            ssidHelper.requestPermissionIfNeeded()
        }
        
        print("UserSetting.shared.server.rawValue",UserSetting.shared.server.rawValue)
        return true
    }
    
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        Log.info("application will resign active")
        WLBonjourCameraListManager.shared.deactivate()
        isActive = false
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Log.info("application did enter background")
        delegate?.didEnterBackground()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        Log.info("application will enter foreground")
        delegate?.willEnterForeground()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Log.info("application did become active")
        isActive = true
        WLBonjourCameraListManager.shared.activate()
//
        let camerasToCheck = WLBonjourCameraListManager.shared.cameraList
        checkIfHasConnectedUnsupportedCamera(camerasToCheck)
        delegate?.didBecomeActive()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        Log.info("application will terminate")
        if !UserSetting.shared.isMoc{
            AccountControlManager.shared.keyChainMgr.onLogOut()
        }
        
        ConstantMK.deinitConfig()
        ConstantMK.isShowUpdate = false
        NotificationCenter.default.removeObserver(self, name: Notification.Name.Remote.settingsUpdateTimeOut, object: nil)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        print("application(_ app: UIApplication,open url: URL")
        if (url.scheme == "horn.way.lens") {
            //            let params = url.relativeString.substring(from: (url.scheme! + "://").endIndex)
            //            if !params.contains("/") {
            //                return true
            //            }
            let vc = self.window?.rootViewController?.navigationController?.topViewController
            if let vc = vc, vc is AlertListViewController {
                let alertvc = AlertListViewController.createViewController()
                vc.navigationController?.pushViewController(alertvc, animated: true)
            } else {
                if let vc = self.window?.rootViewController {
                    let alertvc = AlertListViewController.createViewController()
                    vc.present(alertvc, animated: true, completion: nil)
                }
            }
            //            if (vc!.isKind(of: UINavigationController.classForCoder())) {
            //                let type = params.substring(to: (params.range(of: "/")?.lowerBound)!)
            //                let id = params.substring(from: (type + "/").endIndex)
            //                switch type {
            //                case "v":
            //                    return true
            //                default:
            //                    break
            //                }
            //            }
            return true
        }
        return false
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        Log.warn("applicationDidReceiveMemoryWarning")
    }
}

private extension AppDelegate {
    
    func checkUpdate() {
        //        #if !APPSTORE
        //        if Environment.current.shouldCheckUpdate {
        //            FIRUpdate.checkUpdate(appId: Constants.AccessKeys.firAppID, token: Constants.AccessKeys.firToken)
        //        }
        //        #endif
        
     
        
        
        
        
        
    }
    
    
    
    func rootHNCameraSettingViewController() {
        
        let vc = HNCameraSettingViewController.createViewController()
        vc.camera =  UnifiedCameraManager.shared.local
     
        self.setRootVC(vc: vc)
    }
   
    
    

    
    
    func rootConfigCamera() {
      
        let vc = ConfigCameraMKViewController(nibName: "ConfigCameraMKViewController", bundle: nil)
        self.setRootVC(vc: vc)
    }
    
    func setupMixpanel() {
#if useMixpanel
        if (Environment.current == .appStore) ||
            (Environment.current == .testFlight) {
            Mixpanel.initialize(token: Constants.AccessKeys.mixpanelTokenForAppStore)
        } else {
            Mixpanel.initialize(token: Constants.AccessKeys.mixpanelToken)
        }
#endif
    }
    
    func setupLogger() {
#if DEBUG
        Log.setupForDebug()
#else
        Log.setup()
#endif
        //        guard let fileLogger = DDFileLogger() else { return }
        //        fileLogger.rollingFrequency = 3600 * 24 * 7
        //        fileLogger.logFileManager.maximumNumberOfLogFiles = 2;
        //        DDLog.add(fileLogger, with: .verbose)
    }
    
    func setupDDAutoTrackerManager() {
        DDAutoTrackerManager.sharedInstance()?.isDebug = true
        if let trackEventsUrl = Bundle.main.url(forResource: "Events", withExtension: "plist"), let array = NSArray(contentsOf: trackEventsUrl) as? [Any] {
            DDAutoTrackerManager.sharedInstance()?.configArray = array
        }
        DDAutoTrackerManager.sharedInstance()?.startWithCompletionBlock(success: { (dict) in
            guard let dict = dict else { return }
            let event = dict[DDAutoTrackerEventIDKey] as? String
            let info = dict[DDAutoTrackerInfoKey] as? [String: Any]
            if let prop = info, prop.count > 0 {
                Log.debug("DDTracker: \(event ?? ""), info: \(prop)")
            } else {
                Log.debug("DDTracker: \(event ?? "")")
            }
            
            if let name = dict[DDAutoTrackerNameKey] as? String {
                MixpanelHelper.track(event: name, properties: info)
            } else {
                var newevent = event
                if event?.hasPrefix("Acht.") ?? false {
                    newevent = String(event!.suffix(event!.count - 5))
                }
                if event?.hasPrefix("Fleet.") ?? false  {
                    newevent = String(event!.suffix(event!.count - 6))
                }
                switch newevent {
                    // ignore some frequent events
                case "UITabBar/@_sendAction:withEvent": break
                case "HNHomeViewController/@viewDidAppear": break
                case "TabBarController/@viewDidAppear": break
                case "UIInputWindowController/@viewDidAppear": break
                case "UIAlertController/@viewDidAppear": break
                case "UITabBar/@_buttonDown:": break
                case "TabBarController/@_tabBarItemClicked:": break
                case "UITabBar/@_sendAction:withEvent:": break
                case "UITabBar/@_buttonUp:": break
                case "_UINavigationBarContentView/@__backButtonAction:": break
                case "PlayerPanel/@viewDidAppear": break
                case "HNCameraDetailViewController/@viewDidAppear": break
                case "CameraTimelineVerticalViewController/@viewDidAppear": break
                default:
                    MixpanelHelper.track(event: newevent, properties: info)
                    break
                }
            }
            
        }, debug: { (_) in
        })
    }
    
    func subcribeCurrentCamera() {
        currentCameraObservation = UnifiedCameraManager.shared.observe(\.current, options: [.old, .new]) { [weak self] (cameraManager, change) in
            if let newValue = change.newValue, let newCamera = newValue {
                self?.tryRemindUpdateFirmware(of: newCamera)
            }
        }
    }
    
    func tryRemindUpdateFirmware(of camera: UnifiedCamera) {
#if !FLEET
        if  let model = camera.model,
            let firmware = camera.firmware,
            let name = camera.name,
            WLFirmwareUpgradeManager.shared().firmwareInfo(forModel: model)?.needUpgrade(firmware) ?? false {
            if let recent = UserSetting.shared.recentFirmwareUpdateRemindDate, -recent.timeIntervalSinceNow < 7 * 24 * 3600 {
                return
            }
            
            let alert = UIAlertController(
                title: NSLocalizedString("Firmware update", comment: "Firmware update"),
                message: String(format: NSLocalizedString("Firmware update available for %@", comment: "Firmware update available for %@"), name),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("Update", comment: "Update"), style: .default, handler: { (_) in
                let vc = HNCSFirmwareViewController.createViewController()
                vc.camera = camera
                
                if #available(iOS 13.0, *) {
                    vc.modalPresentationStyle = .fullScreen
                }
                
                AppViewControllerManager.topViewController?.present(vc, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
            
            AppViewControllerManager.topViewController?.present(alert, animated: true, completion: nil)
            
            UserSetting.shared.recentFirmwareUpdateRemindDate = Date()
        }
#endif
    }
    
    // MARK: Notifications
    
    func subcribeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onSettingsUpdateTimeOut(sender:)), name: Notification.Name.Remote.settingsUpdateTimeOut, object: nil)
    }
    
    @objc func onSettingsUpdateTimeOut(sender: Notification) {
        guard let vc = AppViewControllerManager.topViewController, let sn = sender.object as? String else { return }
        if let cvc = vc as? CameraRelated, sn == cvc.camera?.sn {
            HNMessage.showWhisper(type: .error, message: NSLocalizedString("Failed to apply camera settings.", comment: "Failed to apply camera settings."))
        } else if let camera = UnifiedCameraManager.shared.cameraForSN(sn)?.name {
            HNMessage.showError(message: String(format: NSLocalizedString("Failed to apply camera settings to %@", comment: "Failed to apply camera settings to %@"), camera))
        }
    }
    
}

extension AppDelegate: UnsupportedCameraMonitor, WLBonjourCameraListManagerDelegate {
    
    var unsupportedCameraPrompter: UnsupportedCameraPrompter? {
        return window?.rootViewController
    }
    
    func bonjourCameraListManager(_ bonjourCameraListManager: WLBonjourCameraListManager, didUpdateCameraList cameraList: [WLCameraDevice]) {
        checkIfHasConnectedUnsupportedCamera(cameraList)
    }
    
    func bonjourCameraListManager(_ bonjourCameraListManager: WLBonjourCameraListManager, didDisconnectCamera camera: WLCameraDevice) {
        
    }
    
}

#if DEBUG

extension ThemedWindow {
    
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        
        if case UIEvent.EventSubtype.motionShake = motion {
            FLEXManager.shared.showExplorer()
        }
    }
    
}

#endif

extension NSURLRequest {
    func allowsAnyHTTPSCertificateForHost(_ host : String) -> Bool {
        return true;
    }
}



extension AppDelegate : ConfigPushMKDelegate {
//    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification!) {
//
//    }


    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
      
     //   scheduleDemoLocalNotification()
         let userInfo = notification.request.content.userInfo;
        print("userInfo",userInfo)
//
//        JPUSHService.handleRemoteNotification(userInfo)
//    
//        JPush.shared().willPresent(notification)
        //completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert)
        //pushNotifyFinish()
    }


    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        print("jpushNotificationCenter 2 ")
       let userInfo = response.notification.request.content.userInfo;
        if let id = userInfo["notificationId"] as? String {
            
            
            
            print("Id Notification",id)
            
            NotificationServiceMK.shared.user_notification_info(notificationId: id, completion: {
                (result) in
                    switch result {
                    case .success(let value):
               
                        ConstantMK.parseJson(dict: value, handler: { success, msg in
                            if success{
                                if let datas = value["data"] as? JSON {

                                    print("infoData Notification",datas)
                                    
                                    
                                        if let infoData = try? JSONSerialization.data(withJSONObject: datas, options: []){
                                            do {

                                                let item = try JSONDecoder().decode(NotiItem.self, from: infoData)
                                                
                                                AppViewControllerManager.showNotiDetaiViewController(item: item)
                             
                                            } catch let err {
                                                print("err get noti ",err)
                                            }
                                        }

                                }
                            }
                        })
                    case .failure(let err):
                        print("err get noti \(err?.msg ?? "")")
                    }
            })
        }
        print("userInfo2",userInfo)
        
    }

    func jpushNotificationAuthorization(_ status: JPAuthorizationStatus, withInfo info: [AnyHashable : Any]!) {
        print("jpushNotificationCenter 3 ")
        JPush.shared().alertNotificationAuthorization(status)
    }


}


extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      //  RemoteNotificationController.shared.sendPushNotificationDetails(using: deviceToken)
        JPUSHService.registerDeviceToken(deviceToken)
        JPush.shared().deviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("didReceiveRemoteNotification \(userInfo)")
        RemoteNotificationController.shared.handleNotificationDictionary(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("didReceiveRemoteNotification 2 \(userInfo)")
//        completionHandler(.noData)
      RemoteNotificationController.shared.handleNotificationDictionary(userInfo)
        JPUSHService.handleRemoteNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
}
