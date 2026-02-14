//
//  WaylensClientS.swift
//  Acht
//
//  Created by gliu on 8/23/16.
//  Copyright © 2016 waylens. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
//import CocoaLumberjack
import Moya
import WaylensFoundation

extension Data {
    func hexString() -> String {
        return self.reduce("") { string, byte in
            string + String(format: "%02X", byte)
        }
    }
}

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}

//typealias completionBlock =  (WLAPIResult) -> Void

class WaylensClientS {
    static let shared = WaylensClientS()

    #if FLEET
    private let apiProvider = MoyaProvider<FleetAPI>(plugins: [NetworkLoggerPlugin(verbose: true)])
    #endif

    fileprivate var headers : [String: String] {
        var _headers = [
            "User-Agent"    : userAgent,
        ]
        if let token = AccountControlManager.shared.keyChainMgr.token {
            _headers["X-Auth-Token"] = token
        }
        return _headers
    }

    var baseApiUrl:String {
        #if FLEET
        // for report issue
        return "https://ws.waylens.com/360"
        #else
        return UserSetting.shared.server.rawValue
        #endif
    }

    var userAgent : String
    
    private init() {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        userAgent = "Secure360/\(version)/\(build);\(deviceModelName());\(UIDevice.current.systemName + UIDevice.current.systemVersion)"
    }
    
    func signup(_ email: String, password: String, completion: completionBlock?) {
        var params = [
            "email": email,
            "password": password,
            "deviceName": UIDevice.current.name
        ]

        if let remoteNotificationToken = RemoteNotificationController.shared.remoteNotificationToken {
            params["appToken"] = remoteNotificationToken
        }

        _ = post(.signup, params: params) { (result) in
            if result.isSuccess {
                AccountControlManager.shared.keyChainMgr.onLogInDone(result.value!, email:email)
            }
            completion?(result)
        }
    }

    #if FLEET
    
//    func loginNew(_ email : String , password : String , completion : completionBlock?) {
//        apiProvider.request(.loginNew(email: email, password: password), completionHandler: { result in
//            if result.isSuccess {
//                AccountControlManager.shared.keyChainMgr.onLogInDone(result.value!, email:email)
//                
//                WaylensClientS.shared.fetchProfile(completion: <#T##completionBlock?##completionBlock?##(WLAPIResult) -> Void#>)
//
//            } else {
//                completion?(result)
//            }
//            
//        })
//    }
   
    
    
    func login(_ email: String, password: String, deviceToken: String?, completion:completionBlock?) {
        apiProvider.request(.login(email: email, password: password, deviceToken: deviceToken, isSandBox: Environment.current.isSandBox), completionHandler: { result in
            if result.isSuccess {
                AccountControlManager.shared.keyChainMgr.onLogInDone(result.value!, email:email)

                // Must be behide `AccountControlManager.shared.keyChainMgr.onLogInDone`, because `AccountControlManager.shared.keyChainMgr.token` is needed to send subsequent requests.

                if let remoteNotificationToken = RemoteNotificationController.shared.remoteNotificationToken {
                    WaylensClientS.shared.refreshPushNotificationToken(remoteNotificationToken, completion: nil)
                }

                WaylensClientS.shared.fetchProfile { (profileResult) in
                    switch profileResult {
                    case .success(let profileResponse):
                        AccountControlManager.shared.keyChainMgr.updateProfile(profileResponse)
                        RemoteNotificationController.shared.registerForRemoteNotifications()
                        
                    case .failure(_):
                        break
                    }
                    completion?(profileResult)
                }
            } else {
                completion?(result)
            }
        })
    }
    
    
    
    
    #else
    func login(_ email: String, password: String, completion:completionBlock?) {
        var params = [
            "email": email,
            "password": password,
            "deviceName": UIDevice.current.name
        ]

        if let remoteNotificationToken = RemoteNotificationController.shared.remoteNotificationToken {
            params["appToken"] = remoteNotificationToken
        }

        _ = post(.login, params: params, completion:{ (result) in
            if result.isSuccess {
                AccountControlManager.shared.keyChainMgr.onLogInDone(result.value!, email:email)
            }
            completion?(result)
        })
    }
    #endif
    
