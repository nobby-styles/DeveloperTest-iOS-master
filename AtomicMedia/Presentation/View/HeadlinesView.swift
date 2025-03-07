//
//  HeadlinesView.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 07/03/2025.
//

import SwiftUI

struct HeadlinesView: View {
    @ObservedObject private var viewModel: HeadlineViewModel
    
    init(viewModel: HeadlineViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                contentView
                
                if viewModel.isLoading {
                    loadingView
                }
            }
            .navigationTitle("Headlines")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.refreshHeadlines()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                viewModel.refreshHeadlines()
            }
            .refreshable {
                await viewModel.fetchHeadlines()
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if let error = viewModel.error {
            errorView(error: error)
        } else {
            headlinesListView
        }
    }
    
    private var headlinesListView: some View {
        List {
            ForEach(viewModel.headlines) { headline in
                HeadlineRowView(headline: headline)
            }
        }
        .listStyle(.plain)
        .overlay(
            Group {
                if viewModel.headlines.isEmpty && !viewModel.isLoading {
                    VStack(spacing: 16) {
                        Image(systemName: "newspaper")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No Headlines")
                            .font(.headline)
                        
                        Text("There are no headlines to display at this time.")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
        )
    }
    
    private func errorView(error: HeadlineError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text("Something went wrong")
                .font(.headline)
            
            Text(error.message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Try Again") {
                viewModel.refreshHeadlines()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding()
    }
    
    private var loadingView: some View {
        ZStack {
            Color(.systemBackground).opacity(0.8)
            
            ProgressView()
                .scaleEffect(1.5)
        }
        .ignoresSafeArea()
    }
}

struct HeadlineRowView: View {
    let headline: Headline
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(headline.title)
                .font(.headline)
                .lineLimit(2)
            

            Text("By \(headline.author)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// Preview provider for SwiftUI Canvas
struct HeadlinesView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock view model for preview
        let mockUseCase = MockGetHeadlinesUseCase()
        let viewModel = DependencyContainer.shared.makeHeadlineViewModel(with: mockUseCase)
        return HeadlinesView(viewModel: viewModel)
    }
}

// Mock for Preview
private class MockGetHeadlinesUseCase: GetHeadlinesUseCase {
    func execute() async throws -> [Headline] {
        // Return sample data for preview
        return [
            Headline(id: 1, title: "SwiftUI 5 Announced with Major Performance Improvements", author: "John Appleseed"),
            Headline(id: 2, title: "The Future of Swift Concurrency", author: "Tim Apple"),
            Headline(id: 3, title: "iOS 19 Rumored to Include AI-Powered Features", author: "Charles Dickens")
        ]
    }
}
