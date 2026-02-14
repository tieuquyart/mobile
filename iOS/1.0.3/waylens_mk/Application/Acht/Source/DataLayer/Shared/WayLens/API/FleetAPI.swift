//
//  FleetAPI.swift
//  Acht
//
//  Created by forkon on 2019/8/26.
//  Copyright © 2019 waylens. All rights reserved.
//

import Moya
import WaylensFoundation


enum FleetAPI {
   
    
    case login(email: String, password: String, deviceToken: String?, isSandBox: Bool)
    case logout
    case userInfo
    case userInfoWithEmail(email: String)
    case changePassword(userEmail: String, oldPassword: String, newPassword: String)
    case requestPasswordReset(targetEmail: String)
    case resetPassword(email: String, token: String, newPassword: String)
    case devices(cursor: Int, count: Int)
    case deviceInfo(deviceID: String)
    case deviceOnlineStatus(deviceID: String)
    case deviceEvents(deviceID: String, cursor: Int, count: Int)
    case deviceSummary(deviceID: String, fromDate: String, toDate: String) // eg. 2019-07-01
    case deviceDataUsage(deviceID: String, toDate: Int64)
    case deviceManualUpgradeFirmwareInfo(deviceID: String)
    case deviceUpdateSettings(deviceID: String, settings: [String : Any])
    case deviceAudioBroadcast(deviceID: String, action: String) // action: start or stop
    case startLive(deviceID: String)
    case stopLive(deviceID: String)
    case liveStatus(deviceID: String)
    case liveBitRate(deviceID: String)
    case allEvents(cursor: Int, count: Int)
    case driversSummary(from: Int64, to: Int64)
    case vehiclesLastLocation
    case driverEvents(driverID: String, from: Int64, to: Int64, cursor: Int, count: Int)
    case driverEventsAll(driverID: String, eventType: String?, from: Int64, to: Int64)
    case driverEventDetail(driverID: String, clipID: String, videoType: String) // videoType: mp4 or hls
    case driverTrips(driverID: String, from: Int64, to: Int64)
    case driverStatisticAll(driverID: String, from: Int64, to: Int64, interval: Int)
    case driverTimeline(driverID: String, from: Int64, to: Int64)
    case driverInfoList
    case driverInfo(driverID: String)
    case userNotDriverInfoList
    case tripTrack(driverID: String, tripID: String, step: Int, from: Int64, to: Int64)
    case statisticAll(from: Int64, to: Int64, interval: Int)
    case statisticList(from: Int64, to: Int64)
    case addNewMemberNotDriver(email: String, name: String, phoneNumber: String?, role: [String])
    case addNewDriver(email: String?, name: String, phoneNumber: String?)
    case addNewInstaller(email: String, name: String, password: String)
    case removeMemberNotDriver(email: String)
    case removeDriver(driverID: String)
    case editMemberNotDriverProfile(email: String, name: String, phoneNumber: String?, role: [String])
    case editDriverProfile(driverID: String, name: String, phoneNumber: String?, email: String?)
    case changeFleetOwner(targetOwnerEmail: String, currentOwnerPassword: String)
    case vehicleInfoList
    case cameraList
    case bindVehicleCamera(vehicleID: String, cameraSN: String)
    case unbindVehicleCamera(vehicleID: String, cameraSN: String)
    case bindVehicleDriver(vehicleID: String, driverID: String)
    case unbindVehicleDriver(vehicleID: String, driverID: String)
    case updateVehicleDriverBinding(vehicleID: String, driverID: String)
    case editVehicleProfile(vehicleID: String, plateNumber: String, model: String)
    case removeVehicle(vehicleID: String)
    case addCamera(cameraSN: String, password: String)
    case removeCamera(cameraSN: String)
    case activateCameraSimCard(cameraSN: String)
    case deactivateCameraSimCard(cameraSN: String)
    case addVehicle(plateNumber: String, model: String)
    case billingData
    case historicalBillingData
    case notificationList(from: Int64, to: Int64)
    case notificationsUnreadCount(from: Int64, to: Int64)
    case markNotificationsAsRead(notificationIDs: [String])
    case uploadReport(params: [String : String]?, logFileURL: URL?)
    case userNotificationInfo
    case unsubscribeNotification(notificationType: [String])
    case refreshPushNotificationToken(deviceToken: String, isSandBox: Bool)
    case addGeoFence(name: String, center: CLLocationCoordinate2D?, radius: Int?, polygon: [CLLocationCoordinate2D]?)
    case removeGeoFence(fenceID: String)
    case enableGeofence(fenceID: String)
    case disableGeofence(fenceID: String)
    case geoFenceDetail(fenceID: String)
    case geoFenceList(type: String)
    case geoFenceRuleList
    case geoFenceRuleDetail(fenceRuleID: String)
    case addGeoFenceRule(fenceID: String, name: String, type: [String], scope: String, vehicleList: [String]?)
    case removeGeoFenceRule(fenceRuleID: String)
    case editGeoFenceRule(fenceRuleID: String, name: String, type: [String], scope: String, vehicleList: [String]?)
}

