//
//  GoodNewsView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 05/05/2025.
//

import SwiftUI

struct GoodNewsView: View {
    @EnvironmentObject private var notificationsManager: NotificationsManager
    
    @State private var showNextView = false
    @State private var userProfile: UserProfile = UserProfile.load()
    
    @AppStorage("isNotificationsScheduled") private var isNotificationsScheduled: Bool = false

    var body: some View {
        ZStack {
            AppBackground()
            if showNextView {
                TryHoldWorkoutView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .zIndex(1)
            } else {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Image("holdIcon")
                            Spacer()
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 14)
                    }
                    VStack(spacing: 0) {
                        Text("Good News \(userProfile.name)")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.white)
                            .padding(.top, 34)
                            .padding(.horizontal,33)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("We’ve put together a personalized plan to help you get back complete control over your body and achieve goal of lasting **\(UserStorage.wantToLastTime)**")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                            .padding(.top, 34)
                            .padding(.horizontal,32)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("You’ll be able to get real lasting results and all it will take is **5 minutes** per day.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                            .padding(.top, 34)
                            .padding(.horizontal,32)
                            .multilineTextAlignment(.center)

                        Image("goodNewsIcon")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal, 60)
                            .padding(.top, 60)
                            .padding(.bottom, 48)
//                        Spacer()
                        HStack {
                            Rectangle()
                                .frame(width: 6,height: 99)
                                .cornerRadius(3)
                                .foregroundColor(Color(hex: "#FF1919"))
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Most men notice real improvements within the first month.")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer().frame(height: 23)
                                Text("Stick with it—your control, stamina, and confidence start leveling up fast.")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.horizontal,30)
                        
                        Spacer()
                        
                        Button(action: {
                            triggerHaptic()
                            withAnimation {
                                showNextView = true
                                if !isNotificationsScheduled {
                                    scheduleNotifications()
                                }
                            }
                        }) {
                            Text("Next")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity, maxHeight: 47)
                                .background(Color(hex: "#FF1919"))
                                .foregroundColor(.white)
                                .cornerRadius(30)
                                .padding(.horizontal, 56)
                        }
                        .padding(.bottom, 32)
                        .padding(.top)
                        
                    }
                }
            }
        }
        .animation(.easeInOut, value: showNextView)
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func scheduleNotifications() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            notificationsManager.requestPermission()
        }
    }
}

#Preview {
    GoodNewsView()
}
