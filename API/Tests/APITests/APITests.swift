import XCTest
import Combine
@testable import API


/// Tests to demonstrate how the API calls work
final class APITests: XCTestCase {
    
    let api:API = APIBuilder().makeAPI()
    
    var cancellables: Set<AnyCancellable> = []

    func testHeadlineAsync() async throws {
        do {
            let dto = try await api.getHeadlines()
            XCTAssert(dto.count > 0)
        } catch APIError.failed {
            // This is an expected failure mode, so nothing to do
        }
    }
    
    func testHeadlineCallback() {
        let exp = expectation(description: "data or APIError.failed error passed to callback")
        api.getHeadlines { result in
            switch result {
            case .success(let dto):
                XCTAssert(dto.count > 0)
                exp.fulfill()
            case .failure(APIError.failed):
                exp.fulfill()
            case .failure:
                XCTFail()
                exp.fulfill()
            }
        }
        waitForExpectations(timeout: 4.0)
    }
    
        
    func testHeadlinePublisher() {
        let exp = expectation(description: "data or APIError.failed error emitted by publisher")
        api.getHeadlinesPublisher()
            .sink { completion in
                switch completion {
                case .finished:
                    exp.fulfill()
                case .failure(APIError.failed):
                    exp.fulfill()
                case .failure:
                    XCTFail()
                    exp.fulfill()
                }
            } receiveValue: { dto in
                XCTAssert(dto.count > 0)
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 4.0)
    }
}
