//
//  ThumbnailFetcher.swift
//  Acht
//
//  Created by Chester Shen on 1/4/18.
//  Copyright © 2018 waylens. All rights reserved.
//
import WaylensCarlos
import WaylensPiedPiper
import AlamofireImage
import WaylensCameraSDK
import WaylensVideoSDK

protocol ResizedImage: StringConvertible {
    func keyForOriginalImage() -> Any
    func needDewarp() -> Bool
    var facedown: Bool { get }
    var targetSize: CGSize { get }
}

struct ThumbnailCacheRequest: ResizedImage {
    let rawRequest: VDBThumbnailRequest
    let targetSize: CGSize
    var facedown: Bool {
        return rawRequest.clip.isRotated
    }
    func toString() -> String {
        let width = Int64(targetSize.width.rounded())
        return "\(rawRequest.getKey())_w\(width)_f\(facedown ? 1 : 0)"
    }
    
    func keyForOriginalImage() -> Any {
        return rawRequest
    }

    func needDewarp() -> Bool {
        if rawRequest.clip != nil  {
            return rawRequest.clip.needDewarp
        }
        return UnifiedCameraManager.shared.cameraForSN(rawRequest.cameraID)?.needDewarp ?? false
    }
}

struct ImageCacheRequest: ResizedImage {
    let url: URL
    let targetSize: CGSize
    let facedown: Bool
    let dewarp: Bool
    init(url: URL, targetSize: CGSize, facedown: Bool=false, dewarp:Bool=true) {
        self.url = url
        self.targetSize = targetSize
        self.facedown = facedown
        self.dewarp = dewarp
    }
    
    func toString() -> String {
        let width = Int64(targetSize.width.rounded())
        return "\(url.absoluteString)_w\(width)_f\(facedown)"
    }
    
    func keyForOriginalImage() -> Any {
        return url
    }

    func needDewarp() -> Bool {
        return dewarp
    }
}

class ImageFetcher: Fetcher {
    typealias KeyType = URL
    typealias OutputType = UIImage
//    let queue = DispatchQueue(label: "com.waylens.acht.imagefetcher")
    func get(_ key: URL) -> Future<UIImage> {
        let promise = Promise<UIImage>()
        if key.isFileURL { // from local file
//            queue.async {
                if let data = try? Data(contentsOf: key), let image = UIImage(data: data) {
                    promise.succeed(image)
                } else {
                    promise.fail(FetchError.valueNotInCache)
                }
//            }
        } else { // from network
            let request = URLRequest(url: key)
            let receipt = ImageDownloader.default.download(request) { (response) in
                if let image = response.result.value {
                    promise.succeed(image)
                } else {
                    promise.fail(FetchError.valueNotInCache)
                }
            }
            promise.onCancel {
                receipt?.request.cancel()
            }
        }
        return promise.future
    }
}

extension CacheLevel where KeyType: ResizedImage, OutputType == UIImage {
    func composeAndDewarpImage<A: CacheLevel>(_ cache: A) -> BasicCache<KeyType, A.OutputType> where A.OutputType == OutputType {
        return BasicCache(
            getClosure: { key in
                let request = Promise<A.OutputType>()
                self.get(key)
                    .onSuccess(request.succeed)
                    .onCancel(request.cancel)
                    .onFailure { error in
                        if let imageKey = key.keyForOriginalImage() as? A.KeyType {
                            _ = request.mimic(cache.get(imageKey).flatMap { (result) -> Future<UIImage> in
                                // dewarping
                                let promise = Promise<UIImage>()
                                if key.needDewarp() == false {
                                    promise.succeed(result)
                                    self.set(result, forKey: key)
                                } else {
                                    ImageDewarper.shared.processImage(result, width: key.targetSize.width, facedown: key.facedown, completion: { (image) in
                                        if let image = image {
                                            promise.succeed(image)
                                            self.set(image, forKey: key)
                                        } else {
                                            promise.fail(FetchError.valueTransformationFailed)
                                        }
                                    })
                                }
                                // TODO: cancel dewarping operation in queue on Cancel
                                return promise.future
                            })
                        } else {
                            request.fail(error)
                        }
                }
                return request.future
        },
            setClosure: { (value, key) in
                let firstWrite = self.set(value, forKey: key)
//                let secondWrite = cache.set(value, forKey: key)
                return firstWrite
        },
            clearClosure: {
                self.clear()
                cache.clear()
        },
            memoryClosure: {
                self.onMemoryWarning()
                cache.onMemoryWarning()
        }
        )
    }
}

class ThumbnailFetcher: Fetcher {
    typealias KeyType = VDBThumbnailRequest
    typealias OutputType = UIImage
    
    func get(_ request: KeyType) -> Future<OutputType> {
        let promise = Promise<UIImage>()
        if let vdbManager = UnifiedCameraManager.shared.cameraForSN(request.cameraID)?.local?.vdbManager {
            let vdbRequest = vdbManager.getThumbnail(forClip: request.clip, atTime: request.pts, ignorable: false, completion: { (result) in
                if result.isSuccess, let thumbnail = result.value as? WLVDBThumbnail, let image = UIImage(data: thumbnail.imageData) {
                    DispatchQueue.main.async {
                        promise.succeed(image)
                    }
                } else {
                    DispatchQueue.main.async {
                        promise.fail(FetchError.valueNotInCache)
                    }
                }
            })
            promise.onCancel {
                vdbRequest.cancel()
            }
        } else {
            DispatchQueue.main.async {
                promise.fail(FetchError.noCacheLevelsRemaining)
            }
        }
        return promise.future
    }
}