    func logout(completion:completionBlock?) {
        #if FLEET
        apiProvider.request(.logout, completionHandler: completion)
        #else
        _ = post(.logout, params: nil) { (result) in
            completion?(result)
        }
        #endif
        AccountControlManager.shared.keyChainMgr.onLogOut()
    }
    
    func requestPasswordReset(email: String, completion: completionBlock?) {
        #if FLEET
        apiProvider.request(.requestPasswordReset(targetEmail: email), completionHandler: completion)
        #else
        let params = [
            "to": email
        ]
        post(.requestPasswordReset, params: params, completion: completion)
        #endif
    }
    
    func resetPassword(email: String, token: String, password: String, completion: completionBlock?) {
        #if FLEET
        apiProvider.request(.resetPassword(email: email, token: token, newPassword: password), completionHandler: completion)
        #else
        let params = [
            "email": email,
            "token": token,
            "newPassword": password
        ]
        post(.resetPassword, params: params, completion: completion)
        #endif
    }
    
    func resendVerification(completion: completionBlock?) {
        _ = post(.resendVerification, params: nil, completion: completion)
    }
    
    func changePassword(current: String, new: String, completion: completionBlock?) {
        #if FLEET
        apiProvider.request(.changePassword(userEmail: AccountControlManager.shared.keyChainMgr.email, oldPassword: current, newPassword: new), completionHandler: completion)
        #else
        let params = [
            "curPassword": current,
            "newPassword": new
        ]

        _ = put(.changePassword, params: params, completion: { (result) in
            if result.isSuccess {
                AccountControlManager.shared.keyChainMgr.onLogInDone(result.value!, email:AccountControlManager.shared.keyChainMgr.email)
            }
            completion?(result)
        })
        #endif
    }
    
    func fetchProfile(completion: completionBlock?) {
        #if FLEET
        apiProvider.request(.userInfo, completionHandler: { result in
            if result.isSuccess {
                AccountControlManager.shared.keyChainMgr.updateProfile(result.value!)
            }
            completion?(result)
        })
        #else
        get(.profile, params: nil) { (result) in
            if result.isSuccess {
                AccountControlManager.shared.keyChainMgr.updateProfile(result.value!)
            }
            completion?(result)
        }
        #endif
    }
    
    
    func congfiguareCamera(_ cameraSN : String, params : [String : Any], completion: completionBlock?) {
        _ = post(.configCamera(sn: cameraSN), params: params, completion: completion)
    }
    
    func updateProfile(name:String, completion: completionBlock?) {
        let params = [
            "displayName": name
        ]
        _ = post(.profile, params: params, completion: completion)
    }
    
    func bindCamera(_ cameraID : String, password : String, nickName : String, completion: completionBlock?) {
        let params = [
            "sn" : cameraID,
            "name" : nickName == "" ? cameraID : nickName,
            "password" : password
        ]
        _ = post(.bindDevice, params: params, completion: completion)
    }
    
    
    
    
    
    func unbindCamera(_ cameraID : String, completion: completionBlock?) {
        _ = delete(.device(cameraID), params: nil, completion: completion)
    }
    
//    func doSendAlarm(_ cameraID : String, success : @escaping (AnyObject?) -> Void, failed : @escaping (NSError?) -> Void) {
//        let params = [
//            "deviceID"  : cameraID,
//            "action"    : "alarm"
//        ]
//        self.doPost(urlSendAlarm(), params: params as [String : AnyObject]?, header: headers, success: success, failed: failed)
//    }
    
