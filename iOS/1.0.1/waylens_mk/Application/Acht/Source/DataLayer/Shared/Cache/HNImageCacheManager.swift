//
//  HNImageCacheManager.swift
//  Acht
//
//  Created by Chester Shen on 8/25/17.
//  Copyright © 2017 waylens. All rights reserved.
//

import UIKit
import WaylensPiedPiper
import WaylensFoundation

extension CGSize {
    func toString() -> String {
        let width = Int64(self.width.rounded())
        let height = Int64(self.height.rounded())
        return "size:(\(width)x\(height))"
    }
    
    func scaled() -> CGSize {
        let scale = UIScreen.main.scale
        return self.applying(CGAffineTransform(scaleX: scale, y: scale))
    }
}

extension UIImageView {
    private static var imageFutureKey = "imageFutureKey"
    
    var image_future : Future<UIImage>? {
        get {
            let _future = objc_getAssociatedObject(self, &UIImageView.imageFutureKey) as? Future<UIImage>
            return _future
        }
        set {
            objc_setAssociatedObject(self, &UIImageView.imageFutureKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func hn_setImage(url:URL, facedown:Bool, dewarp:Bool, placeholderImage: UIImage? = nil, animated:Bool = true, completion: (() -> ())? = nil) {
        guard bounds.shorterEdge > 0 else { return }
        let originalWidth = max(self.bounds.size.width, self.bounds.size.height * 16 / 9)
        let targetSize = CGSize(width: originalWidth, height: originalWidth * 9 / 16).scaled()
        let request = ImageCacheRequest(url: url, targetSize: targetSize, facedown: facedown, dewarp: dewarp)
        cancelImageFuture()
        let requestTime = Date()
        image_future = CacheManager.shared.imageCache.get(request)
            .onCompletion({ [weak self] (result) in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let image):
                    if animated && (-requestTime.timeIntervalSinceNow > 0.1) {
                        strongSelf.run(.crossDissolve(0.3), with: image)
                    } else {
                        strongSelf.image = image
                    }
                case .error(_):
                    strongSelf.image = placeholderImage
                    Log.error("Fail to set image")
                default:
                    break
                }
                completion?()
            })
    }
    
    func vdb_setThumbnail(_ request: VDBThumbnailRequest, placeholderImage: UIImage? = nil, animated:Bool = true) {
        guard bounds.shorterEdge > 0 else { return }
        let originalWidth = max(self.bounds.size.width, self.bounds.size.height * 16 / 9)
        let targetSize = CGSize(width: originalWidth, height: originalWidth * 9 / 16).scaled()
        let cacheRequest = ThumbnailCacheRequest(rawRequest: request, targetSize: targetSize)
        cancelImageFuture()
        let requestTime = Date()
        image_future = CacheManager.shared.thumbnailCache.get(cacheRequest)
            .onCompletion { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let image):
                    if animated && (-requestTime.timeIntervalSinceNow > 0.1) {
                        strongSelf.run(.crossDissolve(0.3), with: image)
                    } else {
                        strongSelf.image = image
                    }
                case .error(_):
                    strongSelf.image = placeholderImage
                    Log.error("Fail to set image")
                default:
                    break
                }
        }
    }
    
    func cancelImageFuture() {
        if let future = image_future {
            future.cancel()
            stopAnimating()
            image_future = nil
        }
    }
}
