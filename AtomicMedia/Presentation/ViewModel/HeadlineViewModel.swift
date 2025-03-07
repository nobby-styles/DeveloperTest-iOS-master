//
//  HeadlineViewModel.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 06/03/2025.
//


import Foundation

// Presentation layer - ViewModel
@MainActor
public class HeadlineViewModel: ObservableObject {
    @Published public var headlines: [Headline] = []
    @Published public var isLoading: Bool = false
    @Published public var error: HeadlineError?
    
    private let getHeadlinesUseCase: GetHeadlinesUseCase
    
    public init(getHeadlinesUseCase: GetHeadlinesUseCase) {
        self.getHeadlinesUseCase = getHeadlinesUseCase
    }
    
    public func fetchHeadlines() async {
        isLoading = true
        error = nil
        
        do {
            headlines = try await getHeadlinesUseCase.execute()
        } catch {
            self.error = error.asHeadlineError
        }
        
        isLoading = false
    }
    
    public func refreshHeadlines() {
        Task {
            await fetchHeadlines()
        }
    }
    
    public var errorMessage: String? {
        error?.message
    }
}

extension Error {
    var asHeadlineError: HeadlineError {
        if let domainError = self as? DomainError {
            return domainError.asPresentationError
        }
        return .unknown
    }
}
