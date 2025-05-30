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

// MARK: - Truncated Text View Component
struct TruncatedTextView: View {
    let text: String
    let lineLimit: Int
    let onMoreTapped: () -> Void
    
    @State private var isTruncated = false
    @State private var fullText = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text)
                .font(.body)
                .lineLimit(lineLimit)
                .background(
                    // Hidden text to measure if truncation is needed
                    Text(text)
                        .font(.body)
                        .lineLimit(nil)
                        .background(GeometryReader { geometry in
                            Color.clear.onAppear {
                                let font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
                                let boundingRect = NSString(string: text).boundingRect(
                                    with: CGSize(width: geometry.size.width, height: .greatestFiniteMagnitude),
                                    options: .usesLineFragmentOrigin,
                                    attributes: [.font: font],
                                    context: nil
                                )
                                
                                let singleLineHeight = font.lineHeight
                                let maxAllowedHeight = singleLineHeight * CGFloat(lineLimit)
                                isTruncated = boundingRect.height > maxAllowedHeight
                            }
                        })
                        .hidden()
                )
            
            if isTruncated {
                HStack(spacing: 0) {
                    Text("...")
                        .font(.body)
                    
                    Text(" ")
                        .font(.body)
                        .frame(width: 8) // Slightly larger spacing
                    
                    Button(action: onMoreTapped) {
                        Text("more")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Social Actions View Component
struct SocialActionsView: View {
    let isLiked: Bool
    let likesCount: Int
    let commentsCount: Int
    let sharesCount: Int
    
    let onLike: () -> Void
    let onComment: () -> Void
    let onShare: () -> Void
    let onMore: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            // Like button
            Button(action: onLike) {
                HStack(spacing: 6) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(isLiked ? .red : .black)
                    
                    if likesCount > 0 {
                        Text("\(likesCount)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Comment button
            Button(action: onComment) {
                HStack(spacing: 6) {
                    Image(systemName: "bubble.right")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    if commentsCount > 0 {
                        Text("\(commentsCount)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Share button
            Button(action: onShare) {
                HStack(spacing: 6) {
                    Image(systemName: "arrowshape.turn.up.right")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    if sharesCount > 0 {
                        Text("\(sharesCount)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // More options button
            Button(action: onMore) {
                Image(systemName: "ellipsis")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
            }
            .buttonStyle(PlainButtonStyle())
        }
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
                                .font(.caption)
                                .fontWeight(.semibold)
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
    @State private var showingActionSheet = false
    @State private var showingEditPost = false
    @State private var showingPrivacyTooltip = false
    @State private var showingPostDetail = false
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
                    HStack(spacing: 4) {
                        // Edited label if post was edited
                        if post.isEdited {
                            Text("Edited")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(post.timeAgo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Privacy status button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showingPrivacyTooltip.toggle()
                            }
                        }) {
                            Image(systemName: post.isPrivate ? "person.fill" : "globe")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    if let location = post.location {
                        Label(location, systemImage: "location.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    // Privacy tooltip
                    if showingPrivacyTooltip {
                        Text("This post is visible to \(post.isPrivate ? "yourself" : "anyone on Syval")")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(.systemGray6))
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
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
                TruncatedTextView(text: post.caption, lineLimit: 3, onMoreTapped: {
                    showingPostDetail = true
                })
            }
            
            // Social actions
            SocialActionsView(
                isLiked: post.isLikedByCurrentUser,
                likesCount: post.likesCount,
                commentsCount: post.commentsCount,
                sharesCount: post.sharesCount,
                onLike: onLike,
                onComment: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingAllComments.toggle()
                    }
                    
                    if showingAllComments && comments.isEmpty {
                        loadComments()
                    }
                    
                    onComment()
                },
                onShare: {
                    showingShareSheet = true
                    onShare()
                },
                onMore: {
                    showingActionSheet = true
                }
            )
            .nativeShareSheet(isPresented: $showingShareSheet, items: shareItems) {
                // for debug logging
                print("📤 Share sheet presented")
            }
            
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
                                .font(.subheadline)
                                .fontWeight(.semibold)
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
        .contentShape(Rectangle()) // Make entire card tappable
        .onTapGesture {
            // Hide privacy tooltip when tapping elsewhere
            if showingPrivacyTooltip {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showingPrivacyTooltip = false
                }
            } else {
                // Navigate to detail view when tapping anywhere on the card
                showingPostDetail = true
            }
        }
        .onAppear {
            // Load preview comments when card appears
            if !comments.isEmpty == false && post.commentsCount > 0 {
                loadComments()
            }
        }
        .confirmationDialog("Post Options", isPresented: $showingActionSheet, titleVisibility: .visible) {
            Button("Edit Post") {
                showingEditPost = true
            }
            
            Button("Delete Post", role: .destructive) {
                // Handle delete post
                print("Delete post: \(post.id)")
                feedViewModel.deletePost(post)
            }
            
            Button("Cancel", role: .cancel) {
                // Dismiss action sheet
            }
        }
        .sheet(isPresented: $showingEditPost) {
            CreatePostView(editingPost: post)
        }
        .background(
            NavigationLink(
                destination: PostDetailView(post: post, feedViewModel: feedViewModel),
                isActive: $showingPostDetail
            ) {
                EmptyView()
            }
            .hidden()
        )
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
                    // The comment count should already be updated by the MockDataService
                    // when generateCommentsForPost is called
                }
            )
            .store(in: &cancellables)
    }
} 
