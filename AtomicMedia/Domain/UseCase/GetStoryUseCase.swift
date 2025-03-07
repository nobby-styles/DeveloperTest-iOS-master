//
//  GetStoryUseCase.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 07/03/2025.
//

import Foundation

public protocol GetStoryUseCase {
    func execute(id: Int) async throws -> Story
}

// Default implementation of use case
public class DefaultGetStoryUseCase: GetStoryUseCase {
    private let repository: StoryRepository
    
    public init(repository: StoryRepository) {
        self.repository = repository
    }
    
    public func execute(id: Int) async throws -> Story {
        return try await repository.getStory(id: id)
    }
}

// Repository protocol
public protocol StoryRepository {
    func getStory(id: Int) async throws -> Story
}
