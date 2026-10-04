//
//  OnboardingView.swift
//  MelodicAISongGenerator
//
//  Created by Vlad Lytvynets on 14.08.2026.
//



import SwiftUI
import StoreKit

struct OnboardingView: View {
    
    var onFinished: () -> Void = {}
    
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            
            Theme.background
                .ignoresSafeArea()
            
            Image("onbBackground")
                .resizable()
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                ForEach(OnboardingPage.all) { page in
                    OnboardingPageView(
                        page: page,
                        isLastPage: page.id == OnboardingPage.all.count - 1,
                        onAdvance: { goNext() }
                    )
                    .tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.35), value: currentPage)
        }
        .preferredColorScheme(.dark)
        .onChange(of: currentPage) { oldValue, newValue in
         
            
            if newValue == 1 {
                Task {
                    let granted = await NotificationManager.shared.requestPermission()
                }
            }
            
        }
    }
    
    


    
    func goNext() {
        let lastIndex = OnboardingPage.all.count - 1
        if currentPage < lastIndex {
            withAnimation(.easeInOut(duration: 0.35)) {
                currentPage += 1
            }
        } else {
            onFinished()
        }
    }
}


#Preview {
    OnboardingView()
}
