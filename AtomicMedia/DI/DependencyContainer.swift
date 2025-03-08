//
//  DependencyContainer.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 08/03/2025.
//


//
//  DependencyContainer.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 06/03/2025.
//  Updated on 07/03/2025.
//

import Foundation
import API

// Dependency Injection Container
public class DependencyContainer {
    
    // Singleton pattern for app-wide access
    public static let shared = DependencyContainer()
    
    private init() {}
    
    // MARK: - HeadlineViewModel
    
    // Factory method for HeadlineViewModel
    @MainActor public func makeHeadlineViewModel() -> HeadlineViewModel {
        return HeadlineViewModel(getHeadlinesUseCase: makeGetHeadlinesUseCase())
    }
    
    // Factory method for GetHeadlinesUseCase
    private func makeGetHeadlinesUseCase() -> GetHeadlinesUseCase {
        return DefaultGetHeadlinesUseCase(repository: makeHeadlineRepository())
    }
    
    // Factory method for HeadlineRepository with cache
    private func makeHeadlineRepository() -> HeadlineRepository {
        return CachedHeadlineRepository(api: makeAPI(), cache: InMemoryCache.shared)
    }
    
    // For testing - allows overriding dependencies
    @MainActor public func makeHeadlineViewModel(with useCase: GetHeadlinesUseCase) -> HeadlineViewModel {
        return HeadlineViewModel(getHeadlinesUseCase: useCase)
    }
    
    // MARK: - StoryViewModel
    
    // Factory method for StoryViewModel
    @MainActor public func makeStoryViewModel() -> StoryViewModel {
        return StoryViewModel(getStoryUseCase: makeGetStoryUseCase())
    }
    
    // Factory method for GetStoryUseCase
    private func makeGetStoryUseCase() -> GetStoryUseCase {
        return DefaultGetStoryUseCase(repository: makeStoryRepository())
    }
    
    // Factory method for StoryRepository with cache
    private func makeStoryRepository() -> StoryRepository {
        return CachedStoryRepository(api: makeAPI(), cache: InMemoryCache.shared)
    }
    
    // For testing - allows overriding dependencies
    @MainActor public func makeStoryViewModel(with useCase: GetStoryUseCase) -> StoryViewModel {
        return StoryViewModel(getStoryUseCase: useCase)
    }
    
    // MARK: - Shared Dependencies
    
    // Factory method for API
    private func makeAPI() -> API {
        return APIBuilder().makeAPI()
    }
    
    // Factory method for Cache
    private func makeCache() -> CacheService {
        return InMemoryCache.shared
    }
}