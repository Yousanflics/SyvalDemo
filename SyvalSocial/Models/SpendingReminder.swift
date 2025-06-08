import Foundation
import SwiftUI

// MARK: - 提醒相关枚举

/// 扣费问题类型
enum SpendingIssueType: String, CaseIterable, Codable {
    case overBudget = "over_budget"           // 超预算
    case unnecessaryPurchase = "unnecessary"  // 不必要消费
    case duplicateCharge = "duplicate"        // 重复扣费
    case wrongCategory = "wrong_category"     // 分类错误
    case suspiciousCharge = "suspicious"      // 可疑扣费
    case subscriptionForgotten = "subscription" // 忘记的订阅
    case impulseSpending = "impulse"          // 冲动消费
    case priceIncreased = "price_increase"    // 价格上涨
    
    var displayName: String {
        switch self {
        case .overBudget: return "Over Budget"
        case .unnecessaryPurchase: return "Unnecessary Purchase"
        case .duplicateCharge: return "Duplicate Charge"
        case .wrongCategory: return "Wrong Category"
        case .suspiciousCharge: return "Suspicious Charge"
        case .subscriptionForgotten: return "Forgotten Subscription"
        case .impulseSpending: return "Impulse Spending"
        case .priceIncreased: return "Price Increased"
        }
    }
    
    var emoji: String {
        switch self {
        case .overBudget: return "💸"
        case .unnecessaryPurchase: return "🤔"
        case .duplicateCharge: return "🔄"
        case .wrongCategory: return "🏷️"
        case .suspiciousCharge: return "⚠️"
        case .subscriptionForgotten: return "📱"
        case .impulseSpending: return "⚡"
        case .priceIncreased: return "📈"
        }
    }
    
    var color: Color {
        switch self {
        case .overBudget: return .red
        case .unnecessaryPurchase: return .orange
        case .duplicateCharge: return .purple
        case .wrongCategory: return .blue
        case .suspiciousCharge: return .red
        case .subscriptionForgotten: return .green
        case .impulseSpending: return .yellow
        case .priceIncreased: return .orange
        }
    }
}

/// 提醒频率
enum ReminderFrequency: String, CaseIterable, Codable {
    case once = "once"                    // 一次性
    case beforeSimilarPurchase = "before_similar" // 类似消费前
    case weekly = "weekly"                // 每周
    case monthly = "monthly"              // 每月
    case beforeMerchant = "before_merchant" // 在该商家消费前
    case beforeCategory = "before_category" // 在该类别消费前
    
    var displayName: String {
        switch self {
        case .once: return "One-time Reminder"
        case .beforeSimilarPurchase: return "Before Similar Purchase"
        case .weekly: return "Weekly Reminder"
        case .monthly: return "Monthly Reminder"
        case .beforeMerchant: return "Before Merchant Purchase"
        case .beforeCategory: return "Before Category Purchase"
        }
    }
}

/// 提醒触发条件
struct ReminderTrigger: Codable {
    let merchantName: String?      // 特定商家
    let category: String?          // 特定类别
    let amountThreshold: Double?   // 金额阈值
    let timeOfDay: String?         // 特定时间
    let dayOfWeek: Int?           // 星期几 (1-7)
    let dayOfMonth: Int?          // 每月第几天
}

// MARK: - 核心数据模型

/// 扣费问题记录
struct SpendingIssue: Identifiable, Codable {
    let id = UUID()
    let postId: UUID                    // 关联的消费记录
    let issueType: SpendingIssueType   // 问题类型
    let description: String             // 问题描述
    let createdAt: Date                // 标记时间
    let severity: Int                  // 严重程度 (1-5)
    var isResolved: Bool              // 是否已解决
    var resolvedAt: Date?             // 解决时间
    var resolvedNote: String?         // 解决备注
    
    init(postId: UUID, issueType: SpendingIssueType, description: String, severity: Int = 3) {
        self.postId = postId
        self.issueType = issueType
        self.description = description
        self.createdAt = Date()
        self.severity = max(1, min(5, severity))
        self.isResolved = false
    }
}

