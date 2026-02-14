//
//  WaylensClientConstants.swift
//  Acht
//
//  Created by gliu on 8/25/16.
//  Copyright © 2016 waylens. All rights reserved.
//

import Foundation
import UIKit

enum EndPoint {
    case signup
    case login
    case logout
    case requestPasswordReset
    case resetPassword
    case resendVerification
    case changePassword
    case profile
    case avatar
    case devices
    case device(String)
    case bindDevice
    case deviceName(String)
    case controlDevice(String)
    case uploadDevice(String)
    case reportDeviceIccid(String)
    case live(String)
    case heartBeat(String)
    case liveHighlight(String)
    case liveStatus(String)
    case signal4g(String)
    case liveBitRate(String)
    case events
    case alerts
    case event(Int64)
    case readEvent(Int64)
    case readAllEvents
    case clips
    case clipsStats
    case clip(Int64)
    case report
    case address
    case subscription(String)
    case cameraNotificationSettings(String)
    case refreshPushNotificationToken
    case forumLogin
    case notifications
    case markAllNotificationsRead
    case markNotificationRead(Int64)
    case deviceAudioBroadcast(deviceID: String)
    case configCamera(sn : String)

    var url: String {
        switch self {
        case .signup:
            return "/api/v1.0/users/signup"
        case .login:
            return "/api/v1.0/users/signin"
        case .logout:
            return "/api/v1.0/users/signout"
        case .requestPasswordReset:
            return "/api/v1.0/users/send_passwordreset_email"
        case .resetPassword:
            return "/api/v1.0/users/reset_password"
        case .resendVerification:
            return "/api/v1.0/users/resend_verify_email"
        case .changePassword:
            return "/api/v2.0/users/me/change_password"
        case .profile:
            return "/api/v1.0/users/me/profile"
        case .avatar:
            return "/api/v2.0/users/me/avatar_upload_address"
        case .devices:
            return "/api/v1.0/devices"
        case .device(let deviceID):
            return "/api/v1.0/devices/\(deviceID)"
        case .bindDevice:
            return "/api/v1.0/devices/bind"
        case .deviceName(let deviceID):
            return "/api/v1.0/devices/\(deviceID)/name"
        case .controlDevice(let deviceID):
            return "/api/v1.0/devices/\(deviceID)/control"
        case .uploadDevice(let deviceID):
            return "/api/v1.0/devices/\(deviceID)/report"
        case .reportDeviceIccid(let deviceID):
            return "/api/v1.0/devices/\(deviceID)/report_iccid"
        case .live(let deviceID):
            return "/api/v1.0/devices/\(deviceID)/streaming"
        case .heartBeat(let deviceID):
            return "/api/v2.0/devices/\(deviceID)/streaming/heartbeat"
        case .liveHighlight(let deviceID):
            return "/api/v2.0/devices/\(deviceID)/streaming/highlight"
        case .liveStatus(let deviceID):
            return "/api/v1.0/devices/\(deviceID)/streaming/status"
        case .signal4g(let deviceID):
            return "/api/v1.0/devices/\(deviceID)/streaming/4gsignal"
        case .liveBitRate(let deviceID):
            return "/api/v1.0/devices/\(deviceID)/streaming/bps"
        case .events:
            return "/api/v1.0/events"
        case .alerts:
            return "/api/v1.0/events/alerts"
        case .event(let eventID):
            return "/api/v1.0/events/\(eventID)"
        case .readEvent(let eventID):
            return "/api/v1.0/events/\(eventID)/mark_read"
        case .readAllEvents:
            return "/api/v1.0/events/mark_all_read"
        case .clips:
            return "/api/v1.0/clips"
        case .clipsStats:
            return "/api/v1.0/clips/number"
        case .clip(let clipID):
            return "/api/v1.0/clips/\(clipID)"
        case .report:
            return "/api/v2.0/reports"
        case .address:
            return "/api/v1.0/address"
        case .subscription(let deviceID):
            return "/api/v1.0/devices/\(deviceID)/current_subscription"
        case .cameraNotificationSettings(let deviceID):
            return "/api/v1.0/devices/\(deviceID)/notifications"
        case .refreshPushNotificationToken:
            return "/api/v1.0/users/me/device_token"
        case .forumLogin:
            return "/api/v1.0/users/me/forum_url"
        case .notifications:
            return "/api/v1.0/notifications"
        case .markAllNotificationsRead:
            return "/api/v1.0/notifications/mark_all_read"
        case .markNotificationRead(let notificationID):
            return "/api/v1.0/notifications/\(notificationID)/mark_read"
        case .deviceAudioBroadcast(let deviceID): // action: start or stop
            return "/api/v1.0/devices/\(deviceID)/audio"
        case .configCamera(let sn):
            return "/api/v1/fleet/devices/\(sn)/add_camera_configure"
        }
    }

