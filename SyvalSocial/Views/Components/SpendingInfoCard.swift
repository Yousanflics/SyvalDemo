import SwiftUI

struct SpendingInfoCard: View {
    let post: SpendingPost
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            // Category icon with medium category color
            Text(post.category.emoji)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(post.category.color.lighter(by: 0.4))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(post.merchantName)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(post.formattedAmount)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(post.category.color.darker())
                }
                
                HStack {
                    Text(post.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Emotion
                    HStack(spacing: 4) {
                        Text(post.emotion.rawValue)
                            .font(.caption)
                        Text(post.emotion.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .light ? Color.white.opacity(0.5) : Color(.tertiarySystemFill))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(post.category.color.veryLight(by: 0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(colorScheme == .light ? Color.white.opacity(0.7) : Color(.separator).opacity(0.2), lineWidth: 1.5)
                )
        )
    }
}

#Preview {
//    SpendingInfoCard(post: MockDataService.shared.samplePosts[0])
//        .padding()
} 
