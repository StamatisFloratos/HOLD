//
//  WorkoutView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation
import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel

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
            
            VStack {
                VStack(spacing: 20) {
                    // Logo at the top
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    
                    Image("workoutIconLarge")
                        .resizable()
                        .frame(width: 77, height: 77)
                        .padding(.vertical,45)
                    Text("You’re about to start\na workout.")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Make sure that:")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.bottom,18)
                    
                    BulletTextView(text: "You are in a quiet place where you can focus")
                    BulletTextView(text: "You turned on “Do Not Disturb” on your phone")
                    BulletTextView(text: "You have at least 5 minutes")
                }
                .padding(.horizontal)
                
                Spacer()
                Button(action: {                
                    if let selectedWorkout = workoutViewModel.todaysWorkout {
                        navigationManager.push(to: .workoutDetailView(selectedWorkout: selectedWorkout))
                    }
                    
                }) {
                    Text("Start Workout")
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
        .navigationBarHidden(true)
        
    }
    
    
}


#Preview {
    WorkoutView()
}