    var shouldLogResponse: Bool {
        switch self {
        case .login,
             .resetPassword,
             .signup:
            return false
        default:
            return true
        }
    }

}

enum HNLiveStatus: String {
    case waking = "waitForAwake"
    case inited = "waitForPublish"
    case streaming = "live"
    case failed = "failToStreaming"
    case waitForStop = "waitForStop"
    case stopped = "stopped"
    case offline = "offline"
    case timeout
    
    var displayName: String {
        switch self {
        case .waking:
            return NSLocalizedString("waking up", comment: "waking up")
        case .inited:
            return NSLocalizedString("connecting", comment: "connecting")
        case .streaming:
            return NSLocalizedString("streaming", comment: "streaming")
        case .failed:
            return NSLocalizedString("failed", comment: "failed")
        case .waitForStop:
            return NSLocalizedString("stopping", comment: "stopping")
        case .stopped:
            return NSLocalizedString("stopped", comment: "stopped")
        case .offline:
            return NSLocalizedString("offline", comment: "offline")
        case .timeout:
            return NSLocalizedString("time out", comment: "time out")
        }
    }
    
    var message: String {
        switch self {
        case .waking:
            return NSLocalizedString("Waking up", comment: "Waking up")
        case .inited:
            return NSLocalizedString("Connecting", comment: "Connecting")
        case .streaming:
            return NSLocalizedString("Streaming", comment: "Streaming")
        case .failed:
            return NSLocalizedString("Live stream failed", comment: "Live stream failed")
        case .waitForStop:
            return "Stop"
        case .stopped:
            return NSLocalizedString("Live stream stopped", comment: "Live stream stopped")
        case .offline:
            return NSLocalizedString("Camera offline", comment: "Camera offline")
        case .timeout:
            return NSLocalizedString("Live stream timed out", comment: "Live stream timed out")
        }
    }
    
    var shouldStop: Bool {
        switch self {
        case .failed, .waitForStop, .stopped, .offline, .timeout:
            return true
        default:
            return false
        }
    }
}

#if FLEET

extension AppConfig.CameraServer {

    var displayName: String {
        switch self {
        case .dev:
            return "Dev"
        case .production:
            return "Production"
        case .api:
            return "API"
        }
    }

    var id: Int {
        switch self {
        case .production:
            return 0
        case .dev:
            return 1
        case .api:
            return 2
        }
    }

    func isPaired(with server: AppConfig.Server) -> Bool {
        switch (self, server) {
        case (.production, .production):
            return true
        case (.dev, .dev):
            return true
        case (.api, .production):
            return true
        default:
            return false
        }
    }

}

extension AppConfig.Server {

    var displayName: String {
        switch self {
        case .production:
            return "Production"
        case .dev:
            return "Dev"
        }
    }

    var id: Int {
        switch self {
        case .production:
            return 0
        case .dev:
            return 1
        }
    }

    var pairedCameraServer: AppConfig.CameraServer {
        switch self {
        case .production:
            return AppConfig.CameraServer.production
        case .dev:
            return AppConfig.CameraServer.dev
        }
    }

    static func from(id: Int) -> AppConfig.Server? {
        switch id {
        case 0:
            return .production
        case 1:
            return .dev
        default:
            return .production
        }
    }

}

