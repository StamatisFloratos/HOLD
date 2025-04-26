//
//  WorkoutFinishView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation
import SwiftUI

struct WorkoutFinishView: View {
    @EnvironmentObject var navigationManager: NavigationManager

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
            VStack{
                VStack(spacing: 20) {
                    // Logo at the top
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    
                }.padding(.top, 20)
                    .padding(.horizontal)
                
                Spacer().frame(height: 117)
                
                VStack(spacing:37) {
                    Text("🎉")
                        .font(.system(size: 64, weight: .semibold))
                    Text("Congratulations!")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("You finished today’s workout!")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                
                VStack(spacing: 5) {
                    Text("Finish")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 4)
                        .frame(width: 60)
                }
                Spacer().frame(height: 61)
                
                Button(action: {
                    navigationManager.pop(to: .mainTabView)
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
        .navigationBarHidden(true)
    }
}

#Preview {
    return WorkoutFinishView()
}
