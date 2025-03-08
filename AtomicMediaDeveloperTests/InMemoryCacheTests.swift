//
//  InMemoryCacheTests.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 08/03/2025.
//


import XCTest
@testable import AtomicMediaDeveloper

class InMemoryCacheTests: XCTestCase {
    
    // System under test
    var cache: InMemoryCache!
    
    // Test class for storing in cache
    class TestObject: NSObject {
        let id: Int
        let name: String
        
        init(id: Int, name: String) {
            self.id = id
            self.name = name
        }
    }
    
    override func setUp() {
        super.setUp()
        cache = InMemoryCache.shared
        cache.clearAll() // Start each test with a clean cache
    }
    
    // MARK: - Tests
    
    func testSetAndGetObject() {
        // Arrange
        let testObject = TestObject(id: 1, name: "Test Object")
        let key = "test_key"
        
        // Act
        cache.set(value: testObject, for: key)
        let retrievedObject: TestObject? = cache.get(for: key)
        
        // Assert
        XCTAssertNotNil(retrievedObject)
        XCTAssertEqual(retrievedObject?.id, testObject.id)
        XCTAssertEqual(retrievedObject?.name, testObject.name)
    }
    
    func testGetNonexistentKey() {
        // Act
        let retrievedObject: TestObject? = cache.get(for: "nonexistent_key")
        
        // Assert
        XCTAssertNil(retrievedObject)
    }
    
    func testClearKey() {
        // Arrange
        let testObject = TestObject(id: 1, name: "Test Object")
        let key = "test_key"
        cache.set(value: testObject, for: key)
        
        // Act
        cache.clear(key: key)
        let retrievedObject: TestObject? = cache.get(for: key)
        
        // Assert
        XCTAssertNil(retrievedObject)
    }
    
    func testClearAll() {
        // Arrange
        let testObject1 = TestObject(id: 1, name: "Test Object 1")
        let testObject2 = TestObject(id: 2, name: "Test Object 2")
        cache.set(value: testObject1, for: "key1")
        cache.set(value: testObject2, for: "key2")
        
        // Act
        cache.clearAll()
        let retrievedObject1: TestObject? = cache.get(for: "key1")
        let retrievedObject2: TestObject? = cache.get(for: "key2")
        
        // Assert
        XCTAssertNil(retrievedObject1)
        XCTAssertNil(retrievedObject2)
    }
    
    func testStoreValueTypeWrappedAsReference() {
        // Arrange
        // Create a class wrapper for our struct (value type)
        class StructWrapper<T>: NSObject {
            let value: T
            
            init(value: T) {
                self.value = value
            }
        }
        
        // Create a test struct (value type)
        struct TestStruct {
            let id: Int
            let name: String
        }
        
        let testStruct = TestStruct(id: 1, name: "Test Struct")
        let wrapper = StructWrapper(value: testStruct)
        let key = "test_struct_key"
        
        // Act
        cache.set(value: wrapper, for: key)
        let retrievedWrapper: StructWrapper<TestStruct>? = cache.get(for: key)
        
        // Assert
        XCTAssertNotNil(retrievedWrapper)
        XCTAssertEqual(retrievedWrapper?.value.id, testStruct.id)
        XCTAssertEqual(retrievedWrapper?.value.name, testStruct.name)
    }
    
    func testMultipleDataTypes() {
        // Arrange
        let stringValue = "Test String"
        let numberValue = NSNumber(value: 42)
        let arrayValue = NSArray(array: [1, 2, 3])
        
        // Act
        cache.set(value: stringValue, for: "string_key")
        cache.set(value: numberValue, for: "number_key")
        cache.set(value: arrayValue, for: "array_key")
        
        let retrievedString: String? = cache.get(for: "string_key")
        let retrievedNumber: NSNumber? = cache.get(for: "number_key")
        let retrievedArray: NSArray? = cache.get(for: "array_key")
        
        // Assert
        XCTAssertEqual(retrievedString, stringValue)
        XCTAssertEqual(retrievedNumber, numberValue)
        XCTAssertEqual(retrievedArray, arrayValue)
    }
}
