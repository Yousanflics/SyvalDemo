import SwiftUI
import Combine

class TabBarViewModel: ObservableObject {
    @Published var isTabBarVisible = true
    @Published var currentView: AppView = .feed
    
    private var hideTimer: Timer?
    private let hideDelay: TimeInterval = 2.0
    
    enum AppView {
        case feed
        case detail
        case other
    }
    
    func showTabBar() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isTabBarVisible = true
        }
    }
    
    func hideTabBar() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isTabBarVisible = false
        }
    }
    
    func navigateToView(_ view: AppView) {
        currentView = view
        
        switch view {
        case .feed:
            showTabBar()
        case .detail, .other:
            hideTabBar()
        }
    }
    
    func handleScrolling() {
        // 滚动时立即隐藏TabBar
        hideTabBar()
        
        // 取消之前的计时器
        hideTimer?.invalidate()
        
        // 设置新的计时器，在停止滚动后显示TabBar
        hideTimer = Timer.scheduledTimer(withTimeInterval: hideDelay, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if self.currentView == .feed {
                self.showTabBar()
            }
        }
    }
    
    func resetScrollTimer() {
        hideTimer?.invalidate()
        hideTimer = nil
    }
    
    deinit {
        hideTimer?.invalidate()
    }
}

// 全局实例
extension TabBarViewModel {
    static let shared = TabBarViewModel()
} 
