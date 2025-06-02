import SwiftUI

struct GroupPhotosView: View {
    let images: [String]
    @State private var currentIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            if !images.isEmpty {
                ZStack(alignment: .topTrailing) {
                    // Main photo pager - full width to screen edges
                    TabView(selection: $currentIndex) {
                        ForEach(images.indices, id: \.self) { index in
                            AsyncImage(url: URL(string: images[index])) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity, maxHeight: 400)
                                    .clipped()
                            } placeholder: {
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .frame(maxWidth: .infinity, maxHeight: 400)
                                    .overlay(
                                        ProgressView()
                                            .scaleEffect(1.2)
                                    )
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: 400)
                    
                    // Photo counter - only show if there are multiple images
                    if images.count > 1 {
                        HStack {
                            Text("\(currentIndex + 1)/\(images.count)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.adaptiveShadow.opacity(0.8))
                                )
                        }
                        .padding(.top, 12)
                        .padding(.trailing, 12)
                    }
                }
                
                // Custom page indicator
                if images.count > 1 {
                    HStack(spacing: 8) {
                        ForEach(images.indices, id: \.self) { index in
                            Circle()
                                .fill(currentIndex == index ? Color.indigo : Color.gray.opacity(0.4))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.2), value: currentIndex)
                        }
                    }
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemBackground))
                }
            }
        }
        .background(Color(.secondarySystemBackground))
    }
}

// A simplified version for PostCardView to show a single image or image count
struct PostImagePreview: View {
    let images: [String]
    let maxHeight: CGFloat = 200
    
    var body: some View {
        if !images.isEmpty {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: images[0])) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: maxHeight)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(maxWidth: .infinity, maxHeight: maxHeight)
                        .overlay(
                            ProgressView()
                                .scaleEffect(1.2)
                        )
                }
                
                // Show count if there are multiple images
                if images.count > 1 {
                    HStack(spacing: 4) {
                        Image(systemName: "photo.stack")
                            .font(.caption)
                        Text("\(images.count)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.adaptiveShadow.opacity(0.8))
                    )
                    .padding(.top, 8)
                    .padding(.trailing, 8)
                }
            }
            .cornerRadius(12)
        }
    }
}

#Preview {
    VStack {
        GroupPhotosView(images: [
            "https://example.com/image1.jpg",
            "https://example.com/image2.jpg",
            "https://example.com/image3.jpg"
        ])
        
        PostImagePreview(images: [
            "https://example.com/image1.jpg",
            "https://example.com/image2.jpg"
        ])
        .padding()
    }
} 
