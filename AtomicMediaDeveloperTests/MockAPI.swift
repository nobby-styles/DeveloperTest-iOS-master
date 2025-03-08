//
//  MockAPI.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 08/03/2025.
//


import Foundation
import Combine
@testable import AtomicMediaDeveloper
import API

// Simplified mock implementation with minimal functionality
class MockAPI: API {
    var headlinesToReturn: [HeadlineDto] = []
    var storyToReturn: StoryDto?
    var shouldThrowError = false

    // Async/await methods - used in tests
    func getHeadlines() async throws -> [HeadlineDto] {
        if shouldThrowError {
            throw APIError.offline
        }
        return headlinesToReturn
    }

    func getStory(id: Int) async throws -> StoryDto {
        if shouldThrowError {
            throw APIError.offline
        }
        guard let story = storyToReturn else {
            throw APIError.notFound
        }
        return story
    }

    // Stub implementations - not used in tests
    func getHeadlines(onCompletion: @escaping (Result<[HeadlineDto], APIError>) -> Void) {
        fatalError("Not implemented for tests")
    }

    func getStory(id: Int, onCompletion: @escaping (Result<StoryDto, APIError>) -> Void) {
        fatalError("Not implemented for tests")
    }

    func getHeadlinesPublisher() -> Future<[HeadlineDto], APIError> {
        fatalError("Not implemented for tests")
    }

    func getStoryPublisher(id: Int) -> Future<StoryDto, APIError> {
        fatalError("Not implemented for tests")
    }

    func applyUnreliability() async throws {
        // Do nothing in mock
    }
}
