import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @StateObject private var notificationService = NotificationService.shared
    @State private var showingCreatePost = false
    @State private var showingNotifications = false
    
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
                        
                        Button("Create Post") {
                            showingCreatePost = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding()
                } else {
                    // Posts feed
                    ScrollView {
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
                        
                        // Share/Create post button
                        Button(action: {
                            showingCreatePost = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text("Share")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.indigo)
                            )
                            .overlay(
                                // Red notification badge
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 18, height: 18)
                                    
                                    Text("10")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .offset(x: 35, y: -8)
                            )
                        }
                        
                        // Notification bell
                        Button(action: {
                            showingNotifications = true
                        }) {
                            ZStack {
                                Image(systemName: "bell")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Unread count badge
                                if notificationService.unreadCount > 0 {
                                    Text("\(notificationService.unreadCount)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(minWidth: 16, minHeight: 16)
                                        .background(
                                            Circle()
                                                .fill(Color.red)
                                        )
                                        .offset(x: 8, y: -8)
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreatePost) {
            CreatePostView()
        }
        .fullScreenCover(isPresented: $showingNotifications) {
            NotificationCenterView()
        }
//        .sheet(isPresented: $showingNotifications) {
//            NotificationCenterView()
//        }
    }
}

#Preview {
    FeedView()
} 
