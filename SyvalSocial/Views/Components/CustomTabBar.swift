import SwiftUI

struct CustomTabBar: View {
    @StateObject private var notificationService = NotificationService.shared
    @StateObject private var reminderService = SpendingReminderService.shared
    @State private var showingNotifications = false
    @State private var showingReminders = false
    @State private var showingCreatePost = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Reminder Button
            Button(action: {
                showingReminders = true
            }) {
                VStack(spacing: 4) {
                    ZStack {
                        Image(systemName: "bell.badge")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.orange)
                        
                        // Badge for active reminders
                        if reminderService.stats.activeReminders > 0 {
                            Text("\(reminderService.stats.activeReminders)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(minWidth: 16, minHeight: 16)
                                .background(
                                    Circle()
                                        .fill(Color.red)
                                )
                                .offset(x: 10, y: -8)
                        }
                    }
                    .frame(height: 24)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Share Button
            Button(action: {
                showingCreatePost = true
            }) {
                VStack(spacing: 4) {
                    ZStack {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        // Notification badge
                        Text("10")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 18, height: 18)
                            .background(
                                Circle()
                                    .fill(Color.red)
                            )
                            .offset(x: 15, y: -8)
                    }
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.indigo)
                    )
                }
            }
            .frame(maxWidth: .infinity)
            
            // Notification Button
            Button(action: {
                showingNotifications = true
            }) {
                VStack(spacing: 4) {
                    ZStack {
                        Image(systemName: "message")
                            .font(.system(size: 18, weight: .medium))
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
                                .offset(x: 10, y: -8)
                        }
                    }
                    .frame(height: 24)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
            // Glass morphism background
            RoundedRectangle(cornerRadius: 36)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 36)
                        .stroke(Color.white.opacity(1), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 60)
        .sheet(isPresented: $showingCreatePost) {
            CreatePostView()
        }
        .fullScreenCover(isPresented: $showingNotifications) {
            NotificationCenterView()
        }
        .sheet(isPresented: $showingReminders) {
            SpendingReminderView()
        }
    }
}

#Preview {
    VStack {
        Spacer()
        CustomTabBar()
    }
    .background(
        LinearGradient(
            gradient: Gradient(colors: [.green, .blue]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
} 
