//
//  ChallengeRankView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 24/04/2025.
//

import SwiftUI

struct ChallengeRankView: View {
    @Environment(\.presentationMode) var presentationMode
    var challengeResult: ChallengeResult
    
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
                    Spacer()
                    
                    Text("Your Rank is:")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                    Spacer()
                    rankView
                        .padding(.horizontal)
                    Spacer()
                    Text("Progress Until Next Rank")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    VStack{
                        ZStack {
                            // Background track with rounded corners
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 10)

                            ProgressView(value: challengeResult.duration / Double(challengeResult.nextRankValue))
                                .progressViewStyle(LinearProgressViewStyle())
                                .accentColor(Color(hex: "#0CFF00"))
                                .scaleEffect(x: 1, y: 2, anchor: .center) // adjust height multiplier
                                .frame(height: 10) // match height of background
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        HStack{
                            Text(challengeResult.durationDisplay)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                            Text(challengeResult.timeDisplay(duration: challengeResult.nextRankValue))
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                
                
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
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
    
    var rankView: some View {
        VStack(spacing:0) {
            Image(challengeResult.rankImage)
                .resizable()
                .scaledToFill()
//                .frame(width: 289)
            ZStack {
                LinearGradient(
                    colors: challengeResult.backgroundColor,
                    startPoint: .top,
                    endPoint: .bottom
                )
                VStack{
                    Text("Duration")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor((challengeResult.rank == .npc || challengeResult.rank == .simp) ? .black : .white)
                    Text(challengeResult.durationDisplay)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor((challengeResult.rank == .npc || challengeResult.rank == .simp) ? .black : .white)
                    Spacer().frame(height: 19)
                    Text("Rank")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor((challengeResult.rank == .npc || challengeResult.rank == .simp) ? .black : .white)
                    Text(challengeResult.rankDisplay.uppercased())
                        .italic()
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor((challengeResult.rank == .npc || challengeResult.rank == .simp) ? .black : .white)
                        
                }
                
            }.frame(height: 164)
        }
        .frame(width: 289)
        .cornerRadius(25)
    }
}

#Preview {
    ChallengeRankView(challengeResult: ChallengeResult(duration: 2400))
}
