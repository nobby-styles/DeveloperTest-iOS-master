//
//  StoryViewModel.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 07/03/2025.
//

import Foundation

// Presentation layer - ViewModel
@MainActor
public class StoryViewModel: ObservableObject {
    @Published public var story: Story?
    @Published public var isLoading: Bool = false
    @Published public var error: PresentationError?  // Reusing the existing error type

    private let getStoryUseCase: GetStoryUseCase
    private var currentTask: Task<Void, Never>?

    public init(getStoryUseCase: GetStoryUseCase) {
        self.getStoryUseCase = getStoryUseCase
    }

    public func startLoading() {
        self.isLoading = true
        self.error = nil
    }

    public func fetchStory(id: Int) async {
        // Cancel any existing task to prevent race conditions
        currentTask?.cancel()

        isLoading = true
        error = nil

        do {
            story = try await getStoryUseCase.execute(id: id)
        } catch {
            if !(error is CancellationError) {
                self.error = error.asHeadlineError  // Reusing the existing error mapping
            }
        }

        isLoading = false
    }

    public func refreshStory(id: Int) {
        // Cancel previous task if it exists
        currentTask?.cancel()

        // Create a new task and keep a reference to it
        currentTask = Task {
            await fetchStory(id: id)
        }
    }

    // Clean up resources when the view model is deallocated
    deinit {
        currentTask?.cancel()
    }

    public var formattedPublishedDate: String? {
        guard let publishedAt = story?.publishedAt else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: publishedAt)
    }
}