    func fetchUploadingAlerts(completion: @escaping ([AchtAlert]) -> ()) {
        fetchAlerts { (result) in
            Log.info("Did fetch uploading alerts:\n\(String(describing: result.value?["alerts"]))")
            let alerts: [AchtAlert] = (result.value?["alerts"] as? [[String: Any]])?.map({ AchtAlert(dict: $0)}).uploadingAlerts ?? []
            completion(alerts)
        }
    }
    
    func fetchAlerts(cursor:Int=0, count:Int=10, completion: completionBlock?) {
        #if FLEET
        apiProvider.request(.allEvents(cursor: cursor, count: count), completionHandler: completion)
        #else
        let params = [
            "cursor":cursor,
            "count":count
        ]
        get(.alerts, params: params, completion: completion)
        #endif
    }
    
    func fetchAlertsUnreadCount(completion: @escaping (Int?) -> ()) {
        fetchAlerts(count: 1) { (result) in
            var count: Int?
            if result.isSuccess, let unreadCount = result.value?["unreadCount"] as? Int {
                count = unreadCount
            }
            completion(count)
        }
    }
    
    func readAlert(_ eventID: Int64, completion: completionBlock?) {
        _ = post(.readEvent(eventID), params: nil, completion: completion)
    }
    
    func deleteAlert(_ eventID: Int64, completion: completionBlock?) {
        _ = delete(.event(eventID), params: nil, completion: completion)
    }
    
    func readAllAlerts(completion: completionBlock?) {
        _ = post(.readAllEvents, params: nil, completion: completion)
    }

    func fetchNotifications(cursor: Int = 0, count: Int = 10, completion: completionBlock?) {
        let params = [
            "cursor":cursor,
            "count":count
        ]
        get(.notifications, params: params, completion: completion)
    }

    func markNotificationRead(_ notificationID: Int64, completion: completionBlock?) {
        post(.markNotificationRead(notificationID), params: nil, completion: completion)
    }

    func markAllNotificationsRead(completion: completionBlock?) {
        post(.markAllNotificationsRead, params: nil, completion: completion)
    }

    func fetchNotificationsUnreadCount(completion: @escaping (Int?) -> ()) {
        fetchNotifications(count: 1) { (result) in
            var count: Int?
            if result.isSuccess, let unreadCount = result.value?["unreadCount"] as? Int {
                count = unreadCount
            }
            completion(count)
        }
    }
    
    func fetchCameraList(completion: completionBlock?) {
        #if FLEET
        apiProvider.request(.devices(cursor: 0, count: 100), completionHandler: completion)
        #else
        get(.devices, params: nil, completion: completion)
        #endif
    }

    func fetchClips(_ cameraID: String, filter: HNVideoOptions?=nil, cursor:Int=0, count:Int=10, completion: completionBlock?) {
        #if FLEET
        apiProvider.request(.deviceEvents(deviceID: cameraID, cursor: cursor, count: count), completionHandler: completion)
        #else
        var params: [String : Any] = [
            "sn": cameraID,
            "cursor": cursor,
            "count": count
        ]
        params["filterType"] = filter?.toString()
        get(.clips, params: params.dried(), completion: completion)
        #endif
    }
    
    func fetchClipsStats(_ cameraID: String, completion: completionBlock?) {
        #if FLEET
        let toDate = Date().toString(format: DateFormatType.isoDate)

        apiProvider.request(.deviceSummary(deviceID: cameraID, fromDate: "2015-01-01", toDate: toDate), completionHandler: { result in
            if result.isSuccess {
                var eventTotalCount: Int = 0
                if let statisticList = result.value?["statisticList"] as? [[String : Any]] {
                    statisticList.forEach { (statisticDict) in
                        if let eventCount = statisticDict["event"] as? Int {
                            eventTotalCount += eventCount
                        }
                    }
                    completion?(.success(["eventTotalCount" : eventTotalCount]))
                }
            } else {
                completion?(result)
            }
        })
        #else
        let params = [
            "sn": cameraID
        ]
        get(.clipsStats, params: params, completion: completion)
        #endif
    }
    
