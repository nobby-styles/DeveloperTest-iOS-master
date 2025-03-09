//
//  CacheService.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 08/03/2025.
//


import Foundation

// Generic cache protocol
public protocol CacheService {
    func get<T>(for key: String) -> T?
    func set<T>(value: T, for key: String)
    func clear(key: String)
    func clearAll()
}

// Internal wrapper class for storing value types in NSCache
private class CacheWrapper<T>: NSObject {
    let value: T
    
    init(value: T) {
        self.value = value
    }
}

// In-memory cache implementation using NSCache
public class InMemoryCache: CacheService {
    private let cache = NSCache<NSString, AnyObject>()
    
    // Singleton instance
    public static let shared = InMemoryCache()
    
    private init() {
        // Configure NSCache defaults
        cache.name = "AtomicMediaDeveloperCache"
    }
    
    public func get<T>(for key: String) -> T? {
        // Try to retrieve the wrapper object
        if let wrapper = cache.object(forKey: key as NSString) as? CacheWrapper<T> {
            return wrapper.value
        }
        return nil
    }
    
    public func set<T>(value: T, for key: String) {
        // Wrap the value regardless of its type
        let wrapper = CacheWrapper(value: value)
        cache.setObject(wrapper, forKey: key as NSString)
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
