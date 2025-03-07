//
//  Headline.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 06/03/2025.
//


import Foundation
import API

// Domain models for the presentation layer
public struct Headline: Identifiable {
    public let id: Int
    public let title: String
    public let author: String
    
    public init(id: Int, title: String, author: String) {
        self.id = id
        self.title = title
        self.author = author
    }
}

// Extension to convert from DTO to domain model
extension HeadlineDto {
    func toDomain() -> Headline {
        return Headline(id: id, title: title, author: author)
    }
}
