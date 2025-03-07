//
//  HeadlineViewModelTests.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 06/03/2025.
//


import XCTest
import Combine
@testable import API
@testable import AtomicMediaDeveloper

@MainActor
final class HeadlineViewModelTests: XCTestCase {

    // MARK: - Success State Tests

    func testFetchHeadlinesSuccess() async {
        // Given
        let mockHeadlines = [
            Headline(id: 1, title: "Test Headline 1", author: "Author 1"),
            Headline(id: 2, title: "Test Headline 2", author: "Author 2")
        ]
        let mockUseCase = MockGetHeadlinesUseCase(headlines: mockHeadlines)
        let viewModel = HeadlineViewModel(getHeadlinesUseCase: mockUseCase)

        // When
        await viewModel.fetchHeadlines()

        // Then
        XCTAssertEqual(viewModel.headlines.count, 2)
        XCTAssertEqual(viewModel.headlines[0].id, 1)
        XCTAssertEqual(viewModel.headlines[0].title, "Test Headline 1")
        XCTAssertEqual(viewModel.headlines[1].id, 2)
        XCTAssertEqual(viewModel.headlines[1].title, "Test Headline 2")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testFetchHeadlinesEmptySuccess() async {
        // Given
        let mockUseCase = MockGetHeadlinesUseCase(headlines: [])
        let viewModel = HeadlineViewModel(getHeadlinesUseCase: mockUseCase)

        // When
        await viewModel.fetchHeadlines()

        // Then
        XCTAssertTrue(viewModel.headlines.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertNil(viewModel.errorMessage)
    }

    // MARK: - Error State Tests

    func testFetchHeadlinesConnectivityError() async {
        // Given
        let mockUseCase = MockGetHeadlinesUseCase(domainError: .connectivity)
        let viewModel = HeadlineViewModel(getHeadlinesUseCase: mockUseCase)

        // When
        await viewModel.fetchHeadlines()

        // Then
        XCTAssertTrue(viewModel.headlines.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.error, .connectivity)
        XCTAssertEqual(viewModel.errorMessage, "You appear to be offline")
    }

    func testFetchHeadlinesServerError() async {
        // Given
        let mockUseCase = MockGetHeadlinesUseCase(domainError: .serverError)
        let viewModel = HeadlineViewModel(getHeadlinesUseCase: mockUseCase)

        // When
        await viewModel.fetchHeadlines()

        // Then
        XCTAssertTrue(viewModel.headlines.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.error, .serverError)
        XCTAssertEqual(viewModel.errorMessage, "Something went wrong. Please try again.")
    }

    func testFetchHeadlinesNotFoundError() async {
        // Given
        let mockUseCase = MockGetHeadlinesUseCase(domainError: .notFound)
        let viewModel = HeadlineViewModel(getHeadlinesUseCase: mockUseCase)

        // When
        await viewModel.fetchHeadlines()

        // Then
        XCTAssertTrue(viewModel.headlines.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.error, .notFound)
        XCTAssertEqual(viewModel.errorMessage, "Headlines not found")
    }

    func testFetchHeadlinesUnexpectedError() async {
        // Given
        let mockUseCase = MockGetHeadlinesUseCase(unexpectedError: true)
        let viewModel = HeadlineViewModel(getHeadlinesUseCase: mockUseCase)

        // When
        await viewModel.fetchHeadlines()

        // Then
        XCTAssertTrue(viewModel.headlines.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.error, .unknown)
        XCTAssertEqual(viewModel.errorMessage, "An unexpected error occurred")
    }

    // MARK: - Loading State Tests

    func testLoadingStateChanges() async {
        // Given
        let mockUseCase = SlowMockGetHeadlinesUseCase(headlines: [Headline(id: 1, title: "Title", author: "Author")])
        let viewModel = HeadlineViewModel(getHeadlinesUseCase: mockUseCase)

        // When - First check that loading is false initially
        XCTAssertFalse(viewModel.isLoading)

        // Start a task to fetch headlines
        let fetchTask = Task {
            await viewModel.fetchHeadlines()
        }

        // Give the task time to start and set isLoading to true
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds

        // Verify loading is true during the fetch
        XCTAssertTrue(viewModel.isLoading)

        // Wait for the fetch task to complete
        await fetchTask.value

        // Verify loading is false after fetch completes
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Refresh Test

    func testRefreshHeadlines() async {
        // Given
        let mockUseCase = MockGetHeadlinesUseCase(headlines: [Headline(id: 1, title: "Test Headline", author: "Author")])
        let viewModel = HeadlineViewModel(getHeadlinesUseCase: mockUseCase)

        // When
        viewModel.refreshHeadlines()

        // Wait a short time for the async task to begin and complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then
        XCTAssertEqual(viewModel.headlines.count, 1)
    }
}

// MARK: - Mock Use Cases

class MockGetHeadlinesUseCase: GetHeadlinesUseCase {
    let headlines: [Headline]
    let domainError: DomainError?
    let unexpectedError: Bool

    struct UnexpectedError: Error {}

    init(headlines: [Headline] = [], domainError: DomainError? = nil, unexpectedError: Bool = false) {
        self.headlines = headlines
        self.domainError = domainError
        self.unexpectedError = unexpectedError
    }

    func execute() async throws -> [Headline] {
        if let error = domainError {
            throw error
        }
        if unexpectedError {
            throw UnexpectedError()
        }
        return headlines
    }
}

class SlowMockGetHeadlinesUseCase: GetHeadlinesUseCase {
    let headlines: [Headline]

    init(headlines: [Headline]) {
        self.headlines = headlines
    }

    func execute() async throws -> [Headline] {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        return headlines
    }
}
