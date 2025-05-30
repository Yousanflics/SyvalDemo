import UIKit

extension UIColor {
    
    /// 通过十六进制字符串创建 UIColor
    /// - Parameter hex: 十六进制颜色字符串，支持格式：#RRGGBB, RRGGBB, #RGB, RGB
    /// - Returns: UIColor 实例，如果解析失败返回黑色
    static func hex(_ hex: String) -> UIColor {
        return UIColor(hex: hex)
    }
    
    /// 通过十六进制字符串初始化 UIColor
    /// - Parameter hex: 十六进制颜色字符串，支持格式：#RRGGBB, RRGGBB, #RGB, RGB
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 移除 # 前缀
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        
        // 处理 3 位十六进制（如 RGB -> RRGGBB）
        if hexString.count == 3 {
            hexString = String(hexString.map { "\($0)\($0)" }.joined())
        }
        
        // 确保是 6 位十六进制
        guard hexString.count == 6 else {
            self.init(red: 0, green: 0, blue: 0, alpha: 1.0)
            return
        }
        
        // 解析 RGB 值
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /// 通过十六进制字符串创建带透明度的 UIColor
    /// - Parameters:
    ///   - hex: 十六进制颜色字符串
    ///   - alpha: 透明度 (0.0 - 1.0)
    /// - Returns: UIColor 实例
    static func hex(_ hex: String, alpha: CGFloat) -> UIColor {
        return UIColor(hex: hex).withAlphaComponent(alpha)
    }
    
    /// 将 UIColor 转换为十六进制字符串
    /// - Parameter includeAlpha: 是否包含透明度
    /// - Returns: 十六进制字符串
    func toHex(includeAlpha: Bool = false) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        
        if includeAlpha {
            let a = Int(alpha * 255)
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        } else {
            return String(format: "#%02X%02X%02X", r, g, b)
        }
    }
}

// MARK: - 常用颜色预设
extension UIColor {
    
    /// Syval 主题色
    static let syvalPrimary = UIColor.hex("#6366F1")      // 靛蓝色
    static let syvalSecondary = UIColor.hex("#8B5CF6")    // 紫色
    static let syvalAccent = UIColor.hex("#54443B")       // 深棕色
    static let syvalSuccess = UIColor.hex("#10B981")      // 绿色
    static let syvalWarning = UIColor.hex("#F59E0B")      // 橙色
    static let syvalError = UIColor.hex("#EF4444")        // 红色
    
    /// 社交媒体品牌色
    static let twitterBlue = UIColor.hex("#1DA1F2")
    static let facebookBlue = UIColor.hex("#4267B2")
    static let instagramPink = UIColor.hex("#E4405F")
    static let linkedInBlue = UIColor.hex("#2867B2")
} 
