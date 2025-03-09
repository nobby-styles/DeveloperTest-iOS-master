//
//  CachedHeadlineRepository.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 08/03/2025.
//

import Foundation
import API

// Repository with cache implementation for Headlines
public class CachedHeadlineRepository: HeadlineRepository {
    private let api: API
    private let cache: CacheService
    
    public init(api: API, cache: CacheService = InMemoryCache.shared) {
        self.api = api
        self.cache = cache
    }
    
    public func getHeadlines() async throws -> [Headline] {
        do {
            // Try to fetch from API first
            let headlinesDto = try await api.getHeadlines()
            
            // Convert to domain model
            let headlines = headlinesDto.map { mapToDomain($0) }
            
            // Cache the successful result
             cache.set(value: headlines, for: CacheKeys.headlines)

            return headlines
        } catch {
            // If API call fails, try to get from cache
            if let cachedHeadlines: [Headline] = cache.get(for: CacheKeys.headlines) {
                // Log that we're using cached data
                print("Using cached headlines due to API error: \(error.localizedDescription)")
                return cachedHeadlines
            }
            
            // If no cache available, re-throw the error
            throw error
        }
    }
    
    private func mapToDomain(_ dto: HeadlineDto) -> Headline {
        return Headline(
            id: dto.id,
            title: dto.title,
            author: dto.author
        )
    }
}
