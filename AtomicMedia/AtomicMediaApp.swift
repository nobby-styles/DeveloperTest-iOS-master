//
//  AtomicMediaDeveloperApp.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 07/03/2025.
//
//

import SwiftUI

@main
struct AtomicMediaDeveloperApp: App {
    // Create ViewModel at the app level using DI container
    @StateObject private var headlineViewModel = DependencyContainer.shared.makeHeadlineViewModel()

    var body: some Scene {
        WindowGroup {
            HeadlinesView(viewModel: headlineViewModel)
                .onAppear {
                    // Set loading state and fetch data immediately
                    headlineViewModel.startLoading()
                    headlineViewModel.refreshHeadlines()
                }
        }
    }
}