    func deleteClip(_ clipID: Int64, completion: completionBlock?) {
        _ = delete(.clip(clipID), params: nil, completion: completion)
    }
    
    func startLive(_ cameraID: String, completion: completionBlock?) {
        #if FLEET
        apiProvider.request(.startLive(deviceID: cameraID), completionHandler: completion)
        #else
        let params = [
            "action"    : "start"
        ]
        _ = post(.live(cameraID), params: params, completion: completion)
        #endif
    }
    
    func stopLive(_ cameraID: String, completion: completionBlock?) {
        #if FLEET
        apiProvider.request(.stopLive(deviceID: cameraID), completionHandler: completion)
        #else
        let params = [
            "action"    : "stop"
        ]
        post(.live(cameraID), params: params, completion: completion)
        #endif
    }
    
    func heartBeat(_ cameraID: String, completion: completionBlock?) {
        _ = post(.heartBeat(cameraID), params: nil, completion: completion)
    }
    
    func fetchLiveStatus(_ cameraID: String, completion: completionBlock?) {
        #if FLEET
        apiProvider.request(.liveStatus(deviceID: cameraID), completionHandler: completion)
        #else
        get(.liveStatus(cameraID), params: nil, completion: completion)
        #endif
    }
    
    func fetch4gSignal(_ cameraID: String, completion: completionBlock?) {
        _ = get(.signal4g(cameraID), params: nil, completion: completion)
    }
    
    func fetchLiveBitRate(_ cameraID: String, completion: completionBlock?) {
        #if FLEET
        apiProvider.request(.liveBitRate(deviceID: cameraID), completionHandler: completion)
        #else
        get(.liveBitRate(cameraID), params: nil, completion: completion)
        #endif
    }
    
    func updateCameraName(_ cameraID: String, name: String, completion: completionBlock?) {
        let params = [
            "name": name
        ]
        _ = post(.deviceName(cameraID), params: params, completion: completion)
    }
    
    func updateSettings(_ cameraID: String, settings: [String: Any], completion: completionBlock?) {
        #if FLEET
        apiProvider.request(.deviceUpdateSettings(deviceID: cameraID, settings: settings), completionHandler: completion)
        #else
        let params = [
            "settings": settings
        ]
        _ = post(.controlDevice(cameraID), params: params, completion: completion)
        #endif
    }

    func reportCamera(_ cameraID: String, info: [String: Any], completion: completionBlock?) {
        post(.uploadDevice(cameraID), params: info, completion: completion)
    }
    
    func reportICCID(_ cameraID: String, iccid: String, completion: completionBlock?) {
        let params = [
            "reportIccid": iccid
        ]
        _ = post(.reportDeviceIccid(cameraID), params: params, completion: completion)
    }
    
    func uploadAvatar(_ image: UIImage, progress: ((Float) -> Void)?, completion: completionBlock?) {
        
        _ = get(.avatar, params: nil) { [unowned self] (result) in
            if result.isSuccess {
                guard let data = image.jpegData(compressionQuality: 0.8) else {
                    completion?(.failure(WLError(code:-1, msg:"Image Broken")))
                    return
                }
                self.uploadImage(data: data, serverInfo: result.value!, progress: progress, completion: completion)
            } else {
                completion?(result)
            }
        }
    }

    func startAudioBroadcast(_ cameraSN: String, completion: completionBlock?) {
        #if FLEET
      //  apiProvider.request(.deviceAudioBroadcast(deviceID: cameraSn, action: "start"), completionHandler: completion)
        #else
        let params = [
            "action" : "start"
        ]
        post(.deviceAudioBroadcast(deviceID: cameraSN), params: params, completion: completion)
        #endif
    }

