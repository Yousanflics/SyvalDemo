import Foundation
import Combine
import SwiftUI

class CreatePostViewModel: ObservableObject {
    // Form fields
    @Published var amount: String = ""
    @Published var selectedCategory: SpendingCategory = SpendingCategory.categories[0]
    @Published var merchantName: String = ""
    @Published var description: String = ""
    @Published var selectedEmotion: EmotionType = .neutral
    @Published var caption: String = ""
    @Published var location: String = ""
    @Published var isPrivate: Bool = false
    
    // Image fields
    @Published var selectedImages: [UIImage] = []
    @Published var showingImagePicker = false
    
    // UI State
    @Published var isPosting = false
    @Published var errorMessage: String?
    @Published var showingSuccessAlert = false
    
    // Edit mode
    private var editingPost: SpendingPost?
    var isEditMode: Bool { editingPost != nil }
    
    private let dataService = MockDataService.shared
    private let reminderService = SpendingReminderService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Default initializer for create mode
    init() {}
    
    // Initializer for edit mode
    init(editingPost: SpendingPost) {
        self.editingPost = editingPost
        populateFormWithPost(editingPost)
    }
    
    private func populateFormWithPost(_ post: SpendingPost) {
        amount = String(post.amount)
        selectedCategory = post.category
        merchantName = post.merchantName
        description = post.description
        selectedEmotion = post.emotion
        caption = post.caption
        location = post.location ?? ""
        isPrivate = post.isPrivate
        // Note: For edit mode, we would need to load existing images
        // This would typically involve downloading them from URLs
    }
    
    var isFormValid: Bool {
        !amount.isEmpty &&
        !merchantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(amount) != nil &&
        Double(amount)! > 0
    }
    
    var formattedAmount: String {
        if let amountValue = Double(amount) {
            return String(format: "$%.2f", amountValue)
        }
        return "$0.00"
    }
    
    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
    }
    
    func createPost() {
        guard isFormValid else { return }
        guard let amountValue = Double(amount) else { return }
        
        isPosting = true
        errorMessage = nil
        
        // For demo purposes, we'll simulate image upload by creating placeholder URLs
        let imageUrls = selectedImages.enumerated().map { index, _ in
            "https://picsum.photos/800/600?random=\(UUID().uuidString)"
        }
        
        if isEditMode {
            // Edit existing post
            guard let editingPost = editingPost else { return }
            
            let updateRequest = UpdatePostRequest(
                postId: editingPost.id,
                amount: amountValue,
                categoryId: selectedCategory.id,
                merchantName: merchantName.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                emotion: selectedEmotion,
                caption: caption.trimmingCharacters(in: .whitespacesAndNewlines),
                location: location.isEmpty ? nil : location.trimmingCharacters(in: .whitespacesAndNewlines),
                isPrivate: isPrivate,
                images: imageUrls.isEmpty ? nil : imageUrls
            )
            
            dataService.updatePost(updateRequest)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.isPosting = false
                        
                        if case .failure(let error) = completion {
                            self?.errorMessage = error.localizedDescription
                        }
                    },
                    receiveValue: { [weak self] _ in
                        self?.showingSuccessAlert = true
                    }
                )
                .store(in: &cancellables)
        } else {
            // Create new post
            let request = CreatePostRequest(
                amount: amountValue,
                categoryId: selectedCategory.id,
                merchantName: merchantName.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                emotion: selectedEmotion,
                caption: caption.trimmingCharacters(in: .whitespacesAndNewlines),
                location: location.isEmpty ? nil : location.trimmingCharacters(in: .whitespacesAndNewlines),
                isPrivate: isPrivate,
                images: imageUrls.isEmpty ? nil : imageUrls
            )
            
            dataService.createPost(request)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.isPosting = false
                        
                        if case .failure(let error) = completion {
                            self?.errorMessage = error.localizedDescription
                        }
                    },
                    receiveValue: { [weak self] newPost in
                        // Check reminder rules
                        self?.reminderService.checkReminders(for: newPost)
                        
                        self?.showingSuccessAlert = true
                        self?.resetForm()
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    private func resetForm() {
        amount = ""
        merchantName = ""
        description = ""
        caption = ""
        location = ""
        selectedEmotion = .neutral
        isPrivate = false
        selectedCategory = SpendingCategory.categories[0]
        selectedImages = []
    }
    
    func formatAmountInput() {
        // Remove any non-numeric characters except decimal point
        let filtered = amount.filter { $0.isNumber || $0 == "." }
        
        // Ensure only one decimal point
        let components = filtered.components(separatedBy: ".")
        if components.count > 2 {
            amount = components[0] + "." + components[1]
        } else {
            amount = filtered
        }
        
        // Limit to 2 decimal places
        if let decimalIndex = amount.firstIndex(of: ".") {
            let decimalPart = amount[amount.index(after: decimalIndex)...]
            if decimalPart.count > 2 {
                amount = String(amount.prefix(amount.distance(from: amount.startIndex, to: decimalIndex) + 3))
            }
        }
    }
} 
