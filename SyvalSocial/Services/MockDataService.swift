import Foundation
import Combine

class MockDataService: ObservableObject {
    static let shared = MockDataService()
    
    private init() {
        generateMockPosts()
    }
    
    // MARK: - Mock Data
    
    // MARK: - User Data
    // - DisplayName
    // -
    private var mockUsers: [User] = [
        //
        User(username: "Haruka", displayName: "Haruka_T", avatarEmoji: "💁‍♀️", followersCount: 1200, followingCount: 430),
        User(username: "shein_lover", displayName: "SheinLover", avatarEmoji: "🧝‍♀️", followersCount: 890, followingCount: 234),
        User(username: "Aira_att", displayName: "Aria Attar", avatarEmoji: "🙆‍♂️", followersCount: 340, followingCount: 120),
        User(username: "coffee_addict", displayName: "CoffeFox", avatarEmoji: "🦊", followersCount: 567, followingCount: 290),
        User(username: "foodie_life", displayName: "Alex Chen", avatarEmoji: "👨‍💻", followersCount: 2100, followingCount: 678)
    ]
    
    @Published var posts: [SpendingPost] = []
    @Published var currentUser: User = User.mock
    
    private func generateMockPosts() {
        let mockPosts = [
            SpendingPost(
                user: mockUsers[0],
                amount: 6.75,
                category: SpendingCategory.categories[0], // Travel
                merchantName: "Metra",
                description: "Train ticket",
                emotion: .neutral,
                caption: "Needed break so visited suburbia",
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                location: "Chicago, IL",
                isPrivate: false,
                images: ["https://picsum.photos/800/600?random=1"],
                editedAt: nil,
                likesCount: 1,
                commentsCount: 0,
                sharesCount: 0,
                isLikedByCurrentUser: false
            ),
            SpendingPost(
                user: mockUsers[1],
                amount: 43.56,
                category: SpendingCategory.categories[1], // Shopping
                merchantName: "Shein",
                description: "Summer clothes haul",
                emotion: .excited,
                caption: "Got some amazing deals! #reflect",
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                location: nil,
                isPrivate: false,
                images: [
                    "https://picsum.photos/800/600?random=2",
                    "https://picsum.photos/800/600?random=3",
                    "https://picsum.photos/800/600?random=4"
                ],
                editedAt: nil,
                likesCount: 2,
                commentsCount: 1,
                sharesCount: 0,
                isLikedByCurrentUser: true
            ),
            SpendingPost(
                user: mockUsers[2],
                amount: 73.00,
                category: SpendingCategory.categories[6], // Services
                merchantName: "Fort Wayne Storage",
                description: "Monthly storage unit",
                emotion: .regret,
                caption: "Needed storage for the summer, the first month was out of my budget but at least the following month is free #BOGO😭",
                timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                location: "Fort Wayne, IN",
                isPrivate: true,
                images: nil,
                editedAt: nil,
                likesCount: 1,
                commentsCount: 1,
                sharesCount: 0,
                isLikedByCurrentUser: false
            ),
            SpendingPost(
                user: mockUsers[3],
                amount: 8.64,
                category: SpendingCategory.categories[3], // Coffee
                merchantName: "Haraz Coffee",
                description: "Morning latte",
                emotion: .happy,
                caption: "Had a productive day! ☕",
                timestamp: Calendar.current.date(byAdding: .minute, value: -45, to: Date()) ?? Date(),
                location: "Seattle, WA",
                isPrivate: false,
                images: ["https://picsum.photos/800/600?random=5"],
                editedAt: Calendar.current.date(byAdding: .minute, value: -10, to: Date()),
                likesCount: 5,
                commentsCount: 2,
                sharesCount: 1,
                isLikedByCurrentUser: true
            ),
            SpendingPost(
                user: mockUsers[4],
                amount: 24.99,
                category: SpendingCategory.categories[2], // Food
                merchantName: "Joe's Pizza",
                description: "Dinner with friends",
                emotion: .happy,
                caption: "Best pizza in town! Worth every penny 🍕",
                timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date(),
                location: "New York, NY",
                isPrivate: false,
                images: [
                    "https://picsum.photos/800/600?random=6",
                    "https://picsum.photos/800/600?random=7"
                ],
                editedAt: nil,
                likesCount: 8,
                commentsCount: 3,
                sharesCount: 2,
                isLikedByCurrentUser: false
            )
        ]
        
        self.posts = mockPosts
    }
    