extension FleetAPI: TargetType {

    var baseURL: URL {
        return URL(string: UserSetting.shared.server.rawValue)!
    }

    var path: String {
        switch self {
    
        case .login:
            return "/login"
        case .logout:
            return "/logout"
        case .userInfo:
            return "/users/userInfo"
        case .changePassword:
            return "/users/passWord"
        case .requestPasswordReset:
            return "/users/send_passwordreset_email"
        case .resetPassword:
            return "/users/reset_password"
        case .devices:
            return "/fleet/devices"
        case .vehiclesLastLocation:
            return "/fleet/drivers/vehicle_last_location"
        case .deviceInfo(let deviceID):
            return "/fleet/devices/\(deviceID)"
        case .deviceOnlineStatus(let deviceID):
            return "/fleet/devices/\(deviceID)/online_status"
        case .deviceEvents(let deviceID, _, _):
            return "/fleet/devices/\(deviceID)/events"
        case .deviceSummary(let deviceID, _, _):
            return "/fleet/summary/day/\(deviceID)"
        case .deviceDataUsage(let deviceID, _):
            return "/fleet/devices/\(deviceID)/datausage"
        case .deviceManualUpgradeFirmwareInfo(let deviceID):
            return "/fleet/devices/\(deviceID)/manual_upgrade_firmware"
        case .deviceAudioBroadcast(let deviceID, _):
            return "/fleet/devices/\(deviceID)/audio"
        case .deviceUpdateSettings(let deviceID, _):
            return "/fleet/devices/\(deviceID)/manual_configure"
        case .startLive(let deviceID), .stopLive(let deviceID):
            return "/fleet/devices/\(deviceID)/streaming"
        case .liveStatus(let deviceID):
            return "/fleet/devices/\(deviceID)/streaming/status"
        case .liveBitRate(let deviceID):
            return "/fleet/devices/\(deviceID)/streaming/bps"
        case .allEvents:
            return "/fleet/events"
        case .driversSummary:
            return "/fleet/overview/summary"
        case .driverEvents(let driverID, _, _, _, _):
            return "/fleet/driver/\(driverID)/eventList"
        case .driverEventsAll(let driverID, _, _, _):
            return "/fleet/driver/\(driverID)/eventListAll"
        case .driverEventDetail(let driverID, let clipID, _):
            return "/fleet/driver/\(driverID)/events/\(clipID)"
        case .driverTrips(let driverID, _, _):
            return "/fleet/driver/\(driverID)/trips"
        case .driverStatisticAll(let driverID, _, _, _):
            return "/fleet/statistic/driver/\(driverID)"
        case .driverTimeline(let driverID, _, _):
            return "/fleet/timeline/\(driverID)"
        case .driverInfo(let driverID):
            return "/usersManagement/driverInfo/\(driverID)"
        case .driverInfoList:
            return "/usersManagement/driverInfoList"
        case .userNotDriverInfoList:
            return "/usersManagement/userNotDriverInfoList"
        case .tripTrack(let driverID, let tripID, _, _, _):
            return "/fleet/driver/\(driverID)/trips/\(tripID)/track"
        case .statisticAll(_, _, _):
            return "/fleet/statistic/all"
        case .statisticList(_, _):
            return "/fleet/statistic/list"
        case .addNewMemberNotDriver(_, _, _, _):
            return "/usersManagement/userInfo"
        case .addNewDriver(_, _, _):
            return "/usersManagement/driverInfo"
        case .removeMemberNotDriver(_):
            return "/usersManagement/userInfo"
        case .removeDriver(let driverID):
            return "/usersManagement/driverInfo/\(driverID)"
        case .editMemberNotDriverProfile(_, _, _, _):
            return "/usersManagement/editUserInfo"
        case .editDriverProfile(let driverID, _, _, _):
            return "/usersManagement/driverInfo/\(driverID)"
        case .changeFleetOwner(_, _):
            return "/usersManagement/fleetOwner"
        case .vehicleInfoList:
            return "/usersManagement/vehicleInfoList"
        case .cameraList:
            return "/usersManagement/cameraList"
        case .bindVehicleCamera(_, _):
            return "/usersManagement/bind/vehicleCamera"
        case .unbindVehicleCamera(_, _):
            return "/usersManagement/unbind/vehicleCamera"
        case .bindVehicleDriver(_, _):
            return "/usersManagement/bind/vehicleDriver"
        case .unbindVehicleDriver(_, _):
            return "/usersManagement/unbind/vehicleDriver"
        case .updateVehicleDriverBinding(_, _):
            return "/usersManagement/bind/vehicleDriver/update"
        case .editVehicleProfile(let vehicleID, _, _):
            return "/usersManagement/vehicleInfo/\(vehicleID)"
        case .removeVehicle(let vehicleID):
            return "/usersManagement/vehicleInfo/\(vehicleID)"
        case .addCamera(_, _):
            return "/usersManagement/camera"
        case .removeCamera(let cameraSN):
            return "/usersManagement/camera/\(cameraSN)"
        case .addNewInstaller:
            return "/usersManagement/installerInfo"
        case .addVehicle:
            return "/usersManagement/vehicleInfo"
        case .userInfoWithEmail(_):
            return "/usersManagement/userInfo"
        case .activateCameraSimCard(let cameraSN):
            return "fleet/devices/\(cameraSN)/activatesim"
        case .deactivateCameraSimCard(let cameraSN):
            return "fleet/devices/\(cameraSN)/deactivatesim"
        case .billingData:
            return "/fleet/billing/invoices"
        case .historicalBillingData:
            return "/fleet/billing/invoices/history"
        case .notificationList(_, _):
            return "fleet/notificationList"
        case .markNotificationsAsRead:
            return "fleet/notificationList"
        case .notificationsUnreadCount:
            return "fleet/notificationList/unread"
        case .uploadReport:
            return "api/admin/report/mobileReport"
        case .userNotificationInfo:
            return "/users/userNotificationInfo"
        case .unsubscribeNotification:
            return "/fleet/notification/unsubscribe"
        case .refreshPushNotificationToken:
            return "/users/refreshDeviceToken"
        case .addGeoFence:
            return "fleet/geoFence/fence"
        case .removeGeoFence(let fenceID):
            return "fleet/geoFence/fence/\(fenceID)"
        case .enableGeofence(let fenceID):
            return "/fleet/geofences/\(fenceID)/enable"
        case .disableGeofence(let fenceID):
            return "/fleet/geofences/\(fenceID)/enable"
        case .geoFenceDetail(let fenceID):
            return "/fleet/geoFence/fence/\(fenceID)"
        case .geoFenceList:
            return "fleet/geoFence/fenceList"
        case .geoFenceRuleList:
            return "fleet/geoFence/fenceRuleList"
        case .geoFenceRuleDetail(let fenceRuleID):
            return "fleet/geoFence/fenceRule/\(fenceRuleID)"
        case .addGeoFenceRule:
            return "fleet/geoFence/fenceRule"
        case .removeGeoFenceRule(let fenceRuleID):
            return "fleet/geoFence/fenceRule/\(fenceRuleID)"
        case .editGeoFenceRule(let fenceRuleID, _, _, _, _):
            return "fleet/geoFence/fenceRule/\(fenceRuleID)"
        }
    }

