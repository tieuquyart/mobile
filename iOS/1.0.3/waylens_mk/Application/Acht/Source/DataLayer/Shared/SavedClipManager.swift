//
//  SavedClipManager.swift
//  Acht
//
//  Created by Chester Shen on 9/22/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
import Photos
import WaylensFoundation

#if FLEET
let HornAlbumName = "Waylens Fleet"
#else
let HornAlbumName = "Waylens Secure360"
#endif

protocol SavedClipManagerDelegate:NSObjectProtocol {
    func clipListDidReload()
    func clipDidUpdate(_ clip:SavedClip)
}

class SavedClip: HNClip {
    var videoName: String?
    var thumbnailName: String?
    var phIdentifier: String?
    override var thumbnailUrl: String? {
        get {
            if let name = thumbnailName, let dir = SavedClipManager.videoDirectoryPath {
                return dir.appendingPathComponent(name).path
            }
            return nil
        }
        set {}
    }
    var thumbnailImage: UIImage?
    var toBeRemoved: Bool = false
    var streamIndex = Int32(0)
    
    var indicatorColor: UIColor {
        #if FLEET
        return videoType.color
        #else
        switch videoType {
        case .parkingMotion:
            return UIColor.semanticColor(.activity(.motion))
        case .drivingHit, .parkingHit, .hardAccel, .hardBrake, .sharpTurn, .harshAccel, .harshBrake, .harshTurn, .severeAccel, .severeBrake, .severeTurn:
            return UIColor.semanticColor(.activity(.hit))
        case .drivingHeavy, .parkingHeavy:
            return UIColor.semanticColor(.activity(.heavy))
        case .manual:
            return UIColor.semanticColor(.activity(.manual))
        default:
            return UIColor.semanticColor(.activity(.buffered))
        }
        #endif
    }
    
    override init(dict: [String : Any]) {
        super.init(dict: dict)
        videoName = dict["videoName"] as? String
        thumbnailName = dict["thumbnailName"] as? String
        phIdentifier = dict["phIdentifier"] as? String
        streamIndex = Int32(dict["streamIndex"] as? String ?? "0") ?? 0
    }
    init(dict: [String : Any], index: Int32) {
        super.init(dict: dict)
        videoName = dict["videoName"] as? String
        thumbnailName = dict["thumbnailName"] as? String
        phIdentifier = dict["phIdentifier"] as? String
        streamIndex = index
    }
    
    override func toDict() -> [String : Any] {
        var d = super.toDict()
        d["videoName"] = videoName
        d["thumbnailName"] = thumbnailName
        d["phIdentifier"] = phIdentifier
        d["streamIndex"] = String(streamIndex)
        return d
    }
}

