import SwiftUI

struct CreatePostView: View {
    @StateObject private var viewModel: CreatePostViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Default initializer for create mode
    init() {
            _viewModel = StateObject(wrappedValue: CreatePostViewModel())
        }
    
    // Initializer for edit mode
    init(editingPost: SpendingPost) {
        _viewModel = StateObject(wrappedValue: CreatePostViewModel(editingPost: editingPost))
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Amount section
                Section("Amount") {
                    HStack {
                        Text("$")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        TextField("0.00", text: $viewModel.amount)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .fontWeight(.medium)
                            .onChange(of: viewModel.amount) { _ in
                                viewModel.formatAmountInput()
                            }
                    }
                    
                    if !viewModel.amount.isEmpty {
                        Text("Amount: \(viewModel.formattedAmount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Category section
                Section("Category") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(SpendingCategory.categories) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: viewModel.selectedCategory.id == category.id
                                ) {
                                    viewModel.selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                    }
                }
                
                // Merchant and description
                Section("Purchase Details") {
                    HStack {
                        Text(viewModel.selectedCategory.emoji)
                            .font(.title2)
                        
                        TextField("Merchant name", text: $viewModel.merchantName)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    
                    TextField("What did you buy?", text: $viewModel.description)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                
                // Emotion section
                Section("How do you feel about this? (private)") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(EmotionType.allCases, id: \.rawValue) { emotion in
                                EmotionButton(
                                    emotion: emotion,
                                    isSelected: viewModel.selectedEmotion == emotion
                                ) {
                                    viewModel.selectedEmotion = emotion
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                    }
                }
                
                // Caption section
                Section("Add Caption (optional)") {
                    TextField("Share your thoughts...", text: $viewModel.caption, axis: .vertical)
                        .lineLimit(3...6)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                
                // Images section
                Section("Add Photos (optional)") {
                    VStack(alignment: .leading, spacing: 12) {
                        Button(action: {
                            viewModel.showingImagePicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.badge.plus")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                
                                Text("Add Photos")
                                    .font(.body)
                                    .foregroundColor(.blue)
                                
                                Spacer()
                                
                                if !viewModel.selectedImages.isEmpty {
                                    Text("\(viewModel.selectedImages.count)/5")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Selected images preview
                        if !viewModel.selectedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.selectedImages.indices, id: \.self) { index in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: viewModel.selectedImages[index])
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color.adaptiveShadow.opacity(0.5))
                                                )
                                            
                                            Button(action: {
                                                viewModel.removeImage(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                                    .background(
                                                        Circle()
                                                            .fill(Color.red)
                                                            .frame(width: 20, height: 20)
                                                    )
                                            }
                                            .offset(x: 8, y: -8)
                                        }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                }
                
                // Location section
                Section("Location (optional)") {
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.secondary)
                        
                        TextField("Add location", text: $viewModel.location)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                }
                
                // Privacy toggle
                Section {
                    Toggle("Private post", isOn: $viewModel.isPrivate)
                } footer: {
                    Text("This post is visible to \(viewModel.isPrivate ? "yourself" : "anyone on Syval")")
                }
            }
            .navigationTitle(viewModel.isEditMode ? "Editing Spending" : "Share Spending")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.isEditMode ? "Save" : "Share") {
                        viewModel.createPost()
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isPosting)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $viewModel.showingImagePicker) {
                ImagePicker(selectedImages: $viewModel.selectedImages)
            }
            .overlay {
                if viewModel.isPosting {
                    ZStack {
                        Color.adaptiveShadow.opacity(0.5)
                            .ignoresSafeArea()
                        
                        VStack {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Posting...")
                                .font(.caption)
                                .padding(.top, 8)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                        )
                    }
                }
            }
        }
        .alert(viewModel.isEditMode ? "Post Updated!" : "Post Shared!", isPresented: $viewModel.showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(viewModel.isEditMode ? "Your spending post has been updated successfully!" : "Your spending experience has been shared with your friends!")
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

struct CategoryButton: View {
    let category: SpendingCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(category.emoji)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(isSelected ? category.color : category.color.opacity(0.2))
                    )
                
                Text(category.name)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? category.color : .secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmotionButton: View {
    let emotion: EmotionType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(emotion.rawValue)
                    .font(.title)
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
                
                Text(emotion.description)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CreatePostView()
} 
