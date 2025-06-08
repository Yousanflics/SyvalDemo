//
//  ContentView.swift
//  SyvalSocial
//
//  Created by yousanflics on 5/29/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var tabBarViewModel = TabBarViewModel.shared
    
    var body: some View {
        ZStack {
            FeedView()
                .ignoresSafeArea(.keyboard, edges: .bottom)
            
            VStack {
                Spacer()
                if tabBarViewModel.isTabBarVisible {
                    CustomTabBar()
                        .padding(.bottom, 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
