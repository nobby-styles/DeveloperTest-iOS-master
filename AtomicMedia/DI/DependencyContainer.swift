//
//  DependencyContainer.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 06/03/2025.
//


import Foundation
import API

// Dependency Injection Container
public class DependencyContainer {
    
    // Singleton pattern for app-wide access
    public static let shared = DependencyContainer()
    
    private init() {}
    
    // Factory method for HeadlineViewModel
    @MainActor public func makeHeadlineViewModel() -> HeadlineViewModel {
        return HeadlineViewModel(getHeadlinesUseCase: makeGetHeadlinesUseCase())
    }
    
    // Factory method for GetHeadlinesUseCase
    private func makeGetHeadlinesUseCase() -> GetHeadlinesUseCase {
        return DefaultGetHeadlinesUseCase(repository: makeHeadlineRepository())
    }
    
    // Factory method for HeadlineRepository
    private func makeHeadlineRepository() -> HeadlineRepository {
        return APIHeadlineRepository(api: makeAPI())
    }
    
    // Factory method for API
    private func makeAPI() -> API {
        return APIBuilder().makeAPI()
    }
    
    // For testing - allows overriding dependencies
    @MainActor public func makeHeadlineViewModel(with useCase: GetHeadlinesUseCase) -> HeadlineViewModel {
        return HeadlineViewModel(getHeadlinesUseCase: useCase)
    }
}