#else

extension AppConfig.CameraServer {

    var displayName: String {
        switch self {
        case .china:
            return "China(Aliyun)"
        case .shanghai:
            return "Shanghai(97)"
        case .us_public:
            return "US Public"
        case .us_test:
            return "US Test"
        }
    }

    var id: Int {
        switch self {
        case .us_public:
            return 0
        case .china:
            return 1
        case .shanghai:
            return 2
        case .us_test:
            return 3
        }
    }

    func isPaired(with server: AppConfig.Server) -> Bool {
        switch (self, server) {
        case (.us_public, .us_public):
            return true
        case (.shanghai, .shanghai):
            return true
        case (.us_public, .us_public):
            return true
        case (.us_test, .us_test):
            return true
        default:
            return false
        }
    }

    static func from(id: Int) -> AppConfig.CameraServer? {
        switch id {
        case 0:
            return .us_public
        case 1:
            return .china
        case 2:
            return .shanghai
        case 3:
            return .us_test
        default:
            return nil
        }
    }

}

extension AppConfig.Server {

    var displayName: String {
        switch self {
        case .us_public:
            return "US Public"
        case .china:
            return "China(Aliyun)"
        case .shanghai:
            return "Shanghai(97)"
        case .us_test:
            return "US Test(AWS)"
        }
    }

    var id: Int {
        switch self {
        case .us_public:
            return 0
        case .china:
            return 1
        case .shanghai:
            return 2
        case .us_test:
            return 3
        }
    }

    var pairedCameraServer: AppConfig.CameraServer {
        switch self {
        case .us_public:
            return AppConfig.CameraServer.us_public
        case .china:
            return AppConfig.CameraServer.china
        case .shanghai:
            return AppConfig.CameraServer.shanghai
        case .us_test:
            return AppConfig.CameraServer.us_test
        }
    }

    static func from(id: Int) -> AppConfig.Server? {
        switch id {
        case 0:
            return .us_public
        case 1:
            return .china
        case 2:
            return .shanghai
        case 3:
            return .us_test
        default:
            return nil
        }
    }

}

#endif

enum WebServer: String {
    case us_public = "https://www.waylens.com"
    case cn_public = "http://www.waylens.cn"
    case sgp_beta = "http://beta.waylens.com"
    case cn_beta = "http://beta.waylens.cn"
    case local = "http://192.168.222.153:8083"
    var displayName: String {
        switch self {
        case .us_public:
            return "US Public (www.waylens.com)"
        case .cn_public:
            return "CN Public (www.waylens.cn)"
        case .sgp_beta:
            return "SGP Beta (beta.waylens.com)"
        case .cn_beta:
            return "CN Beta (beta.waylens.cn)"
        case .local:
            return "Local 192.168.222.153:8083"
        }
    }
    static var all = [WebServer.us_public, WebServer.cn_public, WebServer.sgp_beta, WebServer.cn_beta, WebServer.local]
    
    var shopUrl: String {
        return "\(rawValue)/shop/360?from=ios"
    }
    
}

extension Notification.Name {
    public struct Local {
        static let liveMark = Notification.Name(rawValue: "waylens.acht.notification.name.local.livemark")
        static let recordState = Notification.Name(rawValue: "CMD_Cam_get_State_result")
    }
    
    public struct Remote {
        static let stateChanged = Notification.Name(rawValue: "waylens.acht.notification.name.remote.statechanged")
        static let settingsUpdated = Notification.Name(rawValue: "waylens.acht.notification.name.remote.settingsUpdated")
        static let settingsUpdateTimeOut = Notification.Name(rawValue: "waylens.acht.notification.name.remote.settingsUpdateTimeOut")
        static let alert = Notification.Name(rawValue: "waylens.acht.notification.name.remote.alert")
    }
    
    public struct App {
        static let loggedIn = Notification.Name(rawValue: "waylens.acht.notification.name.app.loggedin")
        static let powerTestDone = Notification.Name(rawValue: "waylens.acht.notification.name.app.powertestdone")
    }
}

