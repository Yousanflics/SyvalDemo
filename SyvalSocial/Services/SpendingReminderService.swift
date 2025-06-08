import Foundation
import Combine
import UserNotifications

class SpendingReminderService: ObservableObject {
    static let shared = SpendingReminderService()
    
    // MARK: - Published Properties
    @Published var spendingIssues: [SpendingIssue] = []
    @Published var reminders: [SpendingReminder] = []
    @Published var reminderHistory: [ReminderHistory] = []
    @Published var stats: ReminderStats = .empty
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {
        loadData()
        requestNotificationPermission()
        setupMockData()
    }
    
    // MARK: - Data Persistence
    
    private func loadData() {
        // Load issues records
        if let issuesData = userDefaults.data(forKey: "spending_issues"),
           let issues = try? JSONDecoder().decode([SpendingIssue].self, from: issuesData) {
            spendingIssues = issues
        }
        
        // Load reminder rules
        if let remindersData = userDefaults.data(forKey: "spending_reminders"),
           let remindersArray = try? JSONDecoder().decode([SpendingReminder].self, from: remindersData) {
            reminders = remindersArray
        }
        
        // Load history records
        if let historyData = userDefaults.data(forKey: "reminder_history"),
           let history = try? JSONDecoder().decode([ReminderHistory].self, from: historyData) {
            reminderHistory = history
        }
        
        updateStats()
    }
    
    private func saveData() {
        // Save issues records
        if let issuesData = try? JSONEncoder().encode(spendingIssues) {
            userDefaults.set(issuesData, forKey: "spending_issues")
        }
        
        // Save reminder rules
        if let remindersData = try? JSONEncoder().encode(reminders) {
            userDefaults.set(remindersData, forKey: "spending_reminders")
        }
        
        // Save history records
        if let historyData = try? JSONEncoder().encode(reminderHistory) {
            userDefaults.set(historyData, forKey: "reminder_history")
        }
        
        updateStats()
    }
    
    // MARK: - Issue Management
    
    /// Mark spending record issue
    func markIssue(for postId: UUID, issueType: SpendingIssueType, description: String, severity: Int = 3) {
        let issue = SpendingIssue(
            postId: postId,
            issueType: issueType,
            description: description,
            severity: severity
        )
        spendingIssues.append(issue)
        saveData()
        
        // Auto create related reminder suggestion
        suggestReminder(for: issue)
    }
    
    /// Resolve issue
    func resolveIssue(_ issueId: UUID, note: String? = nil) {
        if let index = spendingIssues.firstIndex(where: { $0.id == issueId }) {
            spendingIssues[index].isResolved = true
            spendingIssues[index].resolvedAt = Date()
            spendingIssues[index].resolvedNote = note
            saveData()
        }
    }
    
    /// Delete issue record
    func deleteIssue(_ issueId: UUID) {
        spendingIssues.removeAll { $0.id == issueId }
        saveData()
    }
    
    // MARK: - Reminder Management
    
    /// Add reminder rule
    func addReminder(_ reminder: SpendingReminder) {
        reminders.append(reminder)
        saveData()
        
        // If it's a time-triggered reminder, set up local notification
        if let nextDate = reminder.nextReminderDate {
            scheduleLocalNotification(for: reminder, at: nextDate)
        }
    }
    
