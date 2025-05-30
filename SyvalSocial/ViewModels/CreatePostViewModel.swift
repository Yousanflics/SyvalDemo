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
    
    // UI State
    @Published var isPosting = false
    @Published var errorMessage: String?
    @Published var showingSuccessAlert = false
    
    private let dataService = MockDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
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
    
    func createPost() {
        guard isFormValid else { return }
        guard let amountValue = Double(amount) else { return }
        
        isPosting = true
        errorMessage = nil
        
        let request = CreatePostRequest(
            amount: amountValue,
            categoryId: selectedCategory.id,
            merchantName: merchantName.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            emotion: selectedEmotion,
            caption: caption.trimmingCharacters(in: .whitespacesAndNewlines),
            location: location.isEmpty ? nil : location.trimmingCharacters(in: .whitespacesAndNewlines),
            isPrivate: isPrivate
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
                receiveValue: { [weak self] _ in
                    self?.showingSuccessAlert = true
                    self?.resetForm()
                }
            )
            .store(in: &cancellables)
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
