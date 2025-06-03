import SwiftUI
import Combine

struct PostDetailView: View {
    let post: SpendingPost
    @StateObject private var feedViewModel: FeedViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var comments: [Comment] = []
    @State private var isLoadingComments = false
    @State private var commentText = ""
    @State private var showingShareSheet = false
    @State private var expandedComments: Set<UUID> = []
    @State private var cancellables = Set<AnyCancellable>()
    @FocusState private var isCommentFieldFocused: Bool
    @State private var showingPrivacyTooltip = false
    @State private var privacyIconPosition: CGRect = .zero
    
    // Follow state - in a real app, this would be managed by a user service
    @State private var isFollowing = false
    
    init(post: SpendingPost, feedViewModel: FeedViewModel) {
        self.post = post
        self._feedViewModel = StateObject(wrappedValue: feedViewModel)
    }
    
    var body: some View {
        ZStack {
            // Main content
            ZStack {
                // set all detailview background color
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Main content in scroll view
                    ScrollView {
                        VStack(alignment: .leading) {//, spacing: 16
                            // Post content
                            postContentView
                                .padding(.top, 16)
                            
                            // Divider
    //                        Divider()
    //                            .padding(.horizontal)
                            
                            // Comments section
                            commentsSection
                                .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 80) // Space for bottom panel
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isCommentFieldFocused = false
                            if showingPrivacyTooltip {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showingPrivacyTooltip = false
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    
                    // Bottom comment panel
                    bottomCommentPanel
                }
            }
            .onPreferenceChange(PrivacyIconPositionKey.self) { position in
                privacyIconPosition = position
            }
            
            // Overlay tooltip
            if showingPrivacyTooltip {
                VStack(spacing: 0) {
                    // Arrow pointing up
                    Triangle()
                        .fill(Color(.systemBackground))
                        .frame(width: 12, height: 6)
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: -1)
                    
                    // Tooltip content
                    Text("This post is visible to \(post.isPrivate ? "yourself" : "anyone on Syval")")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                        )
                }
                .position(
                    x: privacyIconPosition.midX,
                    y: privacyIconPosition.maxY + 20
                )
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                .zIndex(1000)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.callout)
                            .fontWeight(.light)
                            .foregroundColor(.primary)
                    }
                    
                    Text(post.user.avatarEmoji)
                        .font(.title3)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(post.category.color.lighter(by: 0.3))
                        )
                    
                    Text(post.user.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    Button(action: { toggleFollow() }) {
                        Text("Follow")
                            .font(Font.system(size: 13))
                            .fontWeight(.bold)
                            .foregroundColor(isFollowing ? .white : .indigo)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(isFollowing ? Color.indigo : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.indigo, lineWidth: 1)
                                    )
                            )
                    }
                    
                    Button(action: { showingShareSheet = true }) {
                        Image(systemName: "arrowshape.turn.up.right")
                            .font(.callout)
                            .fontWeight(.light)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .nativeShareSheet(isPresented: $showingShareSheet, items: ShareHelper.generateShareContent(for: post))
        .task {
            loadComments()
        }
    }
    
    private var postContentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                // Spending info card
                SpendingInfoCard(post: post)
                
                // Full caption
                if !post.caption.isEmpty {
                    Text(post.caption)
                        .font(.body)
                        .lineLimit(nil)
                }
                
                // Post metadata
                HStack {
                    if post.isEdited {
                        Text("Edited")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(post.timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let location = post.location {
                        Label(location, systemImage: "location.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
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
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: PrivacyIconPositionKey.self, 
                                          value: geometry.frame(in: .global))
                        }
                    )
                }
            }
            .padding(.horizontal)
            
            // Group photos view - full width without horizontal padding
            if let images = post.images, !images.isEmpty {
                GroupPhotosView(images: images)
            }
        }
    }
    
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isLoadingComments {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading comments...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
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
                .padding(.horizontal)
            } else {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(comments) { comment in
                        DetailCommentRowView(
                            comment: comment,
                            isReply: false,
                            isExpanded: expandedComments.contains(comment.id),
                            onToggleExpand: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if expandedComments.contains(comment.id) {
                                        expandedComments.remove(comment.id)
                                    } else {
                                        expandedComments.insert(comment.id)
                                    }
                                }
                            },
                            onLike: {
                                // Handle comment like
                            }
                        )
                    }
                }
            }
        }
    }
    
    private var bottomCommentPanel: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 16) {
                // Comment input
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("Add Comments...", text: $commentText)
                            .font(.subheadline)
                            .focused($isCommentFieldFocused)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(.systemGray6))
                    )
                    
