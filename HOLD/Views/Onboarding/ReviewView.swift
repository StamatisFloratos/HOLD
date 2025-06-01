//
//  WorkoutFinishView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 08/05/2025.
//


import Foundation
import SwiftUI
import StoreKit


struct ReviewView: View {
    @State private var showNextView = false
    
    var body: some View {
        ZStack {
            AppBackground()
            if showNextView {
                MilestoneView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .zIndex(1)
            } else {
                VStack{
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 14)
                    ScrollView {
                        VStack(spacing:37) {
                            Text("Give us a Rating")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("This app was made for people like you and us. We made it because we needed it.")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal,35)
                        
                        Image("thankyouIcon")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,33)
                            .padding(.bottom,-40)
                            .padding(.top,0)
                        
                        VStack(spacing:23) {
                            
                            Image("review1")
                                .resizable()
                                .scaledToFit()
                            Image("review2")
                                .resizable()
                                .scaledToFit()
                            Image("review3")
                                .resizable()
                                .scaledToFit()
                            Image("review4")
                                .resizable()
                                .scaledToFit()
                        }
                        .padding(.horizontal,44)
                        .padding(.bottom, 100)
                    }
                    .scrollIndicators(.hidden)
                    
                    Spacer()
                }
                .ignoresSafeArea(.container, edges: .bottom)
                
                VStack {
                    Spacer()
                    Button(action: {
                        triggerHaptic()
                        withAnimation {
                            showNextView = true
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .padding()
                            .frame(maxWidth: .infinity,maxHeight: 47)
                            .background(Color(hex: "#FF1919"))
                            .foregroundColor(.white)
                            .cornerRadius(30)
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom, 10)
                }
            }
        }
        .onAppear {
            trackOnboarding("ob_review", variant: UserStorage.onboarding)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                requestReview()
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut, value: showNextView)

    }
    
    func requestReview() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    ReviewView()
}
