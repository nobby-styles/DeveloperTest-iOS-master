//
//  APIHeadlineRepository.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 06/03/2025.
//

import API

public enum DomainError: Error, Equatable {
    case connectivity
    case notFound
    case serverError

    // Optional: Add descriptions for debugging
    public var description: String {
        switch self {
        case .connectivity:
            return "Network connectivity issue"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error"
        }
    }
}
// Repository maps API errors to domain errors
public class APIHeadlineRepository: HeadlineRepository {
    private let api: API

    public init(api: API) {
        self.api = api
    }

    public func getHeadlines() async throws -> [Headline] {
        do {
            let headlineDtos = try await api.getHeadlines()
            return headlineDtos.map { $0.toDomain() }
        } catch let apiError as APIError {
            // Map API-specific errors to domain errors
            switch apiError {
            case .offline:
                throw DomainError.connectivity
            case .notFound:
                throw DomainError.notFound
            case .failed:
                throw DomainError.serverError
            }
        } catch {
            // Map any other unexpected errors
            throw DomainError.serverError
        }
    }
}
