//
//  WorkoutView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation
import SwiftUI

struct WorkoutSheetView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @Environment(\.dismiss) var dismiss
    var onBack: () -> Void


    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(spacing: 0) {
                // Logo at the top
                ZStack {
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    
                    
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image("crossIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 21)
                        }
                        .padding(.trailing,26)
                        
                    }
                    
                }
                .padding(.top, 24)
                .padding(.bottom, 14)
                
                VStack(spacing: 0) {
                    Image("workoutIconLarge")
                        .resizable()
                        .frame(width: 77, height: 77)
                        .padding(.top,113)
                    Text("You’re about to start\na workout.")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding(.top,45)

                }
                
                VStack(alignment: .leading,spacing: 0) {
                    Text("Make sure that:")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.bottom,18)
                    
                    BulletTextView(text: "You are in a quiet place where you can focus")
                    BulletTextView(text: "You turned on “Do Not Disturb” on your phone")
                    BulletTextView(text: "You have at least 5 minutes")
                }
                .padding(.horizontal,28)
                .padding(.top,71)
                
                Spacer()
                Button(action: {                
                    triggerHaptic()
                    onBack()
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
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
}


#Preview {
    WorkoutSheetView(onBack: {})
}