    var method: Moya.Method {
        switch self {
        case
             .login,
             .logout,
             .startLive,
             .stopLive,
             .changePassword,
             .requestPasswordReset,
             .resetPassword,
             .deviceUpdateSettings,
             .deviceAudioBroadcast,
             .addNewDriver,
             .addNewMemberNotDriver,
             .editMemberNotDriverProfile,
             .editDriverProfile,
             .changeFleetOwner,
             .unbindVehicleCamera,
             .bindVehicleCamera,
             .editVehicleProfile,
             .bindVehicleDriver,
             .unbindVehicleDriver,
             .updateVehicleDriverBinding,
             .addCamera,
             .activateCameraSimCard,
             .deactivateCameraSimCard,
             .addVehicle,
             .uploadReport,
             .unsubscribeNotification,
             .refreshPushNotificationToken,
             .markNotificationsAsRead,
             .addGeoFence,
             .enableGeofence,
             .disableGeofence,
             .addGeoFenceRule,
             .editGeoFenceRule,
             .addNewInstaller:
            return .post
        case .devices,
             .vehiclesLastLocation,
             .deviceOnlineStatus,
             .deviceEvents,
             .deviceInfo,
             .deviceSummary,
             .deviceDataUsage,
             .deviceManualUpgradeFirmwareInfo,
             .liveStatus,
             .liveBitRate,
             .allEvents,
             .userInfo,
             .userInfoWithEmail,
             .driversSummary,
             .driverEvents,
             .driverEventsAll,
             .driverTrips,
             .driverEventDetail,
             .driverStatisticAll,
             .driverTimeline,
             .driverInfoList,
             .driverInfo,
             .userNotDriverInfoList,
             .tripTrack,
             .statisticAll,
             .statisticList,
             .vehicleInfoList,
             .cameraList,
             .billingData,
             .historicalBillingData,
             .notificationList,
             .notificationsUnreadCount,
             .userNotificationInfo,
             .geoFenceDetail,
             .geoFenceList,
             .geoFenceRuleList,
             .geoFenceRuleDetail:
            return .get
        case .removeMemberNotDriver,
             .removeDriver,
             .removeVehicle,
             .removeCamera,
             .removeGeoFence,
             .removeGeoFenceRule:
            return .delete
      
            
        }
    }