let enablePRDebugKey = "enablePRDebug"
let savedOpticalCenterKey = "savedOpticalCenter"
let lastCarLocationKey = "lastCarLocation"

enum UserSettingKey: String {
    case server = "horn.settings.debug.server"
    case webServer = "horn.settings.debug.webserver"
    case loggedIn = "horn.settings.login"
    case moc = "horn.settings.moc"
    case cachedCameras = "horn.settings.cachedcameras"
    case advancedSettings = "horn.settings.camera.advanced"
    case verified = "horn.settings.verified"
    case lastEmail = "horn.settings.lastemail"
    case isChecked = "horn.setting.isCheckedLogin"
    case lastPwd = "horn.settings.lastpassword"
    case debugEnabled = "horn.settings.debug.enabled"
    case recentFirmwareUpdateRemindDate = "horn.settings.firmwareupdate.recentdate"
    case lastRequestLocationPermissionDate = "horn.settings.lastRequestLocationPermissionDate"
    case guided = "horn.settings.guided"
    case notificationSettings = "horn.settings.notificationSettings"
    case betaFirmwareTester = "com.hachi.firmware.betaTester"
    case shouldRunUIGuide = "horn.settings.guide.ui.shouldrun"
    case showCameraDebugSettings = "showVideoQualitySettings.debugoption.acht" // not only video quality options, also other camera debug settings
    #if FLEET
    case access2CCamera =  "access2CCamera.debugoption.acht"
    case hasSkippedLogin = "horn.settings.hasSkippedLogin"
    case fleetTimeZone = "horn.settings.fleetTimeZone"
    case userProfile = "horn.settings.userProfile"
    case userMK = "horn.settings.userMK"
    
    #else
    case access2BCamera =  "access2BCamera.debugoption.acht"
    #endif
}

enum Tip: String {
    case preview
    
    private static let prefix = "horn.tips."
    
    private var key: String {
        return Tip.prefix + self.rawValue
    }
    var isShown: Bool {
        get {
            return UserDefaults.standard.bool(forKey: self.key)
        }
    }
    
    func didShow() {
        UserDefaults.standard.set(true, forKey: self.key)
        UserDefaults.standard.synchronize()
    }
}

extension Notification.Name {

    public struct UserSetting {
        static let debugEnabledChange = Notification.Name(rawValue: "waylens.acht.notification.name.UserSetting.debugEnabledChange")
        static let userProfileChange = Notification.Name(rawValue: "waylens.acht.notification.name.UserSetting.userProfileChange")
    }

}

struct UserSetting {
    var suffix: String // user id as suffix, allowed to manage user-specific properties
    
    init(_ suffix: String? = nil) {
        self.suffix = suffix == nil ? "" : "." + suffix!
    }
    
    func object(key: UserSettingKey) -> Any? {
        let trueKey = key.rawValue + suffix
        return UserDefaults.standard.object(forKey: trueKey)
    }
    
    func set(_ value: Any?, forKey key: UserSettingKey) {
        let trueKey = key.rawValue + suffix
        UserDefaults.standard.set(value, forKey: trueKey)
        UserDefaults.standard.synchronize()
    }
    
    static var shared = UserSetting() // shared settings for all users on the device
    internal static var _guest = UserSetting("guest")
    internal static var _current: UserSetting?  // user-specific settings
    static var current: UserSetting {
        get {
            if shared.isLoggedIn && _current != nil {
                return _current!
            } else {
                return _guest
            }
        }
        
        set {
            _current = newValue
        }
    }
    
    var isLoggedIn: Bool {
        get {
            return object(key: .loggedIn) as? Bool ?? false
        }
        set {
            set(newValue, forKey: .loggedIn)
        }
    }
    
    var isMoc: Bool{
        get {
            return object(key: .moc) as? Bool ?? false
        }
        set {
            set(newValue, forKey: .moc)
        }
    }
    
    var isVerified: Bool {
        get {
            return object(key: .verified) as? Bool ?? false
        }
        set {
            set(newValue, forKey: .verified)
        }
    }
    
#if FLEET
    
