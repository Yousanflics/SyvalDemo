import SwiftUI

struct ScrollDetectionView: View {
    @StateObject private var tabBarViewModel = TabBarViewModel.shared
    @State private var lastScrollOffset: CGFloat = 0
    @State private var isScrolling = false
    
    let content: () -> AnyView
    
    init<Content: View>(@ViewBuilder content: @escaping () -> Content) {
        self.content = { AnyView(content()) }
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                content()
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: geometry.frame(in: .named("scrollView")).minY
                                )
                        }
                    )
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                handleScrollOffset(value)
            }
        }
    }
    
    private func handleScrollOffset(_ offset: CGFloat) {
        let threshold: CGFloat = 5 // 滚动敏感度阈值
        
        if abs(offset - lastScrollOffset) > threshold {
            if !isScrolling {
                isScrolling = true
                tabBarViewModel.handleScrolling()
            }
            
            // 重置计时器
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if isScrolling {
                    isScrolling = false
                }
            }
        }
        
        lastScrollOffset = offset
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
} 
