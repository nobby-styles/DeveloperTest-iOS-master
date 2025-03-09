//
//  APIStoryRepository.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 07/03/2025.
//

import Foundation
import API

// Repository implementation for Story
public class APIStoryRepository: StoryRepository {
    private let api: API
    
    public init(api: API) {
        self.api = api
    }
    
    public func getStory(id: Int) async throws -> Story {
        do {
            // Call the API method with proper error handling
            let storyDto = try await api.getStory(id: id)
            
            // Map DTO to domain model
            return mapToDomain(storyDto)
        } catch let apiError as APIError {
            // Map API errors to domain errors
            switch apiError {
            case .offline:
                throw DomainError.connectivity
            case .failed:
                throw DomainError.serverError
            case .notFound:
                throw DomainError.notFound
            }
        } catch {
            // Handle any other errors
            throw DomainError.serverError
        }
    }
    
    // Helper method to map DTO to domain model
    func mapToDomain(_ dto: StoryDto) -> Story {
        return Story(
            id: dto.id,
            title: dto.title,
            author: dto.author,
            content: dto.content,

            //fix for a bug in the api data
            publishedAt: Date(timeIntervalSince1970: dto.publicationDate.timeIntervalSince1970 / 1000)
        )
    }
}
