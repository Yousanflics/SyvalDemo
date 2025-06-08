import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var reminderService = SpendingReminderService.shared
    @StateObject private var tabBarViewModel = TabBarViewModel.shared
    // Note: showingCreatePost, showingNotifications, and showingReminders moved to CustomTabBar
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background with gradient and glassy effect
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGroupedBackground),
                        Color(.secondarySystemGroupedBackground),
                        Color(.tertiarySystemGroupedBackground)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .background(.thinMaterial)
                
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    // Loading state
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading posts...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                } else if viewModel.posts.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "heart.text.square")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No posts yet")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Be the first to share your spending experience!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("Tap the share button below to get started")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    .padding()
                } else {
                    // Posts feed
                    ScrollDetectionView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.posts) { post in
                                PostCardView(
                                    post: post,
                                    onLike: {
                                        viewModel.toggleLike(for: post)
                                    },
                                    onComment: {
                                        // Comment functionality is now handled within PostCardView
                                    },
                                    onShare: {
                                        // Share functionality is now handled within PostCardView
                                    },
                                    feedViewModel: viewModel
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    .scrollIndicators(.hidden)
                    .refreshable {
                        viewModel.refreshPosts()
                    }
                }
                
                // Error alert
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(errorMessage)
                                .font(.caption)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 4)
                        )
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Customize navigation bar appearance
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.systemBackground
                appearance.shadowColor = UIColor.clear
                
                // Customize title text attributes
                appearance.titleTextAttributes = [
                    .foregroundColor: UIColor.label,
                    .font: UIFont.systemFont(ofSize: 20, weight: .bold)
                ]
                
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
                UINavigationBar.appearance().compactAppearance = appearance
            }
            .toolbar {
                // Custom title on the left side
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("For You")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 8) {
                        // Friends button
                        Button(action: {
                            // Navigate to friends view
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "person.2")
                                    .font(.caption)
                                Text("Friends")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.purple)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.indigo.veryLight())
                            )
                        }
                    }
                }
            }
        }
        .onAppear {
            tabBarViewModel.navigateToView(.feed)
        }
        // Note: Sheets and fullScreenCover moved to CustomTabBar
    }
}

#Preview {
    FeedView()
} 
