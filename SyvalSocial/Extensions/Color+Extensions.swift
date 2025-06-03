import SwiftUI
import UIKit

extension Color {
    
    /// 通过十六进制字符串创建 SwiftUI Color
    /// - Parameter hex: 十六进制颜色字符串，支持格式：#RRGGBB, RRGGBB, #RGB, RGB
    /// - Returns: SwiftUI Color 实例
    static func hex(_ hex: String) -> Color {
        return Color(UIColor.hex(hex))
    }
    
    /// 通过十六进制字符串创建带透明度的 SwiftUI Color
    /// - Parameters:
    ///   - hex: 十六进制颜色字符串
    ///   - alpha: 透明度 (0.0 - 1.0)
    /// - Returns: SwiftUI Color 实例
    static func hex(_ hex: String, alpha: Double) -> Color {
        return Color(UIColor.hex(hex, alpha: CGFloat(alpha)))
    }
    
    /// 通过十六进制字符串初始化 SwiftUI Color
    /// - Parameter hex: 十六进制颜色字符串
    init(hex: String) {
        self.init(UIColor.hex(hex))
    }
}

// MARK: - Syval 主题色 SwiftUI 版本
extension Color {
    
    /// Syval 主题色
    static let syvalPrimary = Color.hex("#6366F1")      // 靛蓝色
    static let syvalSecondary = Color.hex("#8B5CF6")    // 紫色
    static let syvalAccent = Color.hex("#54443B")       // 深棕色
    static let syvalSuccess = Color.hex("#10B981")      // 绿色
    static let syvalWarning = Color.hex("#F59E0B")      // 橙色
    static let syvalError = Color.hex("#EF4444")        // 红色
    
    /// 社交媒体品牌色
    static let twitterBlue = Color.hex("#1DA1F2")
    static let facebookBlue = Color.hex("#4267B2")
    static let instagramPink = Color.hex("#E4405F")
    static let linkedInBlue = Color.hex("#2867B2")
}

// MARK: - 深色模式支持
extension Color {
    
    /// 自适应文本颜色 (深色模式兼容)
    static var adaptiveText: Color {
        Color(UIColor.label)
    }
    
    /// 自适应次要文本颜色 (深色模式兼容)
    static var adaptiveSecondaryText: Color {
        Color(UIColor.secondaryLabel)
    }
    
    /// 自适应三级文本颜色 (深色模式兼容)
    static var adaptiveTertiaryText: Color {
        Color(UIColor.tertiaryLabel)
    }
    
    /// 自适应背景颜色 (深色模式兼容)
    static var adaptiveBackground: Color {
        Color(UIColor.systemBackground)
    }
    
    /// 自适应次要背景颜色 (深色模式兼容)
    static var adaptiveSecondaryBackground: Color {
        Color(UIColor.secondarySystemBackground)
    }
    
    /// 自适应分组背景颜色 (深色模式兼容)
    static var adaptiveGroupedBackground: Color {
        Color(UIColor.systemGroupedBackground)
    }
    
    /// 自适应边框颜色 (深色模式兼容)
    static var adaptiveBorder: Color {
        Color(UIColor.separator)
    }
    
    /// 自适应阴影颜色 (深色模式兼容)
    static var adaptiveShadow: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark 
                ? UIColor.white.withAlphaComponent(0.15)
                : UIColor.black.withAlphaComponent(0.15)
        })
    }
    
    /// 自适应填充颜色 (深色模式兼容)
    static var adaptiveFill: Color {
        Color(UIColor.systemFill)
    }
    
    /// 自适应次要填充颜色 (深色模式兼容)
    static var adaptiveSecondaryFill: Color {
        Color(UIColor.secondarySystemFill)
    }
    
    /// 自适应三级填充颜色 (深色模式兼容)
    static var adaptiveTertiaryFill: Color {
        Color(UIColor.tertiarySystemFill)
    }
    
    /// 自适应四级填充颜色 (深色模式兼容)
    static var adaptiveQuaternaryFill: Color {
        Color(UIColor.quaternarySystemFill)
    }
}
