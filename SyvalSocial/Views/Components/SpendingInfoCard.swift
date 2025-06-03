import SwiftUI

struct SpendingInfoCard: View {
    let post: SpendingPost
    
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
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 2)
                RoundedRectangle(cornerRadius: 12)
                    .fill(post.category.color.veryLight(by: 0.5))
            }
            
        )
    }
}

#Preview {
//    SpendingInfoCard(post: MockDataService.shared.samplePosts[0])
//        .padding()
} 