    func stopAudioBroadcast(_ cameraSN: String, completion: completionBlock?) {
        #if FLEET
      //  apiProvider.request(.deviceAudioBroadcast(deviceID: cameraSn, action: "stop"), completionHandler: completion)
        #else
        let params = [
            "action" : "stop"
        ]
        post(.deviceAudioBroadcast(deviceID: cameraSN), params: params, completion: completion)
        #endif
    }

    //MARK: - Only for Fleet

    #if FLEET

    func request(_ target: FleetAPI, completion: completionBlock?) {
        apiProvider.request(target, completionHandler: completion)
    }

    func fetchCameraOnlineStatus(_ cameraSn: String, completion: completionBlock?) {
        apiProvider.request(.deviceOnlineStatus(deviceID: cameraSn), completionHandler: completion)
    }

    func fetchCameraDataUsage(_ cameraSn: String, completion: completionBlock?) {
        apiProvider.request(.deviceDataUsage(deviceID: cameraSn, toDate: Int64(Date().millisecondsSince1970)), completionHandler: completion)
    }

    func fetchCameraManualUpgradeFirmwareInfo(_ cameraSn: String, completion: completionBlock?) {
        apiProvider.request(.deviceManualUpgradeFirmwareInfo(deviceID: cameraSn), completionHandler: completion)
    }

    func fetchVehiclesLastLocation(completion: completionBlock?) {
        apiProvider.request(.vehiclesLastLocation, completionHandler: completion)
    }

    func fetchDriversSummary(completion: completionBlock?) {
        let range = DateRange.rangeUsingInOverview
        let from = range.from.millisecondsSince1970
        let to = range.to.millisecondsSince1970

        apiProvider.request(.driversSummary(from: Int64(from), to:Int64(to)), completionHandler: completion)
    }

    func fetchDriverEvents(_ driverID: String, from: TimeInterval, to: TimeInterval, cursor: Int = 0, count: Int = 100, completion: completionBlock?) {
        apiProvider.request(.driverEvents(driverID: driverID, from: Int64(from), to: Int64(to), cursor: cursor, count: count), completionHandler: completion)
    }

    func fetchDriverEventsAll(_ driverID: String, eventType: String? = nil, from: TimeInterval, to: TimeInterval, completion: completionBlock?) {
        apiProvider.request(.driverEventsAll(driverID: driverID, eventType: eventType, from: Int64(from), to: Int64(to)), completionHandler: completion)
    }

    func fetchEventDetail(_ driverID: String, clipID: String, completion: completionBlock?) {
        apiProvider.request(.driverEventDetail(driverID: driverID, clipID: clipID, videoType: "mp4"), completionHandler: completion)
    }

    func fetchDriverTrips(_ driverID: String, completion: completionBlock?) {
        let range = DateRange.rangeUsingInOverview
        let from = range.from.millisecondsSince1970
        let to = range.to.millisecondsSince1970

        apiProvider.request(.driverTrips(driverID: driverID, from: Int64(from), to: Int64(to)), completionHandler: completion)
    }

    func fetchDriverStatisticAll(_ driverID: String, from: TimeInterval, to: TimeInterval, interval: Int = 24, completion: completionBlock?) {
        apiProvider.request(.driverStatisticAll(driverID: driverID, from: Int64(from), to: Int64(to), interval: interval), completionHandler: completion)
    }

    func fetchDriverTimeline(_ driverID: String, from: TimeInterval, to: TimeInterval, completion: completionBlock?) {
        apiProvider.request(.driverTimeline(driverID: driverID, from: Int64(from), to: Int64(to)), completionHandler: completion)
    }

    func fetchUserNotDriverInfoList(completion: completionBlock?) {
        apiProvider.request(.userNotDriverInfoList, completionHandler: completion)
    }

    func fetchDriverInfoList(completion: completionBlock?) {
        apiProvider.request(.driverInfoList, completionHandler: completion)
    }

