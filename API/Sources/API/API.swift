//
//  TransactionManager.swift
//  iOS Dev Test
//

import Foundation
import Combine

public typealias StoryID = Int

public struct HeadlineDto {
    public let id:StoryID
    public let title:String
    public let author:String
}

public struct StoryDto {
    public let id:StoryID
    public let title:String
    public let author:String
    public let content:String
    public let publicationDate:Date
    
    public var headline:HeadlineDto { HeadlineDto(id: self.id, title: self.title, author: self.author)}
}

public protocol API {

    func getHeadlines() async throws -> [HeadlineDto]
    func getStory(id:StoryID) async throws -> StoryDto
    
    func getHeadlines(onCompletion: @escaping (Result<[HeadlineDto],APIError>) -> Void )
    func getStory(id: StoryID, onCompletion: @escaping (Result<StoryDto,APIError>) -> Void )
    
    func getHeadlinesPublisher() -> Future<[HeadlineDto],APIError>
    func getStoryPublisher(id: StoryID) -> Future<StoryDto,APIError>
}

open class APIBuilder {
    
    public init() { }
    
    open func makeAPI(offline:Bool = false) -> API {
        if offline {
            return OfflineAPI()
        } else {
            return SimulatedAPI(stories: exampleData)
        }
    }
}

public enum APIError:Error {
    case failed
    case offline
    case notFound
}


/// A concrete implementation of the API that can simulate an unreliable network.  the function calls take time to respond, and can fail randomly
internal class SimulatedAPI:API {
     
    private let stories:[StoryDto]
    
    internal init(stories: [StoryDto]) {
        self.stories = stories
    }
    
    func getHeadlines() async throws -> [HeadlineDto] {
        try await applyUnreliability()
        return stories.map{ $0.headline }
    }
    
    func getStory(id: StoryID) async throws -> StoryDto {
        try await applyUnreliability()
        guard let story = stories.first(where:{ $0.id == id }) else { throw APIError.notFound }
        return story
    }

    func getHeadlines(onCompletion: @escaping (Result<[HeadlineDto],APIError>) -> Void ) {
        applyUnreliability { result in
            switch result {
            case .failure(let apiError):
                onCompletion(.failure(apiError))
            case .success:
                onCompletion(.success(self.stories.map{ $0.headline }))
            }
        }
    }
    
    func getStory(id: StoryID, onCompletion: @escaping (Result<StoryDto,APIError>) -> Void ) {
        applyUnreliability { result in
            switch result {
            case .failure(let apiError):
                onCompletion(.failure(apiError))
            case .success:
                guard let story = self.stories.first(where:{ $0.id == id }) else { onCompletion( .failure(APIError.notFound) ); return }
                onCompletion(.success(story))
            }
        }
    }
    
    
    func getHeadlinesPublisher() -> Future<[HeadlineDto],APIError> {
        return Future { promise in
            Task {
                do {
                    let headlines = try await self.getHeadlines()
                    promise(.success(headlines))
                } catch let error as APIError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(APIError.failed))
                }
            }
        }
    }

    
    func getStoryPublisher(id: StoryID) -> Future<StoryDto,APIError> {
        return Future { promise in
            Task {
                do {
                    let story = try await self.getStory(id: id)
                    promise(.success(story))
                } catch let error as APIError {
                    promise(.failure(error))
                } catch {
                    promise(.failure(APIError.failed))
                }
            }
        }
    }


    //MARK: - Simulate poor network connections by inserting delays and failures into the API calls
    
    private func applyUnreliability(onCompletion: @escaping (Result<Void,APIError>) -> Void) {
        let randomDelay = Double.random(in: 0.01..<3.0)
        DispatchQueue.global().asyncAfter(deadline: .now() + randomDelay) {
            guard Int.random(in: 0..<5) > 0 else {
                onCompletion(.failure(APIError.failed))
                return
            }
            onCompletion(.success(()))
        }
    }
    
    private func applyUnreliability() async throws {
        let randomDelay = UInt64.random(in: 10_000_000..<3_000_000_000)
        try? await Task.sleep(nanoseconds: randomDelay)
        guard Int.random(in: 0..<5) > 0 else { throw APIError.failed }
    }
}

internal class OfflineAPI:API {
    
    func getHeadlines() async throws -> [HeadlineDto] {
        throw APIError.offline
    }
    
    func getStory(id: StoryID) async throws -> StoryDto {
        throw APIError.offline
    }
    
    func getHeadlines(onCompletion: @escaping (Result<[HeadlineDto], APIError>) -> Void) {
        DispatchQueue.global().async {
            onCompletion(.failure(APIError.offline))
        }
    }
    
    func getStory(id: StoryID, onCompletion: @escaping (Result<StoryDto, APIError>) -> Void) {
        DispatchQueue.global().async {
            onCompletion(.failure(APIError.offline))
        }
    }
    
    func getHeadlinesPublisher() -> Future<[HeadlineDto], APIError> {
        return Future { promise in
            promise(.failure(APIError.offline))
        }
    }
    
    func getStoryPublisher(id: StoryID) -> Future<StoryDto, APIError> {
        return Future { promise in
            promise(.failure(APIError.offline))
        }
    }
}