//                    Button("Post") {
//                        if !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                            feedViewModel.addComment(to: post, content: commentText)
//                            commentText = ""
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                loadComments()
//                            }
//                        }
//                    }
//                    .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                Spacer()
                
                // Like button
                Button(action: { feedViewModel.toggleLike(for: post) }) {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLikedByCurrentUser ? "heart.fill" : "heart")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(post.isLikedByCurrentUser ? .red : .adaptiveText)
                        
                        Text("\(post.likesCount)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.adaptiveText)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Comment count
                HStack(spacing: 6) {
                    Image(systemName: "bubble.right")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.adaptiveText)
                    
                    Text("\(post.commentsCount)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.adaptiveText)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
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
                    // The comment count should already be updated by the MockDataService
                    // when generateCommentsForPost is called
                }
            )
            .store(in: &cancellables)
    }
    
    private func toggleFollow() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isFollowing.toggle()
        }
    }
}

// MARK: - Detail Comment Row View
struct DetailCommentRowView: View {
    let comment: Comment
    let isReply: Bool
    let isExpanded: Bool
    let onToggleExpand: () -> Void
    let onLike: () -> Void
    
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
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color(.systemGray5))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    // Comment header
                    HStack {
                        Text(comment.user.displayName)
                            .font(Font.system(size: 15, weight: .semibold))
                            .fontWeight(.semibold)
                        
                        Text(comment.timeAgo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    // Comment content
                    Text(comment.content)
                        .font(Font.system(size: 15))
                        .lineLimit(nil)
                }
                
                // Like button
                Button(action: onLike) {
                    VStack(spacing: 2) {
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
                .buttonStyle(PlainButtonStyle())
            }
            
            // Replies section
            if !isReply && !comment.replies.isEmpty {
                VStack(spacing: 8) {
                    if comment.replies.count == 1 {
                        // If only one reply, show it directly without expand button
                        DetailCommentRowView(
                            comment: comment.replies[0],
                            isReply: true,
                            isExpanded: false,
                            onToggleExpand: {},
                            onLike: {}
                        )
                    } else if comment.replies.count > 1 {
                        // If multiple replies, always show first reply
                        DetailCommentRowView(
                            comment: comment.replies[0],
                            isReply: true,
                            isExpanded: false,
                            onToggleExpand: {},
                            onLike: {}
                        )
                        
                        // Show expand button after first reply if there are more replies
                        if !isExpanded {
                            Button(action: onToggleExpand) {
                                HStack(spacing: 4) {
                                    // Reduced indentation to align closer to the left
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: 8) // Reduced from 20 to 8
                                    
                                    Text("View \(comment.replies.count - 1) replies")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        // Show remaining replies when expanded
                        if isExpanded {
                            ForEach(comment.replies.indices.dropFirst(), id: \.self) { index in
                                DetailCommentRowView(
                                    comment: comment.replies[index],
                                    isReply: true,
                                    isExpanded: false,
                                    onToggleExpand: {},
                                    onLike: {}
                                )
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Triangle Shape for Tooltip Arrow
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        
        return path
    }
}

// MARK: - PreferenceKey for Privacy Icon Position
struct PrivacyIconPositionKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
} 
