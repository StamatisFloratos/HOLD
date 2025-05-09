//
//  ReviewView 2.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 08/05/2025.
//
import Foundation
import SwiftUI

struct MilestoneView: View {
    @State private var showNextView = false
    var milestoneTitle: String = "Milestone 1"

    var progress: Int = 40
        var name: String = "Jack"
        var streak: String = "1 day"
        var badge: String = "Holder"
    
    var body: some View {
        ZStack {
            AppBackground()
            if showNextView {
                SubscriptionView()
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
                    
                    Text("Welcome to HOLD, your personal\nperformance trainer.")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal,35)
                    Spacer()
                    //milestoneView
                    milestoneView
                    
                    Spacer()
                    
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    var milestoneView: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#990000"), Color(hex: "#FF0000")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Holder")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.4))
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                        Spacer()
                        Text(milestoneTitle)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Progress")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Text("\(progress)%")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
            .frame(height: 265)
            
            HStack {
                Color.white
            }
            .frame(height: 1)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Name")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                    Text(UserStorage.username)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Active Streak")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                    Text(streak)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .frame(height: 87)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex: "#393939"))
            .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
            
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white, lineWidth: 1)
        )
        .frame(width: 269)
        .shadow(radius: 8)
    }
}

#Preview {
    MilestoneView()
}
