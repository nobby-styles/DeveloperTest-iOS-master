//
//  CachedHeadlineRepositoryTests.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 08/03/2025.
//

import XCTest
@testable import AtomicMediaDeveloper
@testable import API

class CachedHeadlineRepositoryTests: XCTestCase {
    
    // Mocks
    var mockAPI: MockAPI!
    var mockCache: MockCacheService!
    
    // System under test
    var repository: CachedHeadlineRepository!
    
    // Test data
    let testHeadlines = [
        HeadlineDto(id: 1, title: "Test Headline 1", author: "Test Author 1"),
        HeadlineDto(id: 2, title: "Test Headline 2", author: "Test Author 2")
    ]
    
    override func setUp() {
        super.setUp()
        mockAPI = MockAPI()
        mockCache = MockCacheService()
        repository = CachedHeadlineRepository(api: mockAPI, cache: mockCache)
    }
    
    override func tearDown() {
        mockAPI = nil
        mockCache = nil
        repository = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testGetHeadlinesFromAPI() async throws {
        // Arrange
        mockAPI.headlinesToReturn = testHeadlines
        
        // Act
        let headlines = try await repository.getHeadlines()
        
        // Assert
        XCTAssertEqual(headlines.count, testHeadlines.count)
        XCTAssertEqual(headlines[0].id, testHeadlines[0].id)
        XCTAssertEqual(headlines[1].id, testHeadlines[1].id)
        
        // Verify cache was updated
        XCTAssertTrue(mockCache.setCalled)
        XCTAssertEqual(mockCache.lastKeySet, CacheKeys.headlines)
    }
    
    func testGetHeadlinesFromCacheWhenAPIFails() async throws {
        // Arrange
        let expectedHeadlines = testHeadlines.map { dto in
            Headline(id: dto.id, title: dto.title, author: dto.author)
        }
        
        mockAPI.shouldThrowError = true
        mockCache.dataToReturn = expectedHeadlines
        
        // Act
        let headlines = try await repository.getHeadlines()
        
        // Assert
        XCTAssertEqual(headlines.count, expectedHeadlines.count)
        XCTAssertEqual(headlines[0].id, expectedHeadlines[0].id)
        XCTAssertEqual(headlines[1].id, expectedHeadlines[1].id)
        
        // Verify cache was checked
        XCTAssertTrue(mockCache.getCalled)
        XCTAssertEqual(mockCache.lastKeyGet, CacheKeys.headlines)
    }
    
    func testErrorPropagatedWhenAPIFailsAndNoCacheAvailable() async {
        // Arrange
        mockAPI.shouldThrowError = true
        mockCache.dataToReturn = nil
        
        // Act & Assert
        do {
            _ = try await repository.getHeadlines()
            XCTFail("Should have thrown an error")
        } catch {
            // Success - error was propagated
            XCTAssertTrue(error is APIError)
        }
    }
}

// MARK: - Mock Cache Service

class MockCacheService: CacheService {
    var getCalled = false
    var setCalled = false
    var clearCalled = false
    var clearAllCalled = false
    
    var lastKeyGet: String?
    var lastKeySet: String?
    var lastKeyCleared: String?
    
    var dataToReturn: Any?
    
    func get<T>(for key: String) -> T? {
        getCalled = true
        lastKeyGet = key
        return dataToReturn as? T
    }
    
    func set<T>(value: T, for key: String) {
        setCalled = true
        lastKeySet = key
    }
    
    func clear(key: String) {
        clearCalled = true
        lastKeyCleared = key
    }
    
    func clearAll() {
        clearAllCalled = true
    }
}
