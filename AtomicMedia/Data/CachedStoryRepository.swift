//
//  CachedStoryRepository.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 08/03/2025.
//


//
//  CachedStoryRepository.swift
//  AtomicMediaDeveloper
//
//  Created on 07/03/2025.
//

import Foundation
import API

// Repository with cache implementation for Stories
public class CachedStoryRepository: StoryRepository {
    private let api: API
    private let cache: CacheService
    
    public init(api: API, cache: CacheService = InMemoryCache.shared) {
        self.api = api
        self.cache = cache
    }
    
    public func getStory(id: Int) async throws -> Story {
        do {
            // Try to fetch from API first
            let storyDto = try await api.getStory(id: id)
            
            // Convert to domain model
            let story = mapToDomain(storyDto)
            
            // Cache the successful result
            cache.set(value: story, for: CacheKeys.story(id: id))
            
            return story
        } catch {
            // If API call fails, try to get from cache
            if let cachedStory: Story = cache.get(for: CacheKeys.story(id: id)) {
                // Log that we're using cached data
                print("Using cached story (ID: \(id)) due to API error: \(error.localizedDescription)")
                return cachedStory
            }
            
            // If no cache available, re-throw the error
            throw error
        }
    }
    
    private func mapToDomain(_ dto: StoryDto) -> Story {
        return Story(
            id: dto.id,
            title: dto.title,
            author: dto.author,
            content: dto.content,
            // Convert milliseconds to seconds for Date
            publishedAt: Date(timeIntervalSince1970: dto.publicationDate.timeIntervalSince1970 / 1000)
        )
    }
}
