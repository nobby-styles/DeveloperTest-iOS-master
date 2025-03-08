//
//  DataCacheService.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 08/03/2025./  Created on 07/03/2025.
//

import Foundation

// Generic cache protocol
public protocol CacheService {
    func get<T>(for key: String) -> T?
    func set<T>(value: T, for key: String)
    func clear(key: String)
    func clearAll()
}

// In-memory cache implementation using NSCache
public class InMemoryCache: CacheService {
    private let cache = NSCache<NSString, AnyObject>()
    
    // Singleton instance
    public static let shared = InMemoryCache()
    
    private init() {
        // Configure NSCache defaults
        cache.name = "AtomicMediaDeveloperCache"
        // Optional: Set limits if needed
        // cache.countLimit = 100
        // cache.totalCostLimit = 50_000_000 // ~50MB
    }
    
    public func get<T>(for key: String) -> T? {
        return cache.object(forKey: key as NSString) as? T
    }
    
    public func set<T>(value: T, for key: String) {
        // NSCache only accepts AnyObject, so we need to ensure the value is an object
        guard let value = value as? AnyObject else {
            print("Warning: Could not cache value for key \(key). Value must be a reference type.")
            return
        }
        
        cache.setObject(value, forKey: key as NSString)
    }
    
    public func clear(key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    public func clearAll() {
        cache.removeAllObjects()
    }
}

// Cache keys
public enum CacheKeys {
    static let headlines = "headlines_cache"
    static func story(id: Int) -> String { "story_cache_\(id)" }
}
