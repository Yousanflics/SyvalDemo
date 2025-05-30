import SwiftUI

struct NotificationCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationService = NotificationService.shared
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if notificationService.notifications.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No Notifications")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("You're all caught up! New notifications will appear here.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    // Notifications list
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(notificationService.notifications) { notification in
                                NotificationRowView(
                                    notification: notification,
                                    onTap: {
                                        handleNotificationTap(notification)
                                    },
                                    onFriendResponse: { action in
                                        notificationService.respondToFriendRequest(
                                            notificationId: notification.id,
                                            action: action
                                        )
                                    }
                                )
                                .background(
                                    notification.isRead ? Color.clear : Color.blue.opacity(0.05)
                                )
                                
                                if notification.id != notificationService.notifications.last?.id {
                                    Divider()
                                        .padding(.leading, 60)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    .refreshable {
                        await refreshNotifications()
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Mark Read") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            notificationService.markAllAsRead()
                        }
                    }
                    .foregroundColor(.blue)
                    .disabled(notificationService.unreadCount == 0)
                }
            }
        }
        .onAppear {
            loadNotifications()
        }
    }
    
    private func loadNotifications() {
        isLoading = true
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
        }
    }
    
    private func refreshNotifications() async {
        // 模拟刷新数据
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
        // 这里可以添加新的通知或重新获取数据
    }
    
    private func handleNotificationTap(_ notification: AppNotification) {
        // 标记为已读
        notificationService.markAsRead(notificationId: notification.id)
        
        // 根据通知类型执行不同操作
        switch notification.type {
        case .like, .comment, .share:
            // 导航到相关帖子
            if let postId = notification.relatedPostId {
                print("Navigate to post: \(postId)")
                // 在实际应用中，这里会导航到对应的帖子详情页
            }
        case .friendRequest:
            // 已经在 NotificationRowView 中处理
            break
        case .friendAccepted, .follow:
            // 导航到用户资料页
            print("Navigate to user profile: \(notification.fromUser.username)")
        case .mention:
            // 导航到提及的帖子
            if let postId = notification.relatedPostId {
                print("Navigate to mentioned post: \(postId)")
            }
        }
    }
}

// MARK: - 通知行视图
struct NotificationRowView: View {
    let notification: AppNotification
    let onTap: () -> Void
    let onFriendResponse: ((NotificationAction) -> Void)?
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // 用户头像
                ZStack {
                    Text(notification.fromUser.avatarEmoji)
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color(.systemGray6))
                        )
                    
                    // 通知类型图标
                    Image(systemName: notification.type.iconName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.hex(notification.type.iconColor))
                        .frame(width: 16, height: 16)
                        .background(
                            Circle()
                                .fill(Color(.systemBackground))
                        )
                        .offset(x: 14, y: 14)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // 通知消息
                    Text(notification.displayMessage)
                        .font(.body)
                        .fontWeight(notification.isRead ? .regular : .medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    // 附加消息（如评论内容）
                    if !notification.message.isEmpty {
                        Text(notification.message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    // 好友请求按钮
                    if notification.type == .friendRequest && !notification.isRead {
                        HStack(spacing: 8) {
                            Button("Accept") {
                                onFriendResponse?(.accept)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                            
                            Button("Decline") {
                                onFriendResponse?(.decline)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        .padding(.top, 4)
                    }
                    
                    // 时间戳
                    Text(notification.timeAgo)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 未读标识
                if !notification.isRead {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NotificationCenterView()
} 
