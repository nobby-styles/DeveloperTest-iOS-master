//
//  Story.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 07/03/2025.
//

import Foundation

// Domain model for Story
public struct Story: Identifiable {
    public let id: Int
    public let title: String
    public let author: String
    public let content: String
    public let publishedAt: Date
}
