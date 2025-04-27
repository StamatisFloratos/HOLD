//
//  ChallengeSheetView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI

struct ChallengeSheetView: View {
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
            
            VStack {
                VStack(spacing: 20) {
                    // Logo at the top
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    
                    Image("challengeIcon")
                        .padding(.vertical,45)
                    Text("You're about to start\nThe Challenge")
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
                    
                    BulletTextView(text: "You have complete privacy.")
                    BulletTextView(text: "Turned on Do Not Disturb")
                    BulletTextView(text: "You follow the rhythm at all times, when you finish, you need to press stop.")
                    BulletTextView(text: "Once The Challenge starts it cannot be paused.")
                }
                .padding(.horizontal)
                
                Spacer()
                Button(action: {
                    navigationManager.push(to: .challengeActivityView)
                }) {
                    Text("Start The Challenge")
                        .font(.system(size: 16, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity,maxHeight: 47)
                        .background(Color(hex: "#FF5E00"))
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 15)
            }
        }
        .navigationBarHidden(true)
//        .fullScreenCover(isPresented: $showingChallengeActivityView,
//                         onDismiss: {
//            print("ChallengeActivityView dismissed, now dismissing ChallengeSheetView.")
//            self.presentationMode.wrappedValue.dismiss()
//        }) {
//            ChallengeActivityView { elapsedTime in
//                // Save the challenge result
//                print("Challenge completed with total time: \(elapsedTime)")
//                viewModel.challengeDidFinish(duration: elapsedTime)
//            }
//        }
    }
    
    
}

struct BulletTextView: View {
    let text: String
    
    var body: some View {
        HStack(alignment:.top) {
            Text("•")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            Text(text)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ChallengeSheetView()
}

