import Foundation
import SwiftUI

// MARK: - Core Models

struct User: Identifiable, Codable {
    let id = UUID()
    let username: String
    let displayName: String
    let avatarEmoji: String
    var followersCount: Int
    var followingCount: Int
    
    static let mock = User(
        username: "young027",
        displayName: "Young",
        avatarEmoji: "👨‍💻",
        followersCount: 234,
        followingCount: 145
    )
}

struct SpendingCategory: Identifiable, Codable {
    let id = UUID()
    let name: String
    let emoji: String
    let colorName: String
    
    // Computed property to get SwiftUI Color from colorName
    var color: Color {
        switch colorName {
        case "blue": return .blue
        case "pink": return .pink
        case "orange": return .orange
        case "brown": return .brown
        case "purple": return .purple
        case "green": return .green
        case "gray": return .gray
        case "red": return .red
        default: return .blue
        }
    }
    
    static let categories = [
        SpendingCategory(name: "Travel", emoji: "✈️", colorName: "blue"),
        SpendingCategory(name: "Shopping", emoji: "🛍️", colorName: "pink"),
        SpendingCategory(name: "Food", emoji: "🍕", colorName: "orange"),
        SpendingCategory(name: "Coffee", emoji: "☕", colorName: "brown"),
        SpendingCategory(name: "Entertainment", emoji: "🎬", colorName: "purple"),
        SpendingCategory(name: "Transport", emoji: "🚗", colorName: "green"),
        SpendingCategory(name: "Services", emoji: "⚙️", colorName: "gray"),
        SpendingCategory(name: "Health", emoji: "💊", colorName: "red")
    ]
}

enum EmotionType: String, CaseIterable, Codable {
    case happy = "😊"
    case neutral = "😐"
    case sad = "😢"
    case excited = "🤩"
    case regret = "😔"
    case proud = "😎"
    
    var description: String {
        switch self {
        case .happy: return "Happy"
        case .neutral: return "Neutral"
        case .sad: return "Sad"
        case .excited: return "Excited"
        case .regret: return "Regret"
        case .proud: return "Proud"
        }
    }
}

struct SpendingPost: Identifiable, Codable {
    let id = UUID()
    let user: User
    let amount: Double
    let category: SpendingCategory
    let merchantName: String
    let description: String
    let emotion: EmotionType
    let caption: String
    let timestamp: Date
    let location: String?
    let isPrivate: Bool
    
    // Social metrics
    var likesCount: Int
    var commentsCount: Int
    var sharesCount: Int
    var isLikedByCurrentUser: Bool
    
    // Computed properties
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    var formattedAmount: String {
        return String(format: "$%.2f", amount)
    }
}

struct Comment: Identifiable, Codable {
    let id = UUID()
    let user: User
    let content: String
    let timestamp: Date
    let likesCount: Int
    var isLikedByCurrentUser: Bool
    let parentCommentId: UUID? // For replies
    var replies: [Comment] // Nested replies
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    // Initialize without replies
    init(user: User, content: String, timestamp: Date, likesCount: Int = 0, isLikedByCurrentUser: Bool = false, parentCommentId: UUID? = nil) {
        self.user = user
        self.content = content
        self.timestamp = timestamp
        self.likesCount = likesCount
        self.isLikedByCurrentUser = isLikedByCurrentUser
        self.parentCommentId = parentCommentId
        self.replies = []
    }
}

// MARK: - API Response Models

struct PostFeedResponse: Codable {
    let posts: [SpendingPost]
    let hasMore: Bool
    let nextPage: Int?
}

struct CreatePostRequest: Codable {
    let amount: Double
    let categoryId: UUID
    let merchantName: String
    let description: String
    let emotion: EmotionType
    let caption: String
    let location: String?
    let isPrivate: Bool
} 
