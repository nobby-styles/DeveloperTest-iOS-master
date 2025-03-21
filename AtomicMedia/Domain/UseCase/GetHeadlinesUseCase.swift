//
//  GetHeadlinesUseCase.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 06/03/2025.
//


import Foundation

// Domain layer - Use Case
public protocol GetHeadlinesUseCase {
    func execute() async throws -> [Headline]
}

// Domain layer - Use Case Implementation
public class DefaultGetHeadlinesUseCase: GetHeadlinesUseCase {
    private let repository: HeadlineRepository

    public init(repository: HeadlineRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [Headline] {
        do {
            return try await repository.getHeadlines()
        } catch let error as DomainError {
            // Map domain errors to presentation errors
            switch error {
            case .connectivity:
                throw PresentationError.connectivity
            case .notFound:
                throw PresentationError.notFound
            case .serverError:
                throw PresentationError.serverError
            }
        } catch {
            // Handle any unexpected errors
            throw PresentationError.unknown
        }
    }
}

// Domain layer - Repository interface
public protocol HeadlineRepository {
    func getHeadlines() async throws -> [Headline]
}

extension DomainError {
    var asPresentationError: PresentationError {
        switch self {
        case .connectivity:
            return .connectivity
        case .notFound:
            return .notFound
        case .serverError:
            return .serverError
        }
    }
}
