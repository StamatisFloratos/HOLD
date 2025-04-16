//
//  WorkoutTabView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI

struct WorkoutTabView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var tabManager: TabManager
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex:"#10171F"),
                    Color(hex:"#466085")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Logo at the top
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    HStack {
                        Text("Today's Workout")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    workoutView
                    streakView
                    
                    
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Spacer(minLength: 80) // Space for tab bar
            }
        }
        .navigationBarHidden(true)
    }
    
    var workoutView: some View {
        VStack(spacing: 36) {
            VStack(spacing: 20) {
                Text("Workout Name")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                Circle()
                    .frame(height: 88)
                
                Text("Status: Not Completed")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("**Difficulty:** Easy")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                Text("**Duration:** 20 seconds")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                Text("**Description:** These beginner level exercises will help you strengthen your pelvic muscles")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            
            Button(action: {
                // Handle measurement action
                navigationManager.push(to: .measurementActivityView)
            }) {
                Text("Start Workout")
                    .font(.system(size: 16, weight: .semibold))
                    .padding()
                    .frame(maxWidth: .infinity,maxHeight: 47)
                    .background(Color(hex: "#FF1919"))                        .foregroundColor(.white)
                    .cornerRadius(30)
            }
            .padding(.horizontal, 50)
            .padding(.bottom, 15)
        }
        .padding(.vertical)
        .background(Color(hex: "#161616").opacity(0.4))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20) // Custom background with border
                .stroke(Color.gray, lineWidth: 1) // Custom border
                .cornerRadius(12)
        )
        

    }
    
    var streakView: some View {
        VStack(alignment:.leading, spacing: 23) {
            VStack(alignment:.leading, spacing: 0) {
                Text("Keep Going!")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("You’re on a 12-day streak!")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                
            }
            .padding(.leading)
            
            // Week Streak View
            HStack() {
                Spacer()
                let completedDays = [true, false, true, false, true, false, false]
                let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sut"]
                
                ForEach(0..<7) { index in
                    DayCircleView(day: daysOfWeek[index], isCompleted: completedDays[index])
                    Spacer()
                }

            }
        }
        .padding(.vertical)
        .background(Color(hex: "#161616").opacity(0.4))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 1)
                .cornerRadius(12)
        )
        
        
    }
}

struct DayCircleView: View {
    let day: String
    let isCompleted: Bool

    var body: some View {
        VStack(spacing: 5) {
            

            if isCompleted {
                // Filled circle/icon for completed days
                Image(systemName: "checkmark.circle.fill") // Using a checkmark icon
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(hex: "#FF1919")) // Your accent color
            } else {
                // Outline circle for incomplete days
                Circle()
//                    .strokeBorder(Color.gray, lineWidth: 1.5)
                    .foregroundStyle(Color(hex: "#606060")) // Ensure transparent background
                    .frame(width: 30, height: 30)
            }
            Text(day)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    WorkoutTabView()
        .environmentObject(TabManager())
}
