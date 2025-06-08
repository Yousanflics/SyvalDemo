import SwiftUI

struct IssueMarkerView: View {
    let post: SpendingPost
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var reminderService: SpendingReminderService
    
    @State private var selectedIssueType = SpendingIssueType.unnecessaryPurchase
    @State private var description = ""
    @State private var severity = 3
    @State private var shouldCreateReminder = true
    @State private var reminderTitle = ""
    @State private var reminderMessage = ""
    @State private var selectedFrequency = ReminderFrequency.beforeSimilarPurchase
    
    private let severityLabels = ["Very Minor", "Minor", "Moderate", "Severe", "Very Severe"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Spending record preview
                    postPreviewCard
                    
                    // Issue type selection
                    issueTypeSection
                    
                    // Issue description
                    descriptionSection
                    
                    // Severity level
                    severitySection
                    
                    // Reminder settings
                    reminderSection
                }
                .padding()
            }
            .navigationTitle("Mark Issue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveIssue()
                    }
                    .disabled(description.isEmpty)
                }
            }
        }
    }
    
    private var postPreviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending Record")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                Text(post.category.emoji)
                    .font(.title2)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(post.category.color.opacity(0.2))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.merchantName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(post.formattedAmount)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(post.category.color)
                    
                    Text(post.category.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(post.emotion.rawValue)
                    .font(.title2)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
    
    private var issueTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Issue Type")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(SpendingIssueType.allCases, id: \.self) { issueType in
                    IssueTypeCard(
                        issueType: issueType,
                        isSelected: selectedIssueType == issueType
                    ) {
                        selectedIssueType = issueType
                        updateSuggestedReminder()
                    }
                }
            }
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Issue Description")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField("Describe this issue in detail...", text: $description, axis: .vertical)
                .lineLimit(3...6)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
        }
    }
    
    private var severitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Severity Level")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                HStack {
                    Text(severityLabels[severity - 1])
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(severity)/5")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { level in
                        Circle()
                            .fill(level <= severity ? Color.red : Color.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                            .onTapGesture {
                                severity = level
                            }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
    
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Create Reminder")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle("", isOn: $shouldCreateReminder)
                    .onChange(of: shouldCreateReminder) { _ in
                        if shouldCreateReminder {
                            updateSuggestedReminder()
                        }
                    }
            }
            
            if shouldCreateReminder {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reminder Title")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("Reminder Title", text: $reminderTitle)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reminder Message")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("Reminder Message", text: $reminderMessage, axis: .vertical)
                            .lineLimit(2...4)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Reminder Frequency")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("Reminder Frequency", selection: $selectedFrequency) {
                            ForEach(ReminderFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.displayName).tag(frequency)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                )
            }
        }
    }
    
    private func updateSuggestedReminder() {
        guard shouldCreateReminder else { return }
        
        switch selectedIssueType {
        case .overBudget:
            reminderTitle = "Budget Reminder"
            reminderMessage = "Notice: Spending in \(post.category.name) category may exceed budget"
            selectedFrequency = .beforeCategory
            
        case .unnecessaryPurchase:
            reminderTitle = "Spending Reminder"
            reminderMessage = "Reminder: Spending at \(post.merchantName) was previously marked as unnecessary"
            selectedFrequency = .beforeMerchant
            
        case .impulseSpending:
            reminderTitle = "Impulse Spending Reminder"
            reminderMessage = "Slow down! Previous impulse spending occurred at \(post.merchantName)"
            selectedFrequency = .beforeMerchant
            
        case .subscriptionForgotten:
            reminderTitle = "Subscription Check"
            reminderMessage = "Remember to check if \(post.merchantName) subscription is still needed"
            selectedFrequency = .monthly
            
        case .duplicateCharge:
            reminderTitle = "Duplicate Charge Reminder"
            reminderMessage = "Check for duplicate charges at \(post.merchantName)"
            selectedFrequency = .beforeMerchant
            
        case .priceIncreased:
            reminderTitle = "Price Change Reminder"
            reminderMessage = "\(post.merchantName) prices may have changed, check carefully"
            selectedFrequency = .beforeMerchant
            
        default:
            reminderTitle = "Spending Reminder"
            reminderMessage = "Notice: There was a previous issue here"
            selectedFrequency = .once
        }
    }
    
    private func saveIssue() {
        // Save issue record
        reminderService.markIssue(
            for: post.id,
            issueType: selectedIssueType,
            description: description,
            severity: severity
        )
        
        // If chose to create reminder, add reminder rule
        if shouldCreateReminder && !reminderTitle.isEmpty && !reminderMessage.isEmpty {
            let trigger = ReminderTrigger(
                merchantName: (selectedFrequency == .beforeMerchant) ? post.merchantName : nil,
                category: (selectedFrequency == .beforeCategory) ? post.category.name : nil,
                amountThreshold: nil,
                timeOfDay: nil,
                dayOfWeek: nil,
                dayOfMonth: nil
            )
            
            let reminder = SpendingReminder(
                title: reminderTitle,
                message: reminderMessage,
                issueType: selectedIssueType,
                frequency: selectedFrequency,
                trigger: trigger
            )
            
            reminderService.addReminder(reminder)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct IssueTypeCard: View {
    let issueType: SpendingIssueType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(issueType.emoji)
                    .font(.title2)
                
                Text(issueType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? issueType.color.opacity(0.2) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? issueType.color : Color.clear, lineWidth: 2)
                    )
            )
            .foregroundColor(isSelected ? issueType.color : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    IssueMarkerView(post: SpendingPost(
        user: User.mock,
        amount: 45.67,
        category: SpendingCategory.categories[0],
        merchantName: "Starbucks",
        description: "Morning coffee",
        emotion: .regret,
        caption: "Maybe I should stop buying coffee every day...",
        timestamp: Date(),
        location: "Coffee Shop",
        isPrivate: false,
        images: nil,
        likesCount: 12,
        commentsCount: 3,
        sharesCount: 1,
        isLikedByCurrentUser: false
    ))
    .environmentObject(SpendingReminderService.shared)
} 
