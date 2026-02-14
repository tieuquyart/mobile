//
//  VDBImageCache.swift
//  Acht
//
//  Created by Chester Shen on 9/6/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import Foundation
import AlamofireImage
import WaylensCameraSDK

struct VDBThumbnailRequest {
    var cameraID: String
    var clip: WLVDBClip
    var pts: TimeInterval
    var ptsInMs: Int64 {
        return Int64(pts * 1000)
    }
    var cache: Bool = true
    var ignorable: Bool = false
    func getKey() -> String {
        return "\(clip.uuid)-\(ptsInMs)"
    }
}

//protocol VDBThumbnailRequestCache: ImageCache {
//    /// Adds the image to the cache using an identifier created from the request and identifier.
//    func add(_ image: Image, for request: VDBThumbnailRequest, withIdentifier identifier: String?)
//    
//    /// Removes the image from the cache using an identifier created from the request and identifier.
//    func removeImage(for request: VDBThumbnailRequest, withIdentifier identifier: String?) -> Bool
//    
//    /// Returns the image from the cache associated with an identifier created from the request and identifier.
//    func image(for request: VDBThumbnailRequest, withIdentifier identifier: String?) -> Image?
//}

class VDBImageCache: AutoPurgingImageCache {
    /// Adds the image to the cache using an identifier created from the request and optional identifier.
    ///
    /// - parameter image:      The image to add to the cache.
    /// - parameter request:    The request used to generate the image's unique identifier.
    /// - parameter identifier: The additional identifier to append to the image's unique identifier.
    func add(_ image: Image, for request: VDBThumbnailRequest, withIdentifier identifier: String? = nil) {
        let requestIdentifier = imageCacheKey(for: request, withIdentifier: identifier)
        add(image, withIdentifier: requestIdentifier)
    }
    
    /// Removes the image from the cache using an identifier created from the request and optional identifier.
    ///
    /// - parameter request:    The request used to generate the image's unique identifier.
    /// - parameter identifier: The additional identifier to append to the image's unique identifier.
    ///
    /// - returns: `true` if the image was removed, `false` otherwise.
    @discardableResult
    func removeImage(for request: VDBThumbnailRequest, withIdentifier identifier: String?) -> Bool {
        let requestIdentifier = imageCacheKey(for: request, withIdentifier: identifier)
        return removeImage(withIdentifier: requestIdentifier)
    }
    
    
    /// Returns the image from the cache associated with an identifier created from the request and optional identifier.
    ///
    /// - parameter request:    The request used to generate the image's unique identifier.
    /// - parameter identifier: The additional identifier to append to the image's unique identifier.
    ///
    /// - returns: The image if it is stored in the cache, `nil` otherwise.
    func image(for request: VDBThumbnailRequest, withIdentifier identifier: String? = nil) -> Image? {
        let requestIdentifier = imageCacheKey(for: request, withIdentifier: identifier)
        return image(withIdentifier: requestIdentifier)
    }
    
    // MARK: Image Cache Keys
    
    /// Returns the unique image cache key for the specified request and additional identifier.
    ///
    /// - parameter request:    The request.
    /// - parameter identifier: The additional identifier.
    ///
    /// - returns: The unique image cache key.
    func imageCacheKey(for request: VDBThumbnailRequest, withIdentifier identifier: String?) -> String {
        var key = request.getKey()
        if let identifier = identifier {
            key += "-\(identifier)"
        }
        return key
    }
}
