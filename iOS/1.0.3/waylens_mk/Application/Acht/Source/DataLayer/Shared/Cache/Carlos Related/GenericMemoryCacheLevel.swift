//
//  GenericMemoryCacheLevel.swift
//  Acht
//
//  Created by Chester Shen on 1/4/18.
//  Copyright © 2018 waylens. All rights reserved.
//

import Foundation
import WaylensPiedPiper
import WaylensCarlos
import WaylensFoundation

class MemoryCache {
    // TODO: add cost management
    var totalCostLimit: Int = 0
    private var cache: [String: Any]
    init() {
        cache = [String: Any]()
    }
    
    func get(_ key: String) -> Any? {
        return cache[key]
    }
    
    func set(_ value: Any, forKey key: String, cost: Int=1) {
        cache[key] = value
    }
    
    func removeAll() {
        cache.removeAll()
    }
}

/// This class is a memory cache level. It internally uses MemoryCache, and has a configurable total cost limit that defaults to 50 MB.
public final class GenericMemoryCacheLevel<K: StringConvertible, T: Any>: CacheLevel {
    /// At the moment the memory cache level only accepts String keys
    public typealias KeyType = K
    public typealias OutputType = T
    
    private let internalCache: MemoryCache
    /**
     Initializes a new memory cache level
     
     - parameter cost: The total cost limit for the memory cache. Defaults to 50 MB
     */
    public init(capacity: Int = 50 * 1024 * 1024) {
        internalCache = MemoryCache()
        internalCache.totalCostLimit = capacity
    }
    
    /**
     Synchronously gets a value for the given key
     
     - parameter key: The key for the value
     
     - returns: A Future where you can call onSuccess and onFailure to be notified of the result of the fetch
     */
    public func get(_ key: KeyType) -> Future<OutputType> {
        let request = Promise<T>()
        
        if let result = internalCache.get(key.toString()) as? T {
            Log.verbose("Hit \(key.toString()) on generic memory cache")
            request.succeed(result)
        } else {
            Log.verbose("Miss \(key.toString()) on the generic memory cache")
            request.fail(FetchError.valueNotInCache)
        }
        
        return request.future
    }
    
    /**
     Clears the contents of the cache
     */
    public func onMemoryWarning() {
//        clear()
    }
    
    /**
     Sets a value for the given key
     
     - parameter value: The value to set
     - parameter key: The key for the value
     */
    public func set(_ value: T, forKey key: K) -> Future<()> {
        Log.verbose("Setting a value for the key \(key.toString()) on generic memory cache \(self)")
        let cost = (value as? ExpensiveObject)?.cost ?? 1
        internalCache.set(value, forKey: key.toString(), cost: cost)
        return Future(())
    }
    
    /**
     Clears the contents of the cache
     */
    public func clear() {
        internalCache.removeAll()
    }
}

