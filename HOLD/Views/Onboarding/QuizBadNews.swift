//
//  QuizBadNews.swift
//  HOLD
//
//  Created by Hafiz Muhammad Ali on 31/05/2025.
//

import SwiftUI

struct QuizBadNews: View {
    @EnvironmentObject private var notificationsManager: NotificationsManager
    
    @State private var showNextView = false
    @State private var animatedProgress: Double = 0.0
    @State private var isFirstView = true
    
    @AppStorage("isNotificationsScheduled") private var isNotificationsScheduled: Bool = false
    
    var body: some View {
        ZStack {
            AppBackground()
            if showNextView {
                ReviewView()
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
                    
                    Spacer().frame(height: 100)
                    
                    VStack(spacing: 0) {
                        Text("We’ve got some news we need to break to you...")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        HStack {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                ProgressBarView(value: animatedProgress, total: 100, backgroundColor: Color(hex: "#626262"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 22)
                                    .foregroundStyle(
                                        isFirstView ? LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: "#990F0F"),
                                                Color(hex: "#FF1919")
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ) : LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: "#00FF2A"),
                                                Color(hex: "#00FF2A")
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            Text("🏆")
                                .font(.system(size: 32, weight: .semibold))
                        }
                        .padding(.top, 46)
                        
                        if isFirstView {
                            VStack {
                                Spacer()
                                
                                (
                                    Text("Based on your answers you are only reaching ") +
                                    Text("13%").foregroundColor(Color(hex: "#FF0000")) +
                                    Text(" of your potential.")
                                )
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                
                                Spacer()
                                
                                (
                                    Text("That places you in the ") +
                                    Text("bottom 20%").foregroundColor(Color(hex: "#FF0000")) +
                                    Text(" of men worldwide.")
                                )
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                
                                Spacer()
                                
                                Text("But it’s not all bad...")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Spacer()
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                        } else {
                            VStack {
                                Spacer()
                                
                                (
                                    Text("Based on your answers you can reach your goal of lasting ") +
                                    Text("\(UserStorage.wantToLastTime)").foregroundColor(Color(hex: "#00FF2A")) +
                                    Text(" by \(getFormattedDate())")
                                )
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                
                                Spacer()
                                
                                (
                                    Text("That will place you in the ") +
                                    Text("top 1.3%").foregroundColor(Color(hex: "#00FF2A")) +
                                    Text(" of men worldwide.")
                                )
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                
                                Spacer()
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                        }
                    }
                    .padding(.horizontal,35)

                    Spacer()

                    Button(action: {
                        triggerHaptic()
                        withAnimation {
                            if isFirstView {
                                isFirstView = false
                                animatedProgress = 98
                            } else {
                                showNextView = true
                                if !isNotificationsScheduled {
                                    scheduleNotifications()
                                }
                            }
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
                    .padding(.bottom, 15)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear{
            withAnimation(.easeInOut(duration: 1)) {
                animatedProgress = 13
            }
        }
        .animation(.easeInOut, value: showNextView)
        .animation(.easeInOut, value: isFirstView)
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func getFormattedDate() -> String {
        let futureDate = Calendar.current.date(byAdding: .day, value: 60, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        let formattedDate = formatter.string(from: futureDate)
        
        return formattedDate
    }
    
    func scheduleNotifications() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            notificationsManager.requestPermission()
        }
    }
}

#Preview {
    QuizBadNews()
        .environmentObject(NotificationsManager.shared)
}