    func fetchTripTrack(_ driverID: String, tripID: String, completion: completionBlock?) {
        let range = DateRange.rangeUsingInOverview
        let from = range.from.millisecondsSince1970
        let to = range.to.millisecondsSince1970

        apiProvider.request(.tripTrack(driverID: driverID, tripID: tripID, step: 15, from: Int64(from), to: Int64(to)), completionHandler: completion)
    }

    func fetchStatisticAll(from: TimeInterval, to: TimeInterval, interval: Int = 24, completion: completionBlock?) {
        apiProvider.request(.statisticAll(from: Int64(from), to: Int64(to), interval: interval), completionHandler: completion)
    }

    func fetchStatisticList(from: TimeInterval, to: TimeInterval, completion: completionBlock?) {
        apiProvider.request(.statisticList(from: Int64(from), to: Int64(to)), completionHandler: completion)
    }

    func addNewMemberNotDriver(email: String, name: String, phoneNumber: String, role: [String], completion: completionBlock?) {
        apiProvider.request(.addNewMemberNotDriver(email: email, name: name, phoneNumber: phoneNumber, role: role), completionHandler: completion)
    }

    func addNewDriver(email: String?, name: String, phoneNumber: String, completion: completionBlock?) {
        apiProvider.request(.addNewDriver(email: email, name: name, phoneNumber: phoneNumber), completionHandler: completion)
    }

    #endif

    //MARK: -

    private func uploadImage(data: Data, serverInfo: [String: Any], progress:((Float)->Void)?, completion: completionBlock?) {
        let server = serverInfo["uploadServer"] as! [String: Any]
        let baseUrl = server["url"] as! String
        let privateKey = server["privateKey"] as! String
        let cfsClient = CFSClient(baseUrl: baseUrl, privateKey: privateKey, userId: AccountControlManager.shared.keyChainMgr.userID)
        cfsClient?.uploadAvatar(data, progress: { (finished, error, msg, percent) in
            progress?(percent)
        }, completion: { (finished, error, msg) in
            var wlerror: WLError?
            if error != nil {
                wlerror = WLError(code: -1, msg: error!.localizedDescription)
            }
            let result = finished ? WLAPIResult.success(msg as! [String: Any]) : WLAPIResult.failure(wlerror)
            completion?(result)
        })
    }
    
    func report(_ detail:String?, camera:UnifiedCamera?, logFile:URL?, completion: completionBlock?) {
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String

        var params: [String: String]? = [
            "detail": detail,
            "agentHW": deviceModelName(),
            "agentOS": "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)",
            "appVersion": "\(appVersion)(\(build))",
            "cameraSN": camera?.sn,
            "cameraHW": camera?.model,
            "cameraFW": camera?.firmware,
            "mountHW": camera?.mountHwModel,
            "mountFW": camera?.mountFwVersion
        ].dried() as? [String: String]

        #if FLEET
        if !AccountControlManager.shared.keyChainMgr.userName.isEmpty {
            params?["userLogin"] = AccountControlManager.shared.keyChainMgr.userName
        }

        apiProvider.request(.uploadReport(params: params, logFileURL: logFile), completionHandler: completion)
        #else
        upload(.report, params: params, files: (logFile != nil ? ["file": logFile!] : nil), completion: completion)
        #endif
    }
    
    func getAddress(longitude: Double, latitude: Double, completion: completionBlock?) -> DataRequest {
        let params = [
            "longitude": String(format: "%.4f", longitude),
            "latitude": String(format: "%.4f", latitude)
        ]
        return get(.address, params: params, completion: completion)
    }
    
    func fetchCameraSubscription(_ cameraID:String,  completion: completionBlock?) {
        _ = get(.subscription(cameraID), params: nil, completion: completion)
    }
    