    //    var hasSkippedLogin: Bool {
    //        get {
    //            return object(key: .hasSkippedLogin) as? Bool ?? false
    //        }
    //        set {
    //            set(newValue, forKey: .hasSkippedLogin)
    //        }
    //    }
    
    var fleetTimeZone: TimeZone {
        get {
            //            if let timeZoneIdentifier = object(key: .fleetTimeZone) as? String, let timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") {
            //                return timeZone
            //            }
            let timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh")!
            return timeZone
            
        }
        set {
            set(newValue.identifier, forKey: .fleetTimeZone)
        }
    }
    
    var userMK : UserMK? {
        get {
            if let userProfileJsonData = object(key: .userMK) as? Data {
                let userProfile = try? JSONDecoder().decode(UserMK.self, from: userProfileJsonData)
                return userProfile
            }
            
            return nil
        }
        set {
            set(try? JSONEncoder().encode(newValue), forKey: .userMK)
            
            NotificationCenter.default.post(name: Notification.Name.UserSetting.userProfileChange, object: nil)
        }
    }
    
    
    var userProfile: UserProfile? {
        get {
            if let userProfileJsonData = object(key: .userProfile) as? Data {
                let userProfile = try? JSONDecoder().decode(UserProfile.self, from: userProfileJsonData)
                return userProfile
            }
            
            return nil
        }
        set {
            set(try? JSONEncoder().encode(newValue), forKey: .userProfile)
            NotificationCenter.default.post(name: Notification.Name.UserSetting.userProfileChange, object: nil)
        }
    }
    
    var access2CCamera: Bool {
        get {
            return object(key: .access2CCamera) as? Bool ?? false
        }
        set {
            set(newValue, forKey: .access2CCamera)
        }
    }
    
#else
    
    var access2BCamera: Bool {
        get {
            return object(key: .access2BCamera) as? Bool ?? false
        }
        set {
            set(newValue, forKey: .access2BCamera)
        }
    }
    
#endif
    
    var server: AppConfig.Server {
        get {
            if let result = object(key: .server) as? String, let stype = AppConfig.Server(rawValue: result) {
                return stype
            } else { // default server
#if FLEET
                return .production
#else
                return .us_public
#endif
            }
        }
        set {
            set(newValue.rawValue, forKey: .server)
        }
    }
    
    var webServer: WebServer {
        get {
            if let result = object(key: .webServer) as? String, let stype = WebServer(rawValue: result) {
                return stype
            } else { // default web server
                return .us_public
            }
        }
        set {
            set(newValue.rawValue, forKey: .webServer)
        }
    }
    
    var advancedSettings: Bool {
        get {
            return object(key: .advancedSettings) as? Bool ?? false
        }
        set {
            set(newValue, forKey: .advancedSettings)
        }
    }
    
    var lastEmail: String? {
        get {
            return object(key: .lastEmail) as? String
        }
        set {
            if let value = newValue {
                set(value, forKey: .lastEmail)
            }
        }
    }
    
    var isChecked: Bool? {
        get{
            return object(key: .isChecked) as? Bool
        }
        set{
            if let value = newValue{
                set(value, forKey: .isChecked)
            }
        }
    }
    
    var savePwd: String?{
        get{
            return object(key: .lastPwd) as? String
        }
        set{
            if let value = newValue{
                set(value, forKey: .lastPwd)
            }
        }
    }
    
    var debugEnabled: Bool {
        get {
            return object(key: .debugEnabled) as? Bool ?? false
        }
        set {
            set(newValue, forKey: .debugEnabled)
            NotificationCenter.default.post(name: Notification.Name.UserSetting.debugEnabledChange, object: nil)
        }
    }
    
    var showCameraDebugSettings: Bool {
        get {
            return object(key: .showCameraDebugSettings) as? Bool ?? false
        }
        set {
            set(newValue, forKey: .showCameraDebugSettings)
        }
    }

