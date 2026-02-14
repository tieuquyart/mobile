//
//  CacheManager.swift
//  Acht
//
//  Created by Chester Shen on 12/27/17.
//  Copyright © 2017 waylens. All rights reserved.
//
import WaylensCarlos
import WaylensPiedPiper
import CoreLocation

extension CacheLevel {
    public func pipe<A: CacheLevel>(_ cache: A) -> BasicFetcher<KeyType, A.OutputType> where A.KeyType == OutputType {
        return BasicFetcher(getClosure: { key in
            return self.get(key)
                .flatMap(cache.get)
        })
    }
}

class CacheManager {
    static let shared = CacheManager()
    let thumbnailCache: BasicCache<ThumbnailCacheRequest, UIImage>
    let locationCache: PoolCache<BasicCache<CLLocationCoordinate2D, WLLocation>>
    let gpsCache: BasicCache<GPSCacheRequest, CLLocation>
    let imageCache: BasicCache<ImageCacheRequest, UIImage>
    let imageFetcher = ImageFetcher()
    
    init() {
        Logger.output = { (msg, level) in
//            switch level {
//            case .Debug:
//                Log.verbose(msg)
//            case .Info:
//                Log.verbose(msg)
//            case .Warning:
//                Log.info(msg)
//            case .Error:
//                Log.warn(msg)
//            default:
//                break
//            }
        }
        thumbnailCache = MemoryCacheLevel<ThumbnailCacheRequest, UIImage>().composeAndDewarpImage(ThumbnailFetcher())
        imageCache = MemoryCacheLevel<ImageCacheRequest, UIImage>().composeAndDewarpImage(imageFetcher)
        locationCache = GenericMemoryCacheLevel<CLLocationCoordinate2D, WLLocation>().compose(LocationFetcher()).pooled()
        gpsCache = GenericMemoryCacheLevel<GPSCacheRequest, CLLocation>().compose(GPSFetcher())
    }
    
    func clear() {
        thumbnailCache.clear()
        imageCache.clear()
        locationCache.clear()
        gpsCache.clear()
    }
}