    func getFileSize(url: String, completion: @escaping (Int64) -> Void) {
        Alamofire.request(URL(string: url)!, method: .head, parameters: nil, encoding: URLEncoding.default, headers: headers)
            .responseData { (response) in
                let len = response.response?.expectedContentLength ?? -1
                Log.debug("expected content length \(len)")
                completion(len)
        }
    }
    
    func fetchNotificationSettings(_ cameraID: String, completion: completionBlock?) {
        _ = get(.cameraNotificationSettings(cameraID), params: nil, completion: completion)
    }
    
    func updateNotificationSettings(_ cameraID: String, settings: HNCSNotificationSettings, completion: completionBlock?) {
        updateNotificationSettings(cameraID, parkingMotionOn: settings.parkingMotionOn, parkingBumpOn: settings.parkingBumpOn, parkingImpactOn: settings.parkingImpactOn, drivingBumpOn: settings.drivingBumpOn, drivingImpactOn: settings.drivingImpactOn, completion: completion)
    }
    
    func updateNotificationSettings(_ cameraID: String, parkingMotionOn: Bool, parkingBumpOn: Bool, parkingImpactOn: Bool, drivingBumpOn: Bool, drivingImpactOn: Bool, completion: completionBlock?) {
        let params = [
            "PARKING_MOTION": parkingMotionOn ? "on" : "off",
            "PARKING_HIT": parkingBumpOn ? "on" : "off",
            "PARKING_HEAVY_HIT": parkingImpactOn ? "on" : "off",
            "DRIVING_HIT": drivingBumpOn ? "on" : "off",
            "DRIVING_HEAVY_HIT": drivingImpactOn ? "on" : "off"
        ]
        _ = post(.cameraNotificationSettings(cameraID), params: params, completion: completion)
    }
	
    func refreshPushNotificationToken(_ token: String, completion: completionBlock?) {
        #if FLEET
        apiProvider.request(.refreshPushNotificationToken(deviceToken: token, isSandBox: Environment.current.isSandBox), completionHandler: completion)
        #else
        let params = [
            "newDeviceToken": token
        ]
        _ = post(.refreshPushNotificationToken, params: params, completion: completion)
        #endif
    }
    
    func fetchForumLoginUrl(completion: completionBlock?) {
        _ = get(.forumLogin, params: nil, completion: completion)
    }

    private func upload(_ endpoint:EndPoint, params: [String: String]?, files: [String: URL]?, completion: completionBlock?) {
        let url = baseApiUrl + endpoint.url
        Alamofire.upload(multipartFormData: { (multiPartFormData) in
            if let params = params {
                for (key, value) in params {
                    multiPartFormData.append(value.data(using: .utf8)!, withName: key)
                }
            }
            if let files = files {
                for (key, value) in files {
                    multiPartFormData.append(value, withName: key)
                }
            }
        }, to: url, headers: self.headers) { (result) in
            switch result {
            case .success(let uploadRequest, _, _):
                uploadRequest.responseJSON(completionHandler: { (response) in
                    if response.result.isFailure {
                        Log.verbose(String(data: response.data!, encoding: .utf8) ?? "")
                        let errorDescription = (response.result.error as NSError?)?.localizedDescription ?? NSLocalizedString("Network Error", comment: "Network Error")
                        let error = WLError(code: WLAPIError.networkError.rawValue, msg: errorDescription)
                        completion?(.failure(error))
                    } else {
                        let data = response.result.value as! [String: Any]
                        if data["code"] as? Int ?? 0 == 0 {
                            completion?(.success(data))
                        } else {
                            let error = WLError(code: data["code"] as! Int, msg: data["msg"] as! String)
                            if error.asAPIError == WLAPIError.authFailed {
                                #if !FLEET
                                AccountControlManager.shared.keyChainMgr.onLogOut()
                                AppViewControllerManager.gotoLogin()
                                #endif
                            }
                            completion?(.failure(error))
                        }
                    }
                })
            case .failure(let encodingError):
                let error = WLError(code: WLAPIError.networkError.rawValue, msg: encodingError.localizedDescription)
                completion?(.failure(error))
            }
        }
    }
    
