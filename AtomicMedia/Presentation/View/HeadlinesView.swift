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
            Group {
                if viewModel.isLoading {
                    // Loading state takes highest priority
                    loadingView
                } else if let error = viewModel.error {
                    // Error state is next
                    errorView(error: error)
                } else {
                    // Content state is shown if not loading and no error
                    headlinesListView
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
                // Only fetch if headlines are empty
                if viewModel.headlines.isEmpty {
                    viewModel.startLoading()
                    viewModel.refreshHeadlines()
                }
            }
            .refreshable {
                await viewModel.fetchHeadlines()
            }

        }
    }

    @ViewBuilder
    private var headlinesListView: some View {
        if viewModel.headlines.isEmpty {
            // Show empty state
            VStack(spacing: 16) {
                Image(systemName: "newspaper")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)

                Text("No Headlines")
                    .font(.headline)

                Text("There are no headlines to display at this time.")
                    .foregroundColor(.secondary)

                Button("Refresh") {
                    viewModel.refreshHeadlines()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
            .padding()
        } else {
            // Show the list if we have headlines
            List {
                ForEach(viewModel.headlines) { headline in
                    NavigationLink(destination: {
                        let storyViewModel = DependencyContainer.shared
                            .makeStoryViewModel()
                        StoriesView(
                            viewModel: storyViewModel, storyId: headline.id)
                    }) {
                        HeadlineRowView(headline: headline)
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    private func errorView(error: PresentationError) -> some View {
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
        VStack {
            Spacer()

            ProgressView()
                .scaleEffect(1.5)
                .padding()

            Text("Loading headlines...")
                .foregroundColor(.secondary)
                .padding()

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
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
