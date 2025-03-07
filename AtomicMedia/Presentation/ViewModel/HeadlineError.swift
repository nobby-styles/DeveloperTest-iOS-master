//
//  HeadlineError.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 06/03/2025.
//


import Foundation

/// Presentation layer errors for headlines feature
public enum HeadlineError: Error, Equatable {
    case connectivity
    case serverError
    case notFound
    case unknown

    public var message: String {
        switch self {
        case .connectivity:
            return "You appear to be offline"
        case .serverError:
            return "Something went wrong. Please try again."
        case .notFound:
            return "Headlines not found"
        case .unknown:
            return "An unexpected error occurred"
        }
    }
}
