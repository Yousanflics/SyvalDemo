import Foundation
import Combine
import SwiftUI

class FeedViewModel: ObservableObject {
    @Published var posts: [SpendingPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isRefreshing = false
    
    private let dataService = MockDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadPosts()
        
        // Subscribe to data service posts updates
        dataService.$posts
            .assign(to: \.posts, on: self)
            .store(in: &cancellables)
    }
    
    func loadPosts() {
        isLoading = true
        errorMessage = nil
        
        dataService.fetchPosts()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    self?.isRefreshing = false
                    
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] response in
                    self?.posts = response.posts
                }
            )
            .store(in: &cancellables)
    }
    
    func refreshPosts() {
        isRefreshing = true
        loadPosts()
    }
    
    func toggleLike(for post: SpendingPost) {
        dataService.toggleLike(postId: post.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to toggle like: \(error)")
                    }
                },
                receiveValue: { _ in
                    // Post update is handled by the data service
                }
            )
            .store(in: &cancellables)
    }
    
    func addComment(to post: SpendingPost, content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        dataService.addComment(postId: post.id, content: content)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to add comment: \(error)")
                    }
                },
                receiveValue: { _ in
                    // Comment count update is handled by the data service
                }
            )
            .store(in: &cancellables)
    }
    
    func getComments(for post: SpendingPost) -> AnyPublisher<[Comment], Error> {
        return dataService.getComments(postId: post.id)
    }
} 