    /// Delete reminder rule
    func deleteReminder(_ reminderId: UUID) {
        reminders.removeAll { $0.id == reminderId }
        saveData()
        
        // Cancel related local notifications
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderId.uuidString])
    }
    
    /// Toggle reminder rule status
    func toggleReminder(_ reminderId: UUID) {
        if let index = reminders.firstIndex(where: { $0.id == reminderId }) {
            reminders[index] = SpendingReminder(
                title: reminders[index].title,
                message: reminders[index].message,
                issueType: reminders[index].issueType,
                frequency: reminders[index].frequency,
                trigger: reminders[index].trigger
            )
            saveData()
        }
    }
    
    // MARK: - Smart Suggestions
    
    /// Auto suggest reminder based on issue
    private func suggestReminder(for issue: SpendingIssue) {
        // Smart suggestion logic can be implemented here
        // Generate appropriate reminder rules based on issue type, historical data, etc.
        
        let trigger = ReminderTrigger(
            merchantName: nil,
            category: nil,
            amountThreshold: nil,
            timeOfDay: nil,
            dayOfWeek: nil,
            dayOfMonth: nil
        )
        
        let frequency: ReminderFrequency
        let title: String
        let message: String
        
        switch issue.issueType {
        case .overBudget:
            frequency = .beforeCategory
            title = "Budget Reminder"
            message = "Notice: Last spending in this category exceeded budget"
            
        case .unnecessaryPurchase:
            frequency = .beforeSimilarPurchase
            title = "Spending Reminder"
            message = "Reminder: This type of spending was previously marked as unnecessary"
            
        case .impulseSpending:
            frequency = .beforeMerchant
            title = "Impulse Spending Reminder"
            message = "Slow down! Previous impulse spending occurred here"
            
        case .subscriptionForgotten:
            frequency = .monthly
            title = "Subscription Check"
            message = "Remember to check if this subscription is still needed"
            
        default:
            frequency = .once
            title = "Spending Reminder"
            message = "Notice: There was a previous issue here"
        }
        
        let suggestion = SpendingReminder(
            title: title,
            message: message,
            issueType: issue.issueType,
            frequency: frequency,
            trigger: trigger
        )
        
        // Could show suggestion dialog for user to choose whether to add
        // Auto-add for now, could be changed to ask user in actual usage
        addReminder(suggestion)
    }
    
    // MARK: - Trigger Logic
    
    /// Check if reminders should be triggered (called when creating new spending record)
    func checkReminders(for post: SpendingPost) {
        for reminder in reminders where reminder.isActive {
            if reminder.shouldTrigger(for: post) {
                triggerReminder(reminder, context: "New spending record: \(post.merchantName)")
            }
        }
    }
    
    /// Trigger reminder
    private func triggerReminder(_ reminder: SpendingReminder, context: String) {
        // Record history
        let history = ReminderHistory(reminderId: reminder.id, triggerContext: context)
        reminderHistory.append(history)
        
        // Update reminder status
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].lastTriggeredAt = Date()
            reminders[index].reminderCount += 1
            
            // Calculate next reminder time
            reminders[index].nextReminderDate = SpendingReminder.calculateNextReminderDate(
                frequency: reminder.frequency,
                from: Date()
            )
        }
        
        saveData()
        
        // Send local notification
        sendLocalNotification(title: reminder.title, message: reminder.message)
    }
    
    // MARK: - Notifications
    
    private func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission request failed: \(error)")
            }
        }
    }
    
    private func scheduleLocalNotification(for reminder: SpendingReminder, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.message
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request)
    }
    
    private func sendLocalNotification(title: String, message: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request)
    }
    
    // MARK: - Statistics
    
    private func updateStats() {
        let totalReminders = reminders.count
        let activeReminders = reminders.filter { $0.isActive }.count
        let today = Calendar.current.startOfDay(for: Date())
        let triggeredToday = reminderHistory.filter { 
            Calendar.current.startOfDay(for: $0.triggeredAt) == today 
        }.count
        let problemsSolved = spendingIssues.filter { $0.isResolved }.count
        
        // Simple estimation of money saved (based on resolved problems)
        let moneySaved = Double(problemsSolved) * 50.0 // Assume average savings of $50 per problem
        
        stats = ReminderStats(
            totalReminders: totalReminders,
            activeReminders: activeReminders,
            triggeredToday: triggeredToday,
            problemsSolved: problemsSolved,
            moneySaved: moneySaved
        )
    }
    
    // MARK: - Mock Data
    
    private func setupMockData() {
        guard spendingIssues.isEmpty && reminders.isEmpty else { return }
        
        // Create some sample issues
        let sampleIssues = [
            SpendingIssue(
                postId: UUID(),
                issueType: .overBudget,
                description: "This month's entertainment spending exceeded budget by $300",
                severity: 4
            ),
            SpendingIssue(
                postId: UUID(),
                issueType: .unnecessaryPurchase,
                description: "Bought another unnecessary coffee, should control this",
                severity: 2
            ),
            SpendingIssue(
                postId: UUID(),
                issueType: .subscriptionForgotten,
                description: "Netflix subscription hasn't been used for months, should cancel",
                severity: 3
            )
        ]
        spendingIssues = sampleIssues
        
        // Create some sample reminders
        let sampleReminders = [
            SpendingReminder(
                title: "Entertainment Budget Reminder",
                message: "Notice: This month's entertainment spending is approaching budget limit",
                issueType: .overBudget,
                frequency: .beforeCategory,
                trigger: ReminderTrigger(
                    merchantName: nil,
                    category: "Entertainment",
                    amountThreshold: 100.0,
                    timeOfDay: nil,
                    dayOfWeek: nil,
                    dayOfMonth: nil
                )
            ),
            SpendingReminder(
                title: "Coffee Spending Reminder",
                message: "You already bought coffee today, are you sure you want to buy more?",
                issueType: .unnecessaryPurchase,
                frequency: .beforeCategory,
                trigger: ReminderTrigger(
                    merchantName: nil,
                    category: "Coffee",
                    amountThreshold: nil,
                    timeOfDay: nil,
                    dayOfWeek: nil,
                    dayOfMonth: nil
                )
            )
        ]
        reminders = sampleReminders
        
        saveData()
    }
    
    // MARK: - Public Helpers
    
    /// Get issues for specific spending record
    func getIssues(for postId: UUID) -> [SpendingIssue] {
        return spendingIssues.filter { $0.postId == postId }
    }
    
    /// Get unresolved issues
    func getUnresolvedIssues() -> [SpendingIssue] {
        return spendingIssues.filter { !$0.isResolved }
    }
    
    /// Get active reminders
    func getActiveReminders() -> [SpendingReminder] {
        return reminders.filter { $0.isActive }
    }
} 
