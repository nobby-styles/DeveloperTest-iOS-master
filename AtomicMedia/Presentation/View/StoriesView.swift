//
//  StoriesView.swift
//  AtomicMediaDeveloper
//
//  Created by Robert Redmond on 07/03/2025.
//

import SwiftUI

struct StoriesView: View {
    @ObservedObject private var viewModel: StoryViewModel
    private let storyId: Int
    
    init(viewModel: StoryViewModel, storyId: Int) {
        self.viewModel = viewModel
        self.storyId = storyId
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                // Loading state takes highest priority
                loadingView
            } else if let error = viewModel.error {
                // Error state is next
                errorView(error: error)
            } else if let story = viewModel.story {
                // Content state is shown if we have a story
                storyContentView(story: story)
            } else {
                // Fallback if no story and no error
                emptyView
            }
        }
        .navigationTitle("Story")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.refreshStory(id: storyId)
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            viewModel.startLoading()
            viewModel.refreshStory(id: storyId)
        }
    }
    
    private func storyContentView(story: Story) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(story.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack {
                    Text("By \(story.author)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let formattedDate = viewModel.formattedPublishedDate {
                        Text(formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                Text(story.content)
                    .font(.body)
                    .lineSpacing(6)
            }
            .padding()
        }
        .refreshable {
            await viewModel.fetchStory(id: storyId)
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Story Found")
                .font(.headline)
            
            Text("The requested story could not be loaded.")
                .foregroundColor(.secondary)
            
            Button("Try Again") {
                viewModel.refreshStory(id: storyId)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding()
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
                viewModel.refreshStory(id: storyId)
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
            
            Text("Loading story...")
                .foregroundColor(.secondary)
                .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// Preview provider for SwiftUI Canvas
struct StoriesView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock view model for preview
        let mockUseCase = MockGetStoryUseCase()
        let viewModel = StoryViewModel(getStoryUseCase: mockUseCase)
        
        NavigationView {
            StoriesView(viewModel: viewModel, storyId: 1)
        }
    }
}

// Mock for Preview
private class MockGetStoryUseCase: GetStoryUseCase {
    func execute(id: Int) async throws -> Story {
        // Return sample data for preview
        return Story(
            id: id,
            title: "The Dawn of Quantum Computing: How It Will Change Everything",
            author: "Jane Smith",
            content: """
            In the ever-evolving landscape of technology, few developments hold as much promise and intrigue as quantum computing. Unlike classical computers that use bits (0s and 1s), quantum computers leverage quantum bits or "qubits" that can exist in multiple states simultaneously, thanks to the principles of quantum mechanics.
            
            This fundamental difference gives quantum computers the potential to solve complex problems that would take classical computers millions of years to complete. From drug discovery and material science to cryptography and artificial intelligence, the applications are vast and transformative.
            
            Major technology companies and research institutions around the world are racing to achieve quantum supremacy – the point at which a quantum computer can perform a task that's practically impossible for classical computers.
            
            While we're still in the early days of this technology, the progress has been remarkable. Researchers have already demonstrated quantum systems with dozens of qubits, and the roadmap to scaling up to hundreds or thousands of qubits is becoming clearer.
            
            As quantum computing continues to advance, we can expect breakthrough discoveries in fields ranging from medicine to climate science. The ability to simulate molecular interactions with unprecedented accuracy could lead to new treatments for diseases, more efficient batteries, and sustainable materials.
            
            However, this technology also brings challenges. Current encryption methods that secure our digital communications could become vulnerable to quantum attacks, necessitating the development of quantum-resistant cryptography.
            
            The journey toward practical, widespread quantum computing is ongoing, with exciting milestones being reached regularly. As we stand on the brink of this new computational era, one thing is certain: quantum computing will fundamentally change our technological capabilities and open doors to innovations we've yet to imagine.
            """,
            publishedAt: Date().addingTimeInterval(-86400) // Yesterday
        )
    }
}