    // MARK: - API Simulation Methods
    
    func fetchPosts() -> some Publisher<PostFeedResponse, Error> {
        // Simulate network delay
        return Just(PostFeedResponse(posts: posts, hasMore: false, nextPage: nil))
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            //.eraseToAnyPublisher()
    }
    
    func createPost(_ request: CreatePostRequest) -> AnyPublisher<SpendingPost, Error> {
        let category = SpendingCategory.categories.first { $0.id == request.categoryId } ?? SpendingCategory.categories[0]
        
        let newPost = SpendingPost(
            user: currentUser,
            amount: request.amount,
            category: category,
            merchantName: request.merchantName,
            description: request.description,
            emotion: request.emotion,
            caption: request.caption,
            timestamp: Date(),
            location: request.location,
            isPrivate: request.isPrivate,
            images: request.images,
            editedAt: nil, // New posts have no edit time
            likesCount: 0,
            commentsCount: 0,
            sharesCount: 0,
            isLikedByCurrentUser: false
        )
        
        return Just(newPost)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] post in
                self?.posts.insert(post, at: 0)
            })
            .eraseToAnyPublisher()
    }
    
    func toggleLike(postId: UUID) -> AnyPublisher<Bool, Error> {
        return Just(())
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                if let index = self?.posts.firstIndex(where: { $0.id == postId }) {
                    self?.posts[index].isLikedByCurrentUser.toggle()
                    if self?.posts[index].isLikedByCurrentUser == true {
                        self?.posts[index].likesCount += 1
                    } else {
                        self?.posts[index].likesCount -= 1
                    }
                }
            })
            .map { [weak self] _ in
                self?.posts.first(where: { $0.id == postId })?.isLikedByCurrentUser ?? false
            }
            .eraseToAnyPublisher()
    }
    
    func addComment(postId: UUID, content: String) -> AnyPublisher<Comment, Error> {
        let comment = Comment(
            user: currentUser,
            content: content,
            timestamp: Date(),
            likesCount: 0,
            isLikedByCurrentUser: false
        )
        
        return Just(comment)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                if let index = self?.posts.firstIndex(where: { $0.id == postId }) {
                    self?.posts[index].commentsCount += 1
                }
            })
            .eraseToAnyPublisher()
    }
    
    func getComments(postId: UUID) -> AnyPublisher<[Comment], Error> {
        // Generate rich mock comments based on post
        let mockComments = generateCommentsForPost(postId: postId)
        
        return Just(mockComments)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func deletePost(postId: UUID) -> AnyPublisher<Bool, Error> {
        return Just(())
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.posts.removeAll { $0.id == postId }
            })
            .map { _ in true }
            .eraseToAnyPublisher()
    }
    
    func updatePost(_ request: UpdatePostRequest) -> AnyPublisher<SpendingPost, Error> {
        return Just(())
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .compactMap { [weak self] _ -> SpendingPost? in
                guard let self = self,
                      let index = self.posts.firstIndex(where: { $0.id == request.postId }) else { 
                    return nil 
                }
                
                let existingPost = self.posts[index]
                let category = SpendingCategory.categories.first { $0.id == request.categoryId } ?? SpendingCategory.categories[0]
                
                // Update the post while preserving original timestamp and social metrics
                let updatedPost = SpendingPost(
                    user: existingPost.user,
                    amount: request.amount,
                    category: category,
                    merchantName: request.merchantName,
                    description: request.description,
                    emotion: request.emotion,
                    caption: request.caption,
                    timestamp: existingPost.timestamp, // Keep original timestamp
                    location: request.location,
                    isPrivate: request.isPrivate,
                    images: request.images,
                    editedAt: Date(), // Set edited timestamp
                    likesCount: existingPost.likesCount, // Preserve social metrics
                    commentsCount: existingPost.commentsCount,
                    sharesCount: existingPost.sharesCount,
                    isLikedByCurrentUser: existingPost.isLikedByCurrentUser
                )
                
                self.posts[index] = updatedPost
                return updatedPost
            }
            .eraseToAnyPublisher()
    }
    
    private func generateCommentsForPost(postId: UUID) -> [Comment] {
        guard let post = posts.first(where: { $0.id == postId }) else { return [] }
        
        var comments: [Comment] = []
        
        switch post.merchantName {
        case "Shein":
            // Comment with 2 replies (should show "View 2 replies")
            let comment1 = Comment(
                user: mockUsers[0],
                content: "Ooh I love their summer collection! 😍",
                timestamp: Calendar.current.date(byAdding: .minute, value: -45, to: Date()) ?? Date(),
                likesCount: 3,
                isLikedByCurrentUser: true
            )
            
            let reply1 = Comment(
                user: mockUsers[1],
                content: "Right?! And the prices are unbeatable 💕",
                timestamp: Calendar.current.date(byAdding: .minute, value: -40, to: Date()) ?? Date(),
                likesCount: 1,
                isLikedByCurrentUser: false,
                parentCommentId: comment1.id
            )
            
            let reply2 = Comment(
                user: mockUsers[3],
                content: "Can you share the link? 👀",
                timestamp: Calendar.current.date(byAdding: .minute, value: -35, to: Date()) ?? Date(),
                likesCount: 0,
                isLikedByCurrentUser: false,
                parentCommentId: comment1.id
            )
            
            var comment1WithReplies = comment1
            comment1WithReplies.replies = [reply1, reply2]
            comments.append(comment1WithReplies)
            
        case "Haraz Coffee":
            // Comment with no replies
            let comment1 = Comment(
                user: mockUsers[1],
                content: "Great choice! 👍",
                timestamp: Calendar.current.date(byAdding: .minute, value: -30, to: Date()) ?? Date(),
                likesCount: 2,
                isLikedByCurrentUser: false
            )
            comments.append(comment1)
            
            // Comment with 1 reply (should show reply directly, no button)
            let comment2 = Comment(
                user: mockUsers[4],
                content: "Their Ethiopian beans are amazing! ☕",
                timestamp: Calendar.current.date(byAdding: .minute, value: -25, to: Date()) ?? Date(),
                likesCount: 4,
                isLikedByCurrentUser: true
            )
            
            let reply1 = Comment(
                user: mockUsers[3],
                content: "Thanks for the recommendation! I'll try them next time 😊",
                timestamp: Calendar.current.date(byAdding: .minute, value: -20, to: Date()) ?? Date(),
                likesCount: 1,
                isLikedByCurrentUser: false,
                parentCommentId: comment2.id
            )
            
            var comment2WithReplies = comment2
            comment2WithReplies.replies = [reply1]
            comments.append(comment2WithReplies)
            
        case "Joe's Pizza":
            // Comment with 1 reply (should show reply directly)
            let comment1 = Comment(
                user: mockUsers[0],
                content: "OMG yes! Best pizza in NYC 🍕",
                timestamp: Calendar.current.date(byAdding: .minute, value: -50, to: Date()) ?? Date(),
                likesCount: 5,
                isLikedByCurrentUser: true
            )
            
            let reply1 = Comment(
                user: mockUsers[1],
                content: "Adding this to my must-try list!",
                timestamp: Calendar.current.date(byAdding: .minute, value: -30, to: Date()) ?? Date(),
                likesCount: 1,
                isLikedByCurrentUser: false,
                parentCommentId: comment1.id
            )
            
            var comment1WithReplies = comment1
            comment1WithReplies.replies = [reply1]
            comments.append(comment1WithReplies)
            
            // Comment with 3 replies (should show "View 3 replies")
            let comment2 = Comment(
                user: mockUsers[2],
                content: "The pepperoni slice is my favorite!",
                timestamp: Calendar.current.date(byAdding: .minute, value: -40, to: Date()) ?? Date(),
                likesCount: 2,
                isLikedByCurrentUser: false
            )
            
            let reply2_1 = Comment(
                user: mockUsers[4],
                content: "We got the margherita and it was perfect! 🤤",
                timestamp: Calendar.current.date(byAdding: .minute, value: -35, to: Date()) ?? Date(),
                likesCount: 3,
                isLikedByCurrentUser: false,
                parentCommentId: comment2.id
            )
            
            let reply2_2 = Comment(
                user: mockUsers[3],
                content: "I love their garlic knots too!",
                timestamp: Calendar.current.date(byAdding: .minute, value: -32, to: Date()) ?? Date(),
                likesCount: 2,
                isLikedByCurrentUser: true,
                parentCommentId: comment2.id
            )
            
            let reply2_3 = Comment(
                user: mockUsers[1],
                content: "Best late night food spot!",
                timestamp: Calendar.current.date(byAdding: .minute, value: -28, to: Date()) ?? Date(),
                likesCount: 4,
                isLikedByCurrentUser: false,
                parentCommentId: comment2.id
            )
            
            var comment2WithReplies = comment2
            comment2WithReplies.replies = [reply2_1, reply2_2, reply2_3]
            comments.append(comment2WithReplies)
            
        case "Fort Wayne Storage":
            // Comment with no replies
            let comment1 = Comment(
                user: mockUsers[4],
                content: "Storage units are so expensive these days 😮‍💨",
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
                likesCount: 1,
                isLikedByCurrentUser: false
            )
            comments.append(comment1)
            
        case "Metra":
            // Comment with 4 replies (should show "View 4 replies")
            let comment1 = Comment(
                user: mockUsers[2],
                content: "Love taking the train to the suburbs!",
                timestamp: Calendar.current.date(byAdding: .minute, value: -60, to: Date()) ?? Date(),
                likesCount: 3,
                isLikedByCurrentUser: false
            )
            
            let reply1 = Comment(
                user: mockUsers[1],
                content: "Much better than driving in traffic",
                timestamp: Calendar.current.date(byAdding: .minute, value: -55, to: Date()) ?? Date(),
                likesCount: 2,
                isLikedByCurrentUser: true,
                parentCommentId: comment1.id
            )
            
            let reply2 = Comment(
                user: mockUsers[3],
                content: "The scenery is beautiful too",
                timestamp: Calendar.current.date(byAdding: .minute, value: -50, to: Date()) ?? Date(),
                likesCount: 1,
                isLikedByCurrentUser: false,
                parentCommentId: comment1.id
            )
            
            let reply3 = Comment(
                user: mockUsers[4],
                content: "I read books during the ride",
                timestamp: Calendar.current.date(byAdding: .minute, value: -45, to: Date()) ?? Date(),
                likesCount: 3,
                isLikedByCurrentUser: false,
                parentCommentId: comment1.id
            )
            
            let reply4 = Comment(
                user: mockUsers[0],
                content: "Perfect for catching up on podcasts!",
                timestamp: Calendar.current.date(byAdding: .minute, value: -40, to: Date()) ?? Date(),
                likesCount: 2,
                isLikedByCurrentUser: true,
                parentCommentId: comment1.id
            )
            
            var comment1WithReplies = comment1
            comment1WithReplies.replies = [reply1, reply2, reply3, reply4]
            comments.append(comment1WithReplies)
            
        default:
            // Comment with 1 reply for default case
            let comment1 = Comment(
                user: mockUsers[1],
                content: "Nice purchase! 👍",
                timestamp: Calendar.current.date(byAdding: .minute, value: -30, to: Date()) ?? Date(),
                likesCount: 1,
                isLikedByCurrentUser: false
            )
            
            let reply1 = Comment(
                user: mockUsers[2],
                content: "Looks like a good deal!",
                timestamp: Calendar.current.date(byAdding: .minute, value: -25, to: Date()) ?? Date(),
                likesCount: 0,
                isLikedByCurrentUser: false,
                parentCommentId: comment1.id
            )
            
            var comment1WithReplies = comment1
            comment1WithReplies.replies = [reply1]
            comments.append(comment1WithReplies)
        }
        
        // Update the post's comment count to match actual generated comments
        // Count root comments + all reply comments
        let totalComments = comments.reduce(0) { count, comment in
            return count + 1 + comment.replies.count // root comment + replies
        }
        
        // Update the post's commentsCount to match the actual data
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts[index].commentsCount = totalComments
        }
        
        return comments
    }
} 