    var sampleData: Data {
        return Data()
    }

    var task: Moya.Task {
        let encoding = URLEncoding.default//JSONEncoding.default

        switch self {
        case .login(let email, let password, let deviceToken, let isSandBox):
            var parameters: [String : Any] = [
                "username" : email,
                "password" : password,
                "isSandBox" : isSandBox
            ]

            if let deviceToken = deviceToken {
                parameters["deviceToken"] = deviceToken
            }

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .logout:
            return .requestPlain
        case .devices(let cursor, let count):
            return .requestParameters(
                parameters: [
                    "cursor" : cursor,
                    "count" : count
                ],
                encoding: encoding
            )
        case .vehiclesLastLocation:
            return .requestPlain
        case .deviceOnlineStatus:
            return .requestPlain
        case .deviceEvents(_, let cursor, let count):
            return .requestParameters(
                parameters: [
                    "cursor" : cursor,
                    "count" : count
                ],
                encoding: encoding
            )
        case .deviceSummary(_, let fromDate, let toDate):
            return .requestParameters(
                parameters: [
                    "from" : fromDate,
                    "to" : toDate
                ],
                encoding: encoding
            )
        case .deviceDataUsage(_, _):
            return .requestPlain
//            return .requestCompositeParameters(
//                bodyParameters: [
//                    "from" : "1567419565930.3499",
//                    "to" : "\(toDate)"
//                ],
//                bodyEncoding: JSONEncoding.default,
//                urlParameters: [:]
//            )
        case .deviceManualUpgradeFirmwareInfo:
            return .requestPlain
        case .deviceAudioBroadcast(_, let action):
            return .requestCompositeParameters(
                bodyParameters: [
                    "action" : action
                ],
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .deviceUpdateSettings(_, let settings):
            return .requestCompositeParameters(
                bodyParameters: [
                    "settings" : settings
                ],
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .startLive:
            return .requestCompositeParameters(
                bodyParameters: [
                    "action" : "start"
                ],
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .stopLive:
            return .requestCompositeParameters(
                bodyParameters: [
                    "action" : "stop"
                ],
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .liveStatus:
            return .requestPlain
        case .liveBitRate:
            return .requestPlain
        case .allEvents(let cursor, let count):
            return .requestParameters(
                parameters: [
                    "cursor" : cursor,
                    "count" : count
                ],
                encoding: encoding
            )
        case .userInfo:
            return .requestPlain
        case .userInfoWithEmail(let email):
            return .requestParameters(
                parameters: [
                    "email" : email
                ],
                encoding: encoding
            )
        case .changePassword(let userEmail, let oldPassword, let newPassword):
            return .requestParameters(
                parameters: [
                    "UserEmail" : userEmail,
                    "OldPassword" : oldPassword,
                    "NewPassword" : newPassword
                ],
                encoding: JSONEncoding.default
            )
        case .requestPasswordReset(let targetEmail):
            return .requestParameters(
                parameters: [
                    "to" : targetEmail
                ],
                encoding: JSONEncoding.default
            )
        case .resetPassword(let email, let token, let newPassword):
            return .requestParameters(
                parameters: [
                    "Email" : email,
                    "Token" : token,
                    "NewPassword" : newPassword
                ],
                encoding: JSONEncoding.default
            )
        case .driversSummary(let from, let to):
            return .requestParameters(
                parameters: [
                    "from" : from,
                    "to" : to
                ],
                encoding: encoding
            )
        case .driverEvents(_, let from, let to, let cursor, let count):
            return .requestParameters(
                parameters: [
                    "from" : from,
                    "to" : to,
                    "cursor" : cursor,
                    "count" : count
                ],
                encoding: encoding
            )
        case .driverEventsAll(_, let eventType, let from, let to):
            var parameters: [String : Any] = [
                "from" : from,
                "to" : to
            ]

            if let eventType = eventType {
                parameters["eventType"] = eventType
            }

            return .requestParameters(
                parameters: parameters,
                encoding: encoding
            )
        case .driverTrips(_, let from, let to):
            return .requestParameters(
                parameters: [
                    "from" : from,
                    "to" : to
                ],
                encoding: encoding
            )
        case .driverEventDetail(_, _, let videoType):
            return .requestParameters(
                parameters: [
                    "videoType": videoType
                ],
                encoding: encoding
            )
        case .driverStatisticAll(_, let from, let to, let interval):
            return .requestParameters(
                parameters: [
                    "interval": interval,
                    "from" : from,
                    "to" : to
                ],
                encoding: encoding
            )
        case .driverTimeline(_, let from, let to):
            return .requestParameters(
                parameters: [
                    "from" : from,
                    "to" : to
                ],
                encoding: encoding
            )
        case .driverInfoList:
            return .requestPlain
        case .driverInfo(_):
            return .requestPlain
        case .userNotDriverInfoList:
            return .requestPlain
        case .tripTrack(_, _, let step, let from, let to):
            return .requestParameters(
                parameters: [
                    "step": step,
                    "from" : from,
                    "to" : to
                ],
                encoding: encoding
            )
        case .statisticAll(let from, let to, let interval):
            return .requestParameters(
                parameters: [
                    "interval": interval,
                    "from" : from,
                    "to" : to
                ],
                encoding: encoding
            )
        case .statisticList(let from, let to):
            return .requestParameters(
                parameters: [
                    "from" : from,
                    "to" : to
                ],
                encoding: encoding
            )
        case .addNewMemberNotDriver(let email, let name, let phoneNumber, let role):
            var parameters: [String : Any] = [
                "name" : name,
                "email" : email,
                "role" : role
            ]

            if let phoneNumber = phoneNumber {
                parameters["phoneNumber"] = phoneNumber
            }

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .addNewDriver(let email, let name, let phoneNumber):
            var parameters: [String : Any] = [
                "name" : name
            ]

            if let phoneNumber = phoneNumber {
                parameters["phoneNumber"] = phoneNumber
            }

            if let email = email {
                parameters["email"] = email
            }

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .removeMemberNotDriver(let email):
            return .requestCompositeParameters(
                bodyParameters: [
                    "email" : email
                ],
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .removeDriver(_):
            return .requestPlain
        case .editMemberNotDriverProfile(let email, let name, let phoneNumber, let role):
            var parameters: [String : Any] = [
                "name" : name,
                "email" : email,
                "role" : role
            ]

            if let phoneNumber = phoneNumber {
                parameters["phoneNumber"] = phoneNumber
            }

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .editDriverProfile(_, let name, let phoneNumber, let email):
            var parameters: [String : Any] = [
                "name" : name
            ]

            if let phoneNumber = phoneNumber {
                parameters["phoneNumber"] = phoneNumber
            }

            if let email = email {
                parameters["email"] = email
            }

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .changeFleetOwner(let targetOwnerEmail, let currentOwnerPassword):
            let parameters: [String : Any] = [
                "targetOwnerEmail" : targetOwnerEmail,
                "currentOwnerPassword" : currentOwnerPassword
            ]

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .vehicleInfoList:
            return .requestPlain
        case .cameraList:
            return .requestPlain
        case .unbindVehicleCamera(let vehicleID, let cameraSN):
            let parameters: [String : Any] = [
                "vehicleID" : vehicleID,
                "cameraSN" : cameraSN
            ]

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .bindVehicleCamera(let vehicleID, let cameraSN):
            let parameters: [String : Any] = [
                "vehicleID" : vehicleID,
                "cameraSN" : cameraSN
            ]

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .bindVehicleDriver(let vehicleID, let driverID):
            let parameters: [String : Any] = [
                "vehicleID" : vehicleID,
                "driverID" : driverID
            ]

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .unbindVehicleDriver(let vehicleID, let driverID):
            let parameters: [String : Any] = [
                "vehicleID" : vehicleID,
                "driverID" : driverID
            ]

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .updateVehicleDriverBinding(let vehicleID, let driverID):
            let parameters: [String : Any] = [
                "vehicleID" : vehicleID,
                "driverID" : driverID
            ]

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .editVehicleProfile(_, let plateNumber, let model):
            let parameters: [String : Any] = [
                "plateNumber" : plateNumber,
                "model" : model
            ]

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .removeVehicle(_):
            return .requestPlain
        case .addCamera(let cameraSN, let password):
            let parameters: [String : Any] = [
                "cameraSN" : cameraSN,
                "password" : password
            ]

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .removeCamera(_):
            return .requestPlain
        case .activateCameraSimCard(_):
            return .requestPlain
        case .deactivateCameraSimCard(_):
            return .requestPlain
        case .deviceInfo(_):
            return .requestPlain
        case .addVehicle(let plateNumber, let model):
            let parameters: [String : Any] = [
                "plateNumber" : plateNumber,
                "model" : model
            ]

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .billingData:
            return .requestPlain
        case .historicalBillingData:
            return .requestPlain
        case .notificationList(let from, let to):
            return .requestParameters(
                parameters: [
                    "from" : from,
                    "to" : to
                ],
                encoding: encoding
            )
        case .notificationsUnreadCount(let from, let to):
            return .requestParameters(
                parameters: [
                    "from" : from,
                    "to" : to
                ],
                encoding: encoding
            )
        case .markNotificationsAsRead(let notificationIDs):
            return .requestCompositeParameters(
                bodyParameters: [
                    "notificationID" : notificationIDs
                ],
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .uploadReport(let params, let logFileURL):
            var multipart: [MultipartFormData] = []

            if let logFileURL = logFileURL {
                multipart.append(MultipartFormData(provider: MultipartFormData.FormDataProvider.file(logFileURL), name: "file"))
            }

            if let params = params {
                params.forEach({ (key, value) in
                    multipart.append(MultipartFormData(provider: .data(value.data(using: .utf8)!), name: key))
                })
            }

            return .uploadMultipart(multipart)
        case .userNotificationInfo:
            return .requestPlain
        case .unsubscribeNotification(let notificationType):
            let parameters: [String : Any] = [
                "notificationType" : notificationType
            ]

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .refreshPushNotificationToken(let deviceToken, let isSandBox):
            let parameters: [String : Any] = [
                "token" : deviceToken,
                "isSandBox" : isSandBox
            ]

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .addGeoFence(let name, let center, let radius, let polygon):
            var parameters: [String : Any] = [
                "name" : name,
                "description" : ""
            ]

            if let center = center?.convertedToWgsCoordinate(), let radius = radius {
                parameters["center"] = [center.latitude, center.longitude]
                parameters["radius"] = radius
            }
            else {
                if var polygon = polygon {
                    if let firstPoint = polygon.first, firstPoint != polygon.last {
                        polygon.append(firstPoint)
                    }

                    parameters["polygon"] = polygon.map{$0.convertedToWgsCoordinate()}.compactMap{[$0.latitude, $0.longitude]}
                }
            }

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .removeGeoFence:
            return .requestPlain
        case .enableGeofence:
            let parameters: [String : Any] = [
                "enable" : true
            ]

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .disableGeofence:
            let parameters: [String : Any] = [
                "enable" : false
            ]

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .geoFenceDetail:
            return .requestPlain
        case .geoFenceList(let type):
            return .requestParameters(
                parameters: [
                    "type" : type
                ],
                encoding: encoding
            )
        case .geoFenceRuleList:
            return .requestPlain
        case .geoFenceRuleDetail:
            return .requestPlain
        case .addGeoFenceRule(let fenceID, let name, let type, let scope, let vehicleList):
            var parameters: [String : Any] = [
                "fenceID" : fenceID,
                "name" : name,
                "type" : type,
                "scope" : scope
            ]

            if let vehicleList = vehicleList {
                parameters["vehicleList"] = vehicleList
            }

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .removeGeoFenceRule:
            return .requestPlain
        case .editGeoFenceRule(_, let name, let type, let scope, let vehicleList):
            var parameters: [String : Any] = [
                "name" : name,
                "type" : type,
                "scope" : scope
            ]

            if let vehicleList = vehicleList {
                parameters["vehicleList"] = vehicleList
            }

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        case .addNewInstaller(let email, let name, let password):
            let parameters: [String : Any] = [
                "email" : email,
                "name" : name,
                "password" : password
            ]

            return .requestCompositeParameters(
                bodyParameters: parameters,
                bodyEncoding: JSONEncoding.default,
                urlParameters: [:]
            )
        }
    }

  /*  var headers: [String : String]? {
        var headers: [String : String] = [:]

        switch self {
        case .login:
            break
        default:
            if let token = AccountControlManager.shared.keyChainMgr.token {
                headers["Authorization"] = "Bearer \(token)"
            }
        }

        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let userAgent = "FleetApp/\(version)/\(build);\(deviceModelName());\(UIDevice.current.systemName + UIDevice.current.systemVersion);\(UIDevice.current.name)"
        headers["User-Agent"] = userAgent

        return headers
    }*/
    
    var headers: [String : String]? {
        var headers: [String : String] = [:]
        headers["x-access-token"] = AccountControlManager.shared.keyChainMgr.token
        return headers
    }

}

extension FleetAPI {

    var shouldLogResponse: Bool {
        #if DEBUG
        return true
        #else
        switch self {
        case .login,
             .resetPassword,
             .changeFleetOwner,
             .addCamera,
             .addNewInstaller:
            return false
        default:
            return true
        }
        #endif
    }

}
