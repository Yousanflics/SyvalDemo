import SwiftUI
import Combine

extension Color {
    // Create lighter version of color for backgrounds
    func lighter(by percentage: Double = 0.8) -> Color {
        return self.opacity(percentage)
    }
    
    // Create very light version for card backgrounds  
    func veryLight(by percentage: Double = 0.15) -> Color {
        return self.opacity(percentage)
    }
    
    // Create darker version for text
    func darker() -> Color {
        return self
    }
}

// MARK: - Comment Row View
struct CommentRowView: View {
    let comment: Comment
    let isReply: Bool
    @State private var showReplies = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                // Indentation for replies
                if isReply {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 20)
                }
                
                // User avatar
                Text(comment.user.avatarEmoji)
                    .font(.caption)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(Color(.systemGray6))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    // Comment header
                    HStack {
                        Text(comment.user.displayName)
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        Text(comment.timeAgo)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Like button
                        HStack(spacing: 2) {
                            Image(systemName: comment.isLikedByCurrentUser ? "heart.fill" : "heart")
                                .font(.caption2)
                                .foregroundColor(comment.isLikedByCurrentUser ? .red : .secondary)
                            
                            if comment.likesCount > 0 {
                                Text("\(comment.likesCount)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Comment content
                    Text(comment.content)
                        .font(.caption)
                        .lineLimit(nil)
                    
                    // Reply button for main comments
                    if !isReply && !comment.replies.isEmpty {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showReplies.toggle()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: showReplies ? "chevron.down" : "chevron.right")
                                    .font(.caption2)
                                Text("\(comment.replies.count) replies")
                                    .font(.caption2)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Replies section
            if !isReply && showReplies && !comment.replies.isEmpty {
                VStack(spacing: 8) {
                    ForEach(comment.replies) { reply in
                        CommentRowView(comment: reply, isReply: true)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

struct PostCardView: View {
    let post: SpendingPost
    let onLike: () -> Void
    let onComment: () -> Void
    let onShare: () -> Void
    let feedViewModel: FeedViewModel
    
    @State private var comments: [Comment] = []
    @State private var showingAllComments = false
    @State private var isLoadingComments = false
    @State private var commentText = ""
    @State private var showingShareSheet = false
    @State private var cancellables = Set<AnyCancellable>()
    
    // 分享内容
    private var shareItems: [Any] {
        return ShareHelper.generateShareContent(for: post)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with user info
            HStack {
                // User avatar with lighter category color
                Text(post.user.avatarEmoji)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(post.category.color.lighter(by: 0.3))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.user.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("@\(post.user.username)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(post.timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let location = post.location {
                        Label(location, systemImage: "location.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Spending info card with very light category color background
            HStack {
                // Category icon with medium category color
                Text(post.category.emoji)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(post.category.color.lighter(by: 0.4))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(post.merchantName)
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text(post.formattedAmount)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(post.category.color.darker())
                    }
                    
                    HStack {
                        Text(post.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Emotion
                        HStack(spacing: 4) {
                            Text(post.emotion.rawValue)
                                .font(.caption)
                            Text(post.emotion.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(post.category.color.veryLight(by: 0.15))
            )
            
            // Caption
            if !post.caption.isEmpty {
                Text(post.caption)
                    .font(.body)
                    .lineLimit(nil)
            }
            
            // Social actions
            HStack(spacing: 24) {
                // Like button
                Button(action: onLike) {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLikedByCurrentUser ? "heart.fill" : "heart")
                            .foregroundColor(post.isLikedByCurrentUser ? .red : .secondary)
                        
                        if post.likesCount > 0 {
                            Text("\(post.likesCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Comment button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingAllComments.toggle()
                    }
                    
                    if showingAllComments && comments.isEmpty {
                        loadComments()
                    }
                    
                    onComment()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.secondary)
                        
                        if post.commentsCount > 0 {
                            Text("\(post.commentsCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Share button
                Button(action: {
                    showingShareSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.secondary)
                        
                        if post.sharesCount > 0 {
                            Text("\(post.sharesCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .nativeShareSheet(isPresented: $showingShareSheet, items: shareItems) {
                    // for debug logging
                    print("📤 Share sheet presented")
                }
                
                Spacer()
            }
            .font(.subheadline)
            
            // Comments section
            if showingAllComments {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                    
                    // Add comment field
                    HStack {
                        TextField("Add a comment...", text: $commentText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Post") {
                            if !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                feedViewModel.addComment(to: post, content: commentText)
                                commentText = ""
                                // Reload comments after adding
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    loadComments()
                                }
                            }
                        }
                        .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    // Comments list
                    if isLoadingComments {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading comments...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    } else if comments.isEmpty {
                        HStack {
                            Image(systemName: "bubble.left")
                                .foregroundColor(.secondary)
                            Text("No comments yet")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    } else {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(comments) { comment in
                                CommentRowView(comment: comment, isReply: false)
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else if post.commentsCount > 0 && !comments.isEmpty {
                // Preview of latest comment
                if let latestComment = comments.first {
                    CommentRowView(comment: latestComment, isReply: false)
                        .opacity(0.8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .onAppear {
            // Load preview comments when card appears
            if !comments.isEmpty == false && post.commentsCount > 0 {
                loadComments()
            }
        }
    }
    
    private func loadComments() {
        isLoadingComments = true
        
        feedViewModel.getComments(for: post)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoadingComments = false
                    if case .failure(let error) = completion {
                        print("Failed to load comments: \(error)")
                    }
                },
                receiveValue: { loadedComments in
                    comments = loadedComments
                }
            )
            .store(in: &cancellables)
    }
} 
