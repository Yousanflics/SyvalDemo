import Foundation
import Combine

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var notifications: [AppNotification] = []
    @Published var unreadCount: Int = 0
    
    private let mockUsers: [User] = [
        User(username: "haruka", displayName: "Haruka", avatarEmoji: "👩🏻‍💻", followersCount: 1024, followingCount: 256),
        User(username: "alex", displayName: "Alex Chen", avatarEmoji: "👨🏻‍🎨", followersCount: 892, followingCount: 178),
        User(username: "sarah", displayName: "Sarah Kim", avatarEmoji: "👩🏻‍🌾", followersCount: 567, followingCount: 234),
        User(username: "mike", displayName: "Mike Johnson", avatarEmoji: "👨🏻‍🍳", followersCount: 345, followingCount: 123),
        User(username: "emma", displayName: "Emma Wilson", avatarEmoji: "👩🏻‍🎤", followersCount: 789, followingCount: 456)
    ]
    
    private init() {
        generateMockNotifications()
        updateUnreadCount()
    }
    
    private func generateMockNotifications() {
        let now = Date()
        let calendar = Calendar.current
        
        notifications = [
            // 最新通知 - 8分钟前
            AppNotification(
                type: .like,
                fromUser: mockUsers[0],
                timestamp: calendar.date(byAdding: .minute, value: -8, to: now) ?? now,
                isRead: false,
                relatedPostId: UUID()
            ),
            
            AppNotification(
                type: .friendRequest,
                fromUser: mockUsers[0],
                timestamp: calendar.date(byAdding: .minute, value: -8, to: now) ?? now,
                isRead: false,
                actionId: UUID()
            ),
            
            // 1小时前
            AppNotification(
                type: .comment,
                fromUser: mockUsers[1],
                message: "Love this spending breakdown! Very helpful 💰",
                timestamp: calendar.date(byAdding: .hour, value: -1, to: now) ?? now,
                isRead: false,
                relatedPostId: UUID()
            ),
            
            // 2小时前 - 已读
            AppNotification(
                type: .friendAccepted,
                fromUser: mockUsers[2],
                timestamp: calendar.date(byAdding: .hour, value: -2, to: now) ?? now,
                isRead: true
            ),
            
            // 3小时前
            AppNotification(
                type: .follow,
                fromUser: mockUsers[3],
                timestamp: calendar.date(byAdding: .hour, value: -3, to: now) ?? now,
                isRead: false
            ),
            
            // 半天前 - 已读
            AppNotification(
                type: .share,
                fromUser: mockUsers[4],
                timestamp: calendar.date(byAdding: .hour, value: -12, to: now) ?? now,
                isRead: true,
                relatedPostId: UUID()
            ),
            
            // 1天前
            AppNotification(
                type: .like,
                fromUser: mockUsers[1],
                timestamp: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
                isRead: false,
                relatedPostId: UUID()
            ),
            
            // 2天前 - 已读
            AppNotification(
                type: .mention,
                fromUser: mockUsers[2],
                message: "Check out @you in this amazing spending challenge!",
                timestamp: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
                isRead: true,
                relatedPostId: UUID()
            ),
            
            // 3天前
            AppNotification(
                type: .comment,
                fromUser: mockUsers[4],
                message: "Great coffee choice! ☕️",
                timestamp: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
                isRead: false,
                relatedPostId: UUID()
            ),
            
            // 1周前 - 已读
            AppNotification(
                type: .friendAccepted,
                fromUser: mockUsers[3],
                timestamp: calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now,
                isRead: true
            )
        ]
    }
    
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
    }
    
    // MARK: - Public Methods
    
    /// 获取所有通知
    func fetchNotifications() -> AnyPublisher<[AppNotification], Error> {
        return Just(notifications)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /// 标记单个通知为已读
    func markAsRead(notificationId: UUID) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
            updateUnreadCount()
        }
    }
    
    /// 标记所有通知为已读
    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
        updateUnreadCount()
    }
    
    /// 处理好友请求
    func respondToFriendRequest(notificationId: UUID, action: NotificationAction) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
            
            switch action {
            case .accept:
                // 在实际应用中，这里会调用API接受好友请求
                print("Accepted friend request from \(notifications[index].fromUser.displayName)")
                
                // 添加一个新的"好友请求已接受"通知（模拟对方收到的通知）
                let acceptedNotification = AppNotification(
                    type: .friendAccepted,
                    fromUser: notifications[index].fromUser,
                    timestamp: Date(),
                    isRead: false
                )
                notifications.insert(acceptedNotification, at: 0)
                
            case .decline:
                print("Declined friend request from \(notifications[index].fromUser.displayName)")
                
            case .viewed:
                break
            }
            
            updateUnreadCount()
        }
    }
    
    /// 删除通知
    func deleteNotification(notificationId: UUID) {
        notifications.removeAll { $0.id == notificationId }
        updateUnreadCount()
    }
    
    /// 添加新通知（用于测试）
    func addTestNotification() {
        let randomUser = mockUsers.randomElement()!
        let randomType = NotificationType.allCases.randomElement()!
        
        let newNotification = AppNotification(
            type: randomType,
            fromUser: randomUser,
            timestamp: Date(),
            isRead: false,
            relatedPostId: UUID()
        )
        
        notifications.insert(newNotification, at: 0)
        updateUnreadCount()
    }
} 