    var beBetaFrimwareTester : Bool {
        get {
            return object(key: .betaFirmwareTester) as? Bool ?? false
        }
        set {
            set(newValue, forKey: .betaFirmwareTester)
        }
    }
    
    var recentFirmwareUpdateRemindDate: Date? {
        get {
            return object(key: .recentFirmwareUpdateRemindDate) as? Date
        }
        set {
            set(newValue, forKey: .recentFirmwareUpdateRemindDate)
        }
    }

    var lastRequestLocationPermissionDate: Date? {
        get {
            return object(key: .lastRequestLocationPermissionDate) as? Date
        }
        set {
            set(newValue, forKey: .lastRequestLocationPermissionDate)
        }
    }
    
    enum GuideSwitch {
        case idle
        case ongoing
        case skipped
    }
    var guideSwitch: GuideSwitch = .idle
    var shouldRunUIGuide: Bool {
        get {
            return object(key: .shouldRunUIGuide) as? Bool ?? true
        }
        set {
            set(newValue, forKey: .shouldRunUIGuide)
        }
    }
    var guideState: GuideState {
        get {
            if let result = object(key: .guided) as? Int {
                return GuideState(rawValue: result) ?? .start
            } else {
                return .start
            }
        }
        set {
            set(newValue.rawValue, forKey: .guided)
            if newValue == .start {
                guideSwitch = .idle
                shouldRunUIGuide = true
            } else if newValue == .end {
                guideSwitch = .idle
                shouldRunUIGuide = false
            }
        }
    }
    
    var notificationSettings: HNCSNotificationSettings {
        get {
            if let settings = object(key: .notificationSettings) as? [String : Any] {
                return HNCSNotificationSettings(dictionary: settings)
            } else {
                let newSettings = HNCSNotificationSettings()
                set(newSettings.dictionaryValue(), forKey: .notificationSettings)
                return newSettings
            }
        }
        set {
            set(newValue.dictionaryValue(), forKey: .notificationSettings)
        }
    }
}

var enablePRDebug : Bool {
    get {
        if (UserDefaults.standard.object(forKey: enablePRDebugKey) == nil) {
            return true
        }
        let debug : Bool? = UserDefaults.standard.bool(forKey : enablePRDebugKey)
        return (debug == true)
    }
    set {
        UserDefaults.standard.set(newValue, forKey: enablePRDebugKey)
        UserDefaults.standard.synchronize()
    }
}

var savedOpticalCenter : CGPoint {
    get {
        if (UserDefaults.standard.object(forKey: savedOpticalCenterKey) == nil) {
            return CGPoint.init(x: 0, y: 0)
        }
        let dict = UserDefaults.standard.dictionary(forKey: savedOpticalCenterKey)
        let x = dict!["x"] as! NSNumber
        let y = dict!["y"] as! NSNumber
        return CGPoint.init(x: CGFloat.init(x.floatValue), y: CGFloat.init(y.floatValue))
    }
    set {
        let dict = [
            "x" : NSNumber.init(value: Float.init(newValue.x)),
            "y" : NSNumber.init(value: Float.init(newValue.y))
        ];
        UserDefaults.standard.set(dict, forKey: savedOpticalCenterKey)
        UserDefaults.standard.synchronize()
    }
}

var lastCarLocation : CGPoint {
    get {
        if (UserDefaults.standard.object(forKey: lastCarLocationKey) == nil) {
            return CGPoint.init(x: 42.357016, y: -71.059262)
        }
        let dict = UserDefaults.standard.dictionary(forKey: lastCarLocationKey)
        let x = dict!["x"] as! NSNumber
        let y = dict!["y"] as! NSNumber
        return CGPoint.init(x: CGFloat.init(x.floatValue), y: CGFloat.init(y.floatValue))
    }
    set {
        let dict = [
            "x" : NSNumber.init(value: Float.init(newValue.x)),
            "y" : NSNumber.init(value: Float.init(newValue.y))
        ];
        UserDefaults.standard.set(dict, forKey: lastCarLocationKey)
        UserDefaults.standard.synchronize()
    }
}
