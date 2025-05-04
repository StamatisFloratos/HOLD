//
//  ProgressView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//
import SwiftUI
import Foundation

struct ChallengeView: View {
    @State private var showChallengeActivity = false
    @State private var showChallengeCompleteView = false
    @State private var showChallengeRank = false
    @State private var elapsedTime: TimeInterval = 0
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var showChallengeOnboardingSheet: Bool = true

    var onBack: () -> Void

    
    var body: some View {
        ZStack {
            AppBackground()
          
            if showChallengeOnboardingSheet {
                ChallengeSheetView(onBack: {
                    withAnimation {
                        showChallengeOnboardingSheet = false
                        showChallengeActivity = true
                    }
                })
                .transition(.move(edge: .trailing))
                .zIndex(0)
            }
            if showChallengeActivity {
                ChallengeActivityView(onBack: { time in
                    elapsedTime = time
                    withAnimation {
                        showChallengeActivity = false
                        showChallengeCompleteView = true
                    }
                })
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
            if showChallengeCompleteView {
                ChallengeCompletionView(totalElapsedTime: elapsedTime, onBack: {
                    withAnimation {
                        showChallengeCompleteView = false
                        showChallengeRank = true
                    }
                })
                .transition(.move(edge: .trailing))
                .zIndex(2)
            }
            
           else if showChallengeRank {
                ChallengeRankView(onBack: {
                    withAnimation {
                        showChallengeRank = false
                        onBack()
                    }
                })
                .transition(.move(edge: .trailing))
                .zIndex(3)
            }
        }
        .navigationBarHidden(true)
    }
}
