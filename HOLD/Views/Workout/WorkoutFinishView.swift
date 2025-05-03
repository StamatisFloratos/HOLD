//
//  WorkoutFinishView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation
import SwiftUI

struct WorkoutFinishView: View {
//    @EnvironmentObject var navigationManager: NavigationManager
    var onBack: () -> Void
    var body: some View {
        ZStack {
            AppBackground()
            VStack{
                HStack {
                    Spacer()
                    Image("holdIcon")
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.bottom, 14)
                
                Spacer().frame(height: 122)
                
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
                    onBack()
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
//    WorkoutFinishView(onBack: /*print("pressed continue")*/)
}
