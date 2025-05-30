import SwiftUI
import UIKit

// MARK: - 分享工具类
class ShareHelper {
    
    /// 生成帖子分享URL
    /// - Parameter postId: 帖子ID
    /// - Returns: 分享URL字符串
    static func generatePostShareURL(postId: UUID) -> String {
        return "https://syvalapp.com/\(postId.uuidString)"
    }
    
    /// 生成分享内容
    /// - Parameters:
    ///   - post: 帖子对象
    ///   - includeDetails: 是否包含详细信息
    /// - Returns: 分享文本和URL的数组
    static func generateShareContent(for post: SpendingPost, includeDetails: Bool = true) -> [Any] {
        let url = generatePostShareURL(postId: post.id)
        
        if includeDetails {
            let shareText = """
            Check out this spending post on Syval! 💰
            
            \(post.user.displayName) spent $\(String(format: "%.2f", post.amount)) at \(post.merchantName)
            
            "\(post.caption)"
            
            See more details:
            """
            
            return [shareText, URL(string: url)!]
        } else {
            return [URL(string: url)!]
        }
    }
}


/// Native Share ViewModifier
struct NativeShareAction: ViewModifier {
    @Binding var isPresented: Bool
    let items: [Any]
    let onPresented: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                if newValue {
                    presentShareSheet()
                }
            }
    }

    private func presentShareSheet() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController else {
                return
            }

            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            activityVC.modalPresentationStyle = .automatic

            rootVC.present(activityVC, animated: true) {
                onPresented?()
                isPresented = false // 自动关闭
            }
        }
    }
}


extension View {
    /// 调用原生系统分享
    func nativeShareSheet(
        isPresented: Binding<Bool>,
        items: [Any],
        onPresented: (() -> Void)? = nil
    ) -> some View {
        self.modifier(NativeShareAction(isPresented: isPresented, items: items, onPresented: onPresented))
    }
}
