import SwiftUI

struct TabBarTestView: View {
    @StateObject private var tabBarViewModel = TabBarViewModel.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("TabBar Test Controls")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                Text("Current State: \(tabBarViewModel.isTabBarVisible ? "Visible" : "Hidden")")
                    .font(.headline)
                    .foregroundColor(tabBarViewModel.isTabBarVisible ? .green : .red)
                
                Text("Current View: \(viewName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                VStack(spacing: 12) {
                    Button("Show TabBar") {
                        tabBarViewModel.showTabBar()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Hide TabBar") {
                        tabBarViewModel.hideTabBar()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Simulate Scrolling") {
                        tabBarViewModel.handleScrolling()
                    }
                    .buttonStyle(.bordered)
                    
                    HStack(spacing: 12) {
                        Button("Feed") {
                            tabBarViewModel.navigateToView(.feed)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Detail") {
                            tabBarViewModel.navigateToView(.detail)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Other") {
                            tabBarViewModel.navigateToView(.other)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .padding()
    }
    
    private var viewName: String {
        switch tabBarViewModel.currentView {
        case .feed:
            return "Feed"
        case .detail:
            return "Detail"
        case .other:
            return "Other"
        }
    }
}

#Preview {
    TabBarTestView()
} 