/// 扣费提醒规则
struct SpendingReminder: Identifiable, Codable {
    let id = UUID()
    let title: String                  // 提醒标题
    let message: String               // 提醒内容
    let issueType: SpendingIssueType // 关联的问题类型
    let frequency: ReminderFrequency  // 提醒频率
    let trigger: ReminderTrigger      // 触发条件
    let isActive: Bool                // 是否激活
    let createdAt: Date              // 创建时间
    var nextReminderDate: Date?      // 下次提醒时间
    var reminderCount: Int           // 已提醒次数
    var lastTriggeredAt: Date?       // 最后触发时间
    
    init(title: String, message: String, issueType: SpendingIssueType, frequency: ReminderFrequency, trigger: ReminderTrigger) {
        self.title = title
        self.message = message
        self.issueType = issueType
        self.frequency = frequency
        self.trigger = trigger
        self.isActive = true
        self.createdAt = Date()
        self.reminderCount = 0
        self.nextReminderDate = SpendingReminder.calculateNextReminderDate(frequency: frequency, from: Date())
    }
    
    /// 计算下次提醒时间
    static func calculateNextReminderDate(frequency: ReminderFrequency, from date: Date) -> Date? {
        let calendar = Calendar.current
        
        switch frequency {
        case .once:
            return nil // 一次性提醒不需要重复
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date)
        case .beforeSimilarPurchase, .beforeMerchant, .beforeCategory:
            return nil // 这些根据行为触发，不是时间触发
        }
    }
    
    /// 检查是否应该触发提醒
    func shouldTrigger(for post: SpendingPost) -> Bool {
        guard isActive else { return false }
        
        switch frequency {
        case .beforeSimilarPurchase:
            // 检查是否是类似的消费（相同类别或商家）
            return post.category.name == trigger.category || post.merchantName == trigger.merchantName
            
        case .beforeMerchant:
            return post.merchantName == trigger.merchantName
            
        case .beforeCategory:
            return post.category.name == trigger.category
            
        case .once, .weekly, .monthly:
            // 时间触发的提醒
            if let nextDate = nextReminderDate {
                return Date() >= nextDate
            }
            return false
        }
    }
}

/// 提醒历史记录
struct ReminderHistory: Identifiable, Codable {
    let id = UUID()
    let reminderId: UUID              // 关联的提醒规则
    let triggeredAt: Date            // 触发时间
    let triggerContext: String       // 触发上下文
    var wasActedUpon: Bool          // 用户是否采取了行动
    var userResponse: String?        // 用户回应
    
    init(reminderId: UUID, triggerContext: String) {
        self.reminderId = reminderId
        self.triggeredAt = Date()
        self.triggerContext = triggerContext
        self.wasActedUpon = false
    }
}

// MARK: - 辅助结构

/// 提醒统计数据
struct ReminderStats: Codable {
    let totalReminders: Int          // 总提醒数
    let activeReminders: Int         // 活跃提醒数
    let triggeredToday: Int         // 今日触发数
    let problemsSolved: Int         // 已解决问题数
    let moneySaved: Double          // 节省金额（估算）
    
    static let empty = ReminderStats(
        totalReminders: 0,
        activeReminders: 0,
        triggeredToday: 0,
        problemsSolved: 0,
        moneySaved: 0.0
    )
}

// MARK: - 扩展现有模型

extension SpendingPost {
    /// 检查是否有关联的问题
    var hasIssues: Bool {
        // 这个需要在实际使用时从服务中查询
        return false
    }
    
    /// 获取风险评分（基于历史问题）
    var riskScore: Double {
        // 基于金额、类别、商家等因素计算风险评分
        var score = 0.0
        
        // 金额因子
        if amount > 100 { score += 1.0 }
        if amount > 500 { score += 1.0 }
        
        // 类别因子（某些类别更容易出问题）
        switch category.name {
        case "Entertainment", "Shopping":
            score += 0.5
        default:
            break
        }
        
        // 情绪因子
        if emotion == .regret || emotion == .sad {
            score += 1.0
        }
        
        return min(5.0, score)
    }
} 
