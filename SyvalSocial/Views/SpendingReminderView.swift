import SwiftUI

struct SpendingReminderView: View {
    @StateObject private var reminderService = SpendingReminderService.shared
    @State private var selectedTab = 0
    @State private var showingAddReminder = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 统计卡片
                StatsCardView(stats: reminderService.stats)
                    .padding()
                
                // 分段控制器
                Picker("View", selection: $selectedTab) {
                    Text("Issues").tag(0)
                    Text("Reminders").tag(1)
                    Text("History").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // 内容区域
                TabView(selection: $selectedTab) {
                    IssuesListView()
                        .tag(0)
                    
                    RemindersListView()
                        .tag(1)
                    
                    ReminderHistoryView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Spending Reminders")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddReminder = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView()
            }
        }
        .environmentObject(reminderService)
    }
}

// MARK: - 统计卡片
struct StatsCardView: View {
    let stats: ReminderStats
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                StatItemView(
                    title: "Active Reminders",
                    value: "\(stats.activeReminders)",
                    icon: "bell.fill",
                    color: .blue
                )
                
                StatItemView(
                    title: "Triggered Today",
                    value: "\(stats.triggeredToday)",
                    icon: "calendar",
                    color: .orange
                )
            }
            
            HStack(spacing: 20) {
                StatItemView(
                    title: "Problems Solved",
                    value: "\(stats.problemsSolved)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatItemView(
                    title: "Estimated Savings",
                    value: String(format: "$%.0f", stats.moneySaved),
                    icon: "dollarsign.circle.fill",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatItemView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 问题列表视图
struct IssuesListView: View {
    @EnvironmentObject var reminderService: SpendingReminderService
    @State private var showingAddIssue = false
    
    var body: some View {
        List {
            ForEach(reminderService.spendingIssues) { issue in
                IssueRowView(issue: issue)
            }
            .onDelete(perform: deleteIssues)
        }
        .listStyle(PlainListStyle())
        .overlay(
            Group {
                if reminderService.spendingIssues.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("No Issue Records")
                            .font(.headline)
                        
                        Text("Record spending issues here when you find them")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
        )
    }
    
    private func deleteIssues(offsets: IndexSet) {
        for index in offsets {
            let issue = reminderService.spendingIssues[index]
            reminderService.deleteIssue(issue.id)
        }
    }
}

struct IssueRowView: View {
    let issue: SpendingIssue
    @EnvironmentObject var reminderService: SpendingReminderService
    
    var body: some View {
        HStack(spacing: 12) {
            // 问题类型图标
            VStack {
                Text(issue.issueType.emoji)
                    .font(.title2)
                
                // 严重程度指示器
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { level in
                        Circle()
                            .fill(level <= issue.severity ? Color.red : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(issue.issueType.displayName)
                        .font(.headline)
                        .foregroundColor(issue.issueType.color)
                    
                    Spacer()
                    
                    if issue.isResolved {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                Text(issue.description)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(issue.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing) {
            if !issue.isResolved {
                Button("Resolve") {
                    reminderService.resolveIssue(issue.id, note: "Resolved")
                }
                .tint(.green)
            }
            
            Button("Delete") {
                reminderService.deleteIssue(issue.id)
            }
            .tint(.red)
        }
    }
}

// MARK: - 提醒规则列表
struct RemindersListView: View {
    @EnvironmentObject var reminderService: SpendingReminderService
    
    var body: some View {
        List {
            ForEach(reminderService.reminders) { reminder in
                ReminderRowView(reminder: reminder)
            }
            .onDelete(perform: deleteReminders)
        }
        .listStyle(PlainListStyle())
        .overlay(
            Group {
                if reminderService.reminders.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Reminder Rules")
                            .font(.headline)
                        
                        Text("Tap the + button in the top right to add new reminder rules")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
        )
    }
    
    private func deleteReminders(offsets: IndexSet) {
        for index in offsets {
            let reminder = reminderService.reminders[index]
            reminderService.deleteReminder(reminder.id)
        }
    }
}

struct ReminderRowView: View {
    let reminder: SpendingReminder
    @EnvironmentObject var reminderService: SpendingReminderService
    
    var body: some View {
        HStack(spacing: 12) {
            VStack {
                Text(reminder.issueType.emoji)
                    .font(.title2)
                
                if reminder.isActive {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.headline)
                    .foregroundColor(reminder.isActive ? .primary : .secondary)
                
                Text(reminder.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(reminder.frequency.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                    
                    if reminder.reminderCount > 0 {
                        Text("Triggered \(reminder.reminderCount) times")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .opacity(reminder.isActive ? 1.0 : 0.6)
        .swipeActions(edge: .trailing) {
            Button(reminder.isActive ? "Disable" : "Enable") {
                reminderService.toggleReminder(reminder.id)
            }
            .tint(reminder.isActive ? .orange : .green)
            
            Button("Delete") {
                reminderService.deleteReminder(reminder.id)
            }
            .tint(.red)
        }
    }
}

// MARK: - 历史记录视图
struct ReminderHistoryView: View {
    @EnvironmentObject var reminderService: SpendingReminderService
    
    var body: some View {
        List {
            ForEach(reminderService.reminderHistory) { history in
                HistoryRowView(history: history)
            }
        }
        .listStyle(PlainListStyle())
        .overlay(
            Group {
                if reminderService.reminderHistory.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No History Records")
                            .font(.headline)
                        
                        Text("Records will appear here after reminders are triggered")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
        )
    }
}

struct HistoryRowView: View {
    let history: ReminderHistory
    @EnvironmentObject var reminderService: SpendingReminderService
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.fill")
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                if let reminder = reminderService.reminders.first(where: { $0.id == history.reminderId }) {
                    Text(reminder.title)
                        .font(.headline)
                } else {
                    Text("Deleted Reminder")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Text(history.triggerContext)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(history.triggeredAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if history.wasActedUpon {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 添加提醒视图
struct AddReminderView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var reminderService: SpendingReminderService
    
    @State private var title = ""
    @State private var message = ""
    @State private var selectedIssueType = SpendingIssueType.unnecessaryPurchase
    @State private var selectedFrequency = ReminderFrequency.once
    @State private var merchantName = ""
    @State private var category = ""
    @State private var amountThreshold = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("提醒标题", text: $title)
                    TextField("提醒内容", text: $message, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("提醒设置")) {
                    Picker("问题类型", selection: $selectedIssueType) {
                        ForEach(SpendingIssueType.allCases, id: \.self) { type in
                            HStack {
                                Text(type.emoji)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                    
                    Picker("提醒频率", selection: $selectedFrequency) {
                        ForEach(ReminderFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.displayName).tag(frequency)
                        }
                    }
                }
                
                Section(header: Text("触发条件"), footer: Text("设置触发提醒的具体条件")) {
                    TextField("特定商家（可选）", text: $merchantName)
                    TextField("特定类别（可选）", text: $category)
                    TextField("金额阈值（可选）", text: $amountThreshold)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveReminder()
                    }
                    .disabled(title.isEmpty || message.isEmpty)
                }
            }
        }
    }
    
    private func saveReminder() {
        let trigger = ReminderTrigger(
            merchantName: merchantName.isEmpty ? nil : merchantName,
            category: category.isEmpty ? nil : category,
            amountThreshold: amountThreshold.isEmpty ? nil : Double(amountThreshold),
            timeOfDay: nil,
            dayOfWeek: nil,
            dayOfMonth: nil
        )
        
        let reminder = SpendingReminder(
            title: title,
            message: message,
            issueType: selectedIssueType,
            frequency: selectedFrequency,
            trigger: trigger
        )
        
        reminderService.addReminder(reminder)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    SpendingReminderView()
} 
