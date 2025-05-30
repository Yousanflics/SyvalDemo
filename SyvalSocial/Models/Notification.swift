import Foundation

// MARK: - 通知类型
enum NotificationType: String, CaseIterable, Codable {
    case like = "like"
    case comment = "comment"
    case friendRequest = "friend_request"
    case friendAccepted = "friend_accepted"
    case follow = "follow"
    case mention = "mention"
    case share = "share"
    
    var iconName: String {
        switch self {
        case .like:
            return "heart.fill"
        case .comment:
            return "bubble.left.fill"
        case .friendRequest:
            return "person.badge.plus"
        case .friendAccepted:
            return "person.badge.checkmark"
        case .follow:
            return "person.circle.fill"
        case .mention:
            return "at.circle.fill"
        case .share:
            return "square.and.arrow.up.fill"
        }
    }
    
    var iconColor: String {
        switch self {
        case .like:
            return "#EF4444" // 红色
        case .comment:
            return "#3B82F6" // 蓝色
        case .friendRequest:
            return "#10B981" // 绿色
        case .friendAccepted:
            return "#10B981" // 绿色
        case .follow:
            return "#8B5CF6" // 紫色
        case .mention:
            return "#F59E0B" // 橙色
        case .share:
            return "#6366F1" // 靛蓝色
        }
    }
}

// MARK: - 通知模型
struct AppNotification: Identifiable, Codable {
    let id = UUID()
    let type: NotificationType
    let fromUser: User
    let message: String
    let timestamp: Date
    var isRead: Bool
    let relatedPostId: UUID?
    let actionId: UUID? // 用于好友请求等需要额外ID的情况
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    var displayMessage: String {
        switch type {
        case .like:
            return "\(fromUser.displayName) liked your post"
        case .comment:
            return "\(fromUser.displayName) commented on your post"
        case .friendRequest:
            return "\(fromUser.displayName) sent you a friend request"
        case .friendAccepted:
            return "\(fromUser.displayName) accepted your friend request"
        case .follow:
            return "\(fromUser.displayName) started following you"
        case .mention:
            return "\(fromUser.displayName) mentioned you in a post"
        case .share:
            return "\(fromUser.displayName) shared your post"
        }
    }
    
    init(type: NotificationType, fromUser: User, message: String = "", timestamp: Date = Date(), isRead: Bool = false, relatedPostId: UUID? = nil, actionId: UUID? = nil) {
        self.type = type
        self.fromUser = fromUser
        self.message = message.isEmpty ? "" : message
        self.timestamp = timestamp
        self.isRead = isRead
        self.relatedPostId = relatedPostId
        self.actionId = actionId
    }
}

// MARK: - 通知请求响应类型
enum NotificationAction {
    case accept
    case decline
    case viewed
} 