class SavedClipManager {
    static let shared = SavedClipManager()
    static let savedVideoDirectory = "Waylens360Raw"
    static let savedClipDataFile = "saved_clips"
    var clips: [SavedClip]?
    weak var delegate: SavedClipManagerDelegate?
    var validClips: [SavedClip] {
        guard let clips = clips else {
            return []
        }
        let filtered = clips.filter { !$0.toBeRemoved }
        return filtered
    }
    static var clipDataPath: URL? {
        guard let root = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return nil }
        return URL(fileURLWithPath: root).appendingPathComponent(savedClipDataFile)
    }
    
    static var videoDirectoryPath: URL? {
        guard let root = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return nil }
        return URL(fileURLWithPath: root).appendingPathComponent(savedVideoDirectory, isDirectory: true)
    }
    
    init() {
        load()
    }
    
    func checkDirectoryExists(path: URL) -> Bool {
        if !FileManager.default.fileExists(atPath: path.path) {
            do {
                try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
            } catch {
                Log.error("Create directory failed:\(error)")
                return false
            }
        }
        return true
    }
    
    func load() {
        guard let path = SavedClipManager.clipDataPath, let dirPath = SavedClipManager.videoDirectoryPath else { return }
        _ = checkDirectoryExists(path: dirPath)
        if FileManager.default.fileExists(atPath: path.path) {
            do {
                let data = try Data(contentsOf: path)
                clips = try (JSONSerialization.jsonObject(with: data) as! [[String:Any]]).map({SavedClip(dict:$0)}).filter({ $0.phIdentifier != nil || $0.videoName != nil})
            } catch {
                Log.error("load clips failure: \(error)")
            }
        }
        sortClips()
        guard let clips = clips else { return }
        clips.forEach { (clip) in
            readAssetFromClip(clip, completion: { (asset) in
                if let asset = asset {
                    if self.updateClip(clip, asset: asset) {
                        self.delegate?.clipDidUpdate(clip)
                        self.save()
                    }
                } else {
                    clip.toBeRemoved = true
                }
            })
        }
        self.delegate?.clipListDidReload()
        
        // TODO: clean these stuff
        let indexedVideoFiles = clips.filter({ $0.videoName != nil }).map({ $0.videoName! + ".mp4"})
        let indexedImageFiles = clips.filter({ $0.thumbnailName != nil }).map({ $0.thumbnailName! })
        do {
            let paths = try FileManager.default.contentsOfDirectory(atPath: dirPath.path)
            let videoFiles = paths.filter({$0.contains(".mp4")})
            let imageFiles = paths.filter({ $0.contains(".png")})
            // remove unindexed videos
            for videoFile in videoFiles {
                if indexedVideoFiles.firstIndex(of:videoFile) == nil {
                    let fullPath = dirPath.appendingPathComponent(videoFile)
                    try FileManager.default.removeItem(atPath: fullPath.path)
                }
            }
            // remove unindexed images
            for imageFile in imageFiles {
                if indexedImageFiles.firstIndex(of: imageFile) == nil {
                    let fullPath = dirPath.appendingPathComponent(imageFile)
                    try FileManager.default.removeItem(atPath: fullPath.path)
                }
            }
        } catch {
            Log.error("Remove unwanted videos failure: \(error)")
        }
    }
    
    func save() {
        guard let path = SavedClipManager.clipDataPath else { return }
        do {
            let list = validClips.map({ $0.toDict()})
            let data = try JSONSerialization.data(withJSONObject: list)
            try data.write(to: path)
        } catch {
            Log.error("save clips failure: \(error)")
        }
    }
    
    private func sortClips() {
        clips?.sort(by:{ (a, b) -> Bool in
        return a.startDate > b.startDate
        })
    }

    func readAssetFromClip(_ clip:SavedClip,  completion:@escaping ((AVURLAsset?)->Void)) {
        if let id = clip.phIdentifier {
            PHPhotoLibrary.getVideo(identifier: id, completion: { (videoAsset, error) in
                completion(videoAsset)
            })
        } else if let videoName = clip.videoName, let dirPath = SavedClipManager.videoDirectoryPath {
            let destination = dirPath.appendingPathComponent(videoName + ".mp4")
            let videoAsset = AVURLAsset(url: destination)
            completion(videoAsset)
        } else {
            completion(nil)
        }
    }
    
    func moveVideo(from videoUrl: URL, toLibrary: Bool, clip: BasicClip, streamIndex: Int32, completion: @escaping ((Bool, SavedClip?)->Void)) {
        let toSave = SavedClip(dict: clip.toDict(), index: streamIndex)
        if toLibrary {
            PHPhotoLibrary.saveVideo(videoUrl: videoUrl, albumName: HornAlbumName) { (asset, error) in
                if let asset = asset {
                    try? FileManager.default.removeItem(at: videoUrl)
                    toSave.phIdentifier = asset.localIdentifier
                    PHPhotoLibrary.getVideo(identifier: asset.localIdentifier, completion: { (avasset, error) in
                        if let avasset = avasset {
                            self.saveClip(toSave, asset: avasset)
                            completion(true, toSave)
                        } else {
                            Log.error("Failed to get video with ID \(asset.localIdentifier) for clip \(clip.clipID), error: \(error?.localizedDescription ?? "")")
                            completion(false, nil)
                        }
                    })
                } else {
                    Log.error("Failed to save video at \(videoUrl) for clip \(clip.clipID), error: \(error?.localizedDescription ?? "")")
                    completion(false, nil)
                }
            }
        } else if let dirPath = SavedClipManager.videoDirectoryPath, checkDirectoryExists(path: dirPath) {
            let videoName = videoNameFor(clip: clip, index: streamIndex)
            var destination = dirPath.appendingPathComponent(videoName + ".mp4")
            var c: Int = 0
            while FileManager.default.fileExists(atPath: destination.path) {
                c += 1
                destination = dirPath.appendingPathComponent("\(videoName)_\(c).mp4")
            }
            do {
                try FileManager.default.moveItem(at: videoUrl, to: destination)
            } catch {
                Log.error("Move file failed:\(error)")
                completion(false, nil)
            }
            toSave.videoName = videoName
            let avasset = AVURLAsset(url: destination)
            saveClip(toSave, asset: avasset)
            completion(true, toSave)
        } else {
            completion(false, nil)
        }
    }
    
    private func videoNameFor(clip: BasicClip, index: Int32) -> String {
        return "Secure360_\(clip.startDate.toString(format: .dateTimeSec))_\(Int(clip.duration * 1000))_\(index)"
    }
    
    private func thumbnailURLfor(clip: SavedClip) -> URL {
        let key: String!
        if let id = clip.phIdentifier {
            key = (id as NSString).md5Encrypt()
        } else {
            key = clip.videoName
        }
        return SavedClipManager.videoDirectoryPath!.appendingPathComponent(key + ".png")
    }
    
    private func updateClip(_ clip: SavedClip, asset: AVURLAsset) -> Bool {
        var thumbnailUpdated = false
        if let thumbnailUrl = clip.thumbnailUrl, FileManager.default.fileExists(atPath: thumbnailUrl) {
            // pass
        } else {
            let thumbnailUrl = thumbnailURLfor(clip: clip)
            if let _ = saveThumbnail(forVideo: asset, at: thumbnailUrl) {
                clip.thumbnailName = thumbnailUrl.lastPathComponent
                thumbnailUpdated = true
            }
        }
        clip.duration = asset.duration.seconds
        clip.url = asset.url.path
        return thumbnailUpdated
    }
    
    private func saveClip(_ clip: SavedClip, asset: AVURLAsset) {
        _ = updateClip(clip, asset: asset)
        if clips == nil {
            clips = []
        }
        clips?.append(clip)
        sortClips()
        save()
        self.delegate?.clipListDidReload()
    }
    
    func removeClip(_ clip: SavedClip) {
        guard let index = clips?.firstIndex(of: clip) else { return }
        clips?.remove(at: index)
        save()
        load()
        if let identifier = clip.phIdentifier {
            PHPhotoLibrary.removeAsset(identifier: identifier, completion: { (success, error) in
                if success {
                    Log.info("Video \(clip.clipID) removed from photo library")
                } else {
                    Log.error("Fail to remove video \(clip.clipID): \(String(describing: error?.localizedDescription))")
                }
            })
        }
    }
    
    func findClip(forClip clip: BasicClip, index: Int32) -> SavedClip? {
        return clips?.first(where: {$0.isIdenticalTo(clip) && ($0.streamIndex == index)})
    }
    
    func clipIsSaved(_ clip: BasicClip, index: Int32) -> Bool {
        return findClip(forClip: clip, index: index) != nil
    }

    func saveThumbnail(forVideo asset: AVAsset, at thumbnailURL:URL) -> UIImage? {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let sampleTime = max(0, min(5, asset.duration.seconds - 1))
        let time = CMTimeMakeWithSeconds(Float64(sampleTime), preferredTimescale: 100)
        do {
            let img = try generator.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            guard let thumbnailData = thumbnail.pngData() else { return nil}
            try thumbnailData.write(to: thumbnailURL)
            return thumbnail
        } catch {
            Log.error("save thumbnail failed:\(error)")
            return nil
        }
    }
}
