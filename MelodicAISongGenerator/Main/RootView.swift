//
//  RootView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 13.08.2026.
//


import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case library = "Library"
    case settings = "Settings"
    
    var id: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .home: return "music.note"
        case .library: return "folder.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct BottomTabBar: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        HStack {
            ForEach(AppTab.allCases) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: AdaptiveFontSize.adaptive22))
                        Text(tab.rawValue)
                            .font(Theme.Typography.tabLabel)
                    }
                    .foregroundStyle(selectedTab == tab ? LinearGradient(colors: [Theme.gradientPink, Theme.gradientPurple], startPoint: .top, endPoint: .bottom) :  LinearGradient(colors: [Theme.textSecondary], startPoint: .top, endPoint: .bottom) )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(
            Theme.surface
                .overlay(Rectangle().fill(Theme.stroke).frame(height: 1), alignment: .top)
                .ignoresSafeArea()
        )
    }
}


struct RootView: View {
    @State private var selectedTab: AppTab = .home
    
    var body: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case .home:
                SongCreatorView()
            case .library:
                LibraryView {
                    selectedTab = .home
                }
            case .settings:
                SettingsView()
            }
            
            BottomTabBar(selectedTab: $selectedTab)
        }
        .background(Theme.background.ignoresSafeArea())
    }
}


#Preview {
    RootView()
}
