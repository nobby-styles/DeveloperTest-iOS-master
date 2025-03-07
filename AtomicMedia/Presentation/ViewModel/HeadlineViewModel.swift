//
//  HeadlineViewModel.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 07/03/2025.
//

import Foundation

// Presentation layer - ViewModel
@MainActor
public class HeadlineViewModel: ObservableObject {
    @Published public var headlines: [Headline] = []
    @Published public var isLoading: Bool = false
    @Published public var error: PresentationError?
    
    private let getHeadlinesUseCase: GetHeadlinesUseCase
    private var currentTask: Task<Void, Never>?
    
    public init(getHeadlinesUseCase: GetHeadlinesUseCase) {
        self.getHeadlinesUseCase = getHeadlinesUseCase
    }
    
    // Explicitly set loading state to true
    public func startLoading() {
        self.isLoading = true
        self.error = nil
    }
    
    public func fetchHeadlines() async {
        // Cancel any existing task to prevent race conditions
        currentTask?.cancel()
        
        isLoading = true
        error = nil
        
        do {
            headlines = try await getHeadlinesUseCase.execute()
        } catch {
            if !(error is CancellationError) {
                self.error = error.asHeadlineError
            }
        }
        
        isLoading = false
    }
    
    public func refreshHeadlines() {
        // Cancel previous task if it exists
        currentTask?.cancel()
        
        // Create a new task and keep a reference to it
        currentTask = Task {
            await fetchHeadlines()
        }
    }
    
    // Clean up resources when the view model is deallocated
    deinit {
        currentTask?.cancel()
    }
    
    public var errorMessage: String? {
        error?.message
    }
}

extension Error {
    var asHeadlineError: PresentationError {
        if let domainError = self as? DomainError {
            return domainError.asPresentationError
        }
        return .unknown
    }
}
