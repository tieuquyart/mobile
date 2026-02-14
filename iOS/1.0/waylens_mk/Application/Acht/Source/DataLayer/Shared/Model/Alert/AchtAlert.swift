//
//  AchtAlert.swift
//  Acht
//
//  Created by gliu on 8/23/16.
//  Copyright © 2016 waylens. All rights reserved.
//

import Foundation
import CoreLocation

enum AchtAlertType : String {
    case parkingMotion = "parking_motion"
    case parkingHit = "parking_hit"
    case drivingHit = "driving_hit"
    case parkingHeavy = "parking_heavy_hit"
    case drivingHeavy = "driving_heavy_hit"
    case unknown
    
    init(raw: String) {
        self = AchtAlertType(rawValue: raw.lowercased()) ?? .unknown
    }
    
    var color: UIColor {
        switch self {
        case .parkingMotion:
            return UIColor.semanticColor(.activity(.motion))
        case .drivingHit, .parkingHit:
            return UIColor.semanticColor(.activity(.hit))
        case .drivingHeavy, .parkingHeavy:
            return UIColor.semanticColor(.activity(.heavy))
        default:
            return .clear
        }
    }
    
    var displayName: String {
        switch self {
        case .parkingMotion:
            return NSLocalizedString("Motion", comment: "Motion")
        case .drivingHit, .parkingHit:
            return NSLocalizedString("Bump", comment: "Bump")
        case .drivingHeavy, .parkingHeavy:
            return NSLocalizedString("Impact", comment: "Impact")
        default:
            return NSLocalizedString("Unknown", comment: "Unknown")
        }
    }
}

enum VideoUploadStatus: String {
    case preparing = "preparing"
    case streaming = "streaming"
    case streamingFailed = "streaming_failed"
    case uploading = "video_uploading"
    case uploadingFailed = "upload_failed"
    case finished = "finish"
    
    var isUploading: Bool {
        switch self {
        case .preparing, .streaming, .uploading:
            return true
        default:
            return false
        }
    }
}

class AchtAlert {
    var alertID: Int64
    var videoUrl: String
    var thumbnailUrl : String
    #if FLEET
    var eventType : HNVideoType
    #else
    var alertType : AchtAlertType
    #endif
    var cameraID : String
    var createTime: Date
    var isRead : Bool
    var sender : String
    var location: WLLocation?
    var duration: TimeInterval
    var uploadStatus: VideoUploadStatus?
    var hasVideo: Bool
    var facedown: Bool = false // TODO: to be implemented
    var needDewarp : Bool = true // todo
    init(dict : Dictionary<String, Any>) {
        #if FLEET
        alertID = dict["momentID"] as! Int64
        cameraID = dict["cameraSN"] as! String
        sender = dict["cameraSN"] as! String

        if let value = dict["eventType"] as? String {
            eventType = HNVideoType.from(string: value)
        } else {
            eventType = .manual
        }

        videoUrl = dict["mp4Url"] as! String
        thumbnailUrl = (dict["thumbnail"] as? String) ?? ""
        createTime = Date(timeIntervalSince1970: (dict["startTime"] as! TimeInterval) / 1000)
        isRead = (dict["isRead"] as? Bool) ?? true
        duration = (dict["duration"] as? TimeInterval ?? 0) / 1000
        hasVideo = true
        facedown = (dict["rotate"] as? String) == CameraInstallationMode.lensDown.toParameterValue()
        #else
        alertID = dict["eventID"] as! Int64
        cameraID = dict["sn"] as! String
        sender = dict["cameraName"] as! String
        if let gps = dict["gps"] as? [String: Any], let address = dict["location"] as? [String: Any] {
            location = WLLocation(coordinate: gps, address: address)
        }
        alertType = AchtAlertType(raw: dict["alertType"] as! String)
        videoUrl = dict["url"] as! String
        thumbnailUrl = dict["thumbnail"] as! String
        createTime = Date(timeIntervalSince1970: (dict["alertTime"] as! TimeInterval) / 1000)
        isRead = dict["isRead"] as! Bool
        duration = (dict["durationMs"] as? TimeInterval ?? 0) / 1000
        if let value = dict["status"] as? String {
            uploadStatus = VideoUploadStatus(rawValue: value)
        }
        hasVideo = (dict["mediaType"] as! String) == "video"
        facedown = (dict["rotate"] as? String) == CameraInstallationMode.lensDown.toParameterValue()
        #endif
    }
    
    func read(completion:completionBlock?=nil) {
        isRead = true
        WaylensClientS.shared.readAlert(alertID, completion: completion)
    }
    
    func remove(completion:completionBlock?=nil) {
        WaylensClientS.shared.deleteAlert(alertID, completion: completion)
    }
}

extension Array where Element == AchtAlert {
    
    var uploadingAlerts: [AchtAlert] {
        return filter{$0.uploadStatus?.isUploading == true}
    }
    
    var hasUploadingAlerts: Bool {
        return contains(where: { (alert) -> Bool in
            return alert.uploadStatus?.isUploading == true
        })
    }
    
    func indexOfAlert(_ alert: AchtAlert) -> Int? {
        return firstIndex(where: {$0.alertID == alert.alertID})
    }
    
}
