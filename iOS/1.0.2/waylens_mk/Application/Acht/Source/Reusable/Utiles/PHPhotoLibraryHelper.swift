//
//  PHPhotoLibraryHelper.swift
//  Acht
//
//  Created by Chester Shen on 11/17/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
import Photos
import WaylensFoundation

enum PhotoError: Error {
    case saveAssetError
    case createAlbumError
    case assetNotFound
//    case
}
public extension PHPhotoLibrary {
    typealias PhotoAsset = PHAsset
    typealias PhotoAlbum = PHAssetCollection
    
    static func saveImage(image: UIImage, albumName: String, completion: @escaping (PHAsset?, Error?)->Void) {
        if let album = self.findAlbum(albumName) {
            saveImage(image, album: album, completion: completion)
            return
        }
        createAlbum(albumName) { album, error in
            if let album = album {
                self.saveImage(image, album: album, completion: completion)
            } else {
                assert(false, "Album is nil")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    static func saveVideo(videoUrl: URL, albumName: String, completion: @escaping (PHAsset?, Error?)->Void) {
        if let album = self.findAlbum(albumName) {
            saveVideo(videoUrl, album: album, completion: completion)
            return
        }
        createAlbum(albumName) { album, error in
            if let album = album {
                self.saveVideo(videoUrl, album: album, completion: completion)
            } else {
                assert(false, "Album is nil")
                DispatchQueue.main.async {
                    completion(nil, error ?? PhotoError.saveAssetError)
                }
            }
        }
    }
    
    static private func saveImage(_ image: UIImage, album: PhotoAlbum, completion: @escaping (PHAsset?, Error?)->Void) {
        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            // Request creating an asset from the image
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            // Request editing the album
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) else {
                assert(false, "Album change request failed")
                return
            }
            // Get a placeholder for the new asset and add it to the album editing request
            guard let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset else {
                assert(false, "Placeholder is nil")
                return
            }
            placeholder = photoPlaceholder
            albumChangeRequest.addAssets([photoPlaceholder] as NSArray)
        }, completionHandler: { success, error in
            guard let placeholder = placeholder else {
                assert(false, "Placeholder is nil")
                DispatchQueue.main.async {
                    completion(nil, PhotoError.saveAssetError)
                }
                return
            }
            DispatchQueue.main.async {
                if success {
                    completion(getAsset(identifier: placeholder.localIdentifier), nil)
                } else {
                    completion(nil, PhotoError.saveAssetError)
                }
            }
        })
    }
    
    static private func saveVideo(_ videoUrl: URL, album: PhotoAlbum, completion: @escaping (PHAsset?, Error?)->Void) {
        
        var placeholder: PHObjectPlaceholder?
        
        PHPhotoLibrary.shared().performChanges({
            
            // Request creating an asset from the image
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
            // Request editing the album
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) else {
                assert(false, "Album change request failed")
                return
            }
            
            // Get a placeholder for the new asset and add it to the album editing request
            guard let videoPlaceholder = createAssetRequest!.placeholderForCreatedAsset else {
                assert(false, "Placeholder is nil")
                return
            }
            
            placeholder = videoPlaceholder
            
            albumChangeRequest.addAssets([videoPlaceholder] as NSArray)
        }, completionHandler: { success, error in
            guard let placeholder = placeholder else {
                assert(false, "Placeholder is nil")
                DispatchQueue.main.async {
                    completion(nil, error ?? PhotoError.saveAssetError)
                }
                return
            }
            DispatchQueue.main.async {
                if success {
                    completion(getAsset(identifier:placeholder.localIdentifier), nil)
                }
                else {
                    completion(nil, error ?? PhotoError.saveAssetError)
                }
            }
        })
    }
    
    
    static func findAlbum(_ albumName: String) -> PhotoAlbum? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions)
        guard let photoAlbum = fetchResult.firstObject else {
            return nil
        }
        return photoAlbum
    }
    
    static func createAlbum(_ albumName: String, completion: @escaping (PhotoAlbum?, Error?)->Void) {
        var albumPlaceholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            // Request creating an album with parameter name
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            // Get a placeholder for the new album
            albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in
            Log.info("Create photo collection, success:\(success), id:\(albumPlaceholder?.localIdentifier ?? "")")
            if success, let placeholder = albumPlaceholder {
                let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                guard let album = fetchResult.firstObject else {
                    Log.error("FetchResult has no PHAssetCollection")
                    assert(false, "FetchResult has no PHAssetCollection")
                    DispatchQueue.main.async {
                        completion(nil, PhotoError.createAlbumError)
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(album, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, error ?? PhotoError.createAlbumError)
                }
            }
        })
    }
    
    static func getAsset(identifier: String, options: PHFetchOptions?=nil) -> PHAsset? {
        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: options).lastObject {
            return asset
        }
        return nil
    }
    
    static func removeAsset(identifier: String, completion: @escaping (Bool, Error?)->Void) {
        if let asset = getAsset(identifier: identifier) {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([asset] as NSArray)
            }, completionHandler: completion)
        } else {
            completion(false, PhotoError.assetNotFound)
        }
    }
    
    static func getImage(identifier: String, size:CGSize? = nil, completion: @escaping (UIImage?, Error?)->Void) {
        guard let asset = getAsset(identifier: identifier), asset.mediaType == .video else {
            completion(nil, PhotoError.assetNotFound)
            return
        }
        PHImageManager.default().requestImage(for: asset, targetSize: size ?? PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil, resultHandler: { result, info in
            DispatchQueue.main.async {
                completion(result, nil)
            }
        })
    }
    
    static func getVideoFileURL(identifier: String, completion: @escaping (URL?, Error?)->Void) {
        guard let asset = getAsset(identifier: identifier), asset.mediaType == .video else {
            completion(nil, PhotoError.assetNotFound)
            return
        }
        let options = PHVideoRequestOptions()
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, avAudioMix, info) in
            let urlAsset = avAsset as! AVURLAsset
            DispatchQueue.main.async {
                completion(urlAsset.url, nil)
            }
        }
    }
    
    static func getVideo(identifier: String, completion: @escaping (AVURLAsset?, Error?)->Void) {
        guard let asset = getAsset(identifier: identifier), asset.mediaType == .video else {
            completion(nil, PhotoError.assetNotFound)
            return
        }
        let options = PHVideoRequestOptions()
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (avAsset, avAudioMix, info) in
            DispatchQueue.main.async {
                completion(avAsset as? AVURLAsset, nil)
            }
        }
    }
}
