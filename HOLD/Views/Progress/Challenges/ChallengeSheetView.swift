//
//  ChallengeSheetView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI

struct ChallengeSheetView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dismiss) var dismiss
    var onBack: () -> Void
    @State private var showChallengeActivityView: Bool = false

    
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
                    Image("challengeIcon")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .padding(.top,113)
                    Text("You’re about to start\n“The Challenge”")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding(.top,37)
                    Text("Tests your stamina by practicing different rhythmic patterns on your own so that you're ready when it matters the most.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding(.top,36)
                        .padding(.horizontal,45)
                }

                VStack(alignment: .leading,spacing: 0) {
                    Text("Make sure that:")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.bottom,18)
                    
                    BulletTextView(text: "You have complete privacy.")
                    BulletTextView(text: "You follow the rhythm at all times, when you finish, you need to press stop.")
                }
                .padding(.horizontal,38)
                .padding(.top,48)
                
                Spacer()
                Button(action: {
                    triggerHaptic()
                    onBack()
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
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct BulletTextView: View {
    let text: String
    
    var body: some View {
        HStack(alignment:.top,spacing: 5) {
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
    ChallengeSheetView(onBack: {
        //
    })
}