    private func request(_ endpoint:EndPoint, method:HTTPMethod, params: [String: Any]?, logData:Bool=true, completion: completionBlock?) -> DataRequest {
        let url = baseApiUrl + endpoint.url
        return Alamofire.request(url, method: method, parameters:params, encoding: method == .get ? URLEncoding.queryString : JSONEncoding.default, headers: headers)
            .responseJSON { response in
                if endpoint.shouldLogResponse {
                    if let body = response.request?.httpBody {
                        if logData {
                            Log.info("\(method) \(response.request?.url?.absoluteString ?? url), \nbody:\(String(data:body, encoding: .utf8) ?? "nil"),\nresponse:\(response)")
                        } else {
                            Log.info("\(method) \(response.request?.url?.absoluteString ?? url),\nresponse:\(response)")
                        }
                    } else {
                        Log.info("\(method) \(response.request?.url?.absoluteString ?? url), \nresponse:\(response)")
                    }
                }

                if response.result.isFailure {
                    if endpoint.shouldLogResponse {
                        Log.verbose(String(data: response.data!, encoding: .utf8) ?? "")
                    }

                    var apiError: WLAPIError!
                    if let aferror = response.error as? AFError, aferror.isResponseSerializationError {
                        apiError = .jsonFormatError
                    } else {
                        apiError = .networkError
                    }
                    let errorDescription = (response.result.error as NSError?)?.localizedDescription ?? NSLocalizedString("Network Error", comment: "Network Error")
                    let error = WLError(code: apiError.rawValue, msg: errorDescription)
                    completion?(.failure(error))
                } else {
                    if let httpResponse = response.response, let fields = httpResponse.allHeaderFields as? [String : String] {
                        // save cookie in shared CookieStorage, to pass access restriction for video / image requests
                        let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: httpResponse.url!)
                        HTTPCookieStorage.shared.setCookies(cookies, for: httpResponse.url!, mainDocumentURL: nil)
                        for cookie in cookies {
                            var cookieProperties = cookie.properties!
                            cookieProperties[HTTPCookiePropertyKey.expires] = cookie.expiresDate ?? Date().addingTimeInterval(3600)
                            let newCookie = HTTPCookie(properties: cookieProperties)
                            HTTPCookieStorage.shared.setCookie(newCookie!)
                        }
                    }
                    let data = response.result.value as! [String: Any]
                    if data["code"] as? Int ?? 0 == 0 {
                        completion?(.success(data))
                    } else {
                        let error = WLError(code: data["code"] as! Int, msg: data["msg"] as! String)
                        if error.asAPIError == WLAPIError.authFailed { // auth token invalid, try to login again
                            #if !FLEET
                            AccountControlManager.shared.keyChainMgr.onLogOut()
                            AppViewControllerManager.gotoLogin()
                            #endif
                        }
                        completion?(.failure(error))
                    }
                }
        }
    }

    @discardableResult
    internal func get(_ endpoint:EndPoint, params: [String: Any]?, completion: completionBlock?) -> DataRequest {
        return request(endpoint, method: .get, params: params, completion: completion)
    }

    @discardableResult
    private func post(_ endpoint:EndPoint, params: [String: Any]?, logData:Bool=true, completion: completionBlock?) -> DataRequest {
        return request(endpoint, method: .post, params: params, logData: logData, completion: completion)
    }
    
    private func put(_ endpoint:EndPoint, params: [String: Any]?, completion: completionBlock?) -> DataRequest {
        return request(endpoint, method: .put, params: params, completion: completion)
    }
    
    private func delete(_ endpoint:EndPoint, params: [String: Any]?, completion: completionBlock?) -> DataRequest {
        return request(endpoint, method: .delete, params: params, completion: completion)
    }
}
