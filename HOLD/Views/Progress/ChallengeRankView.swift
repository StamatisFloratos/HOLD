//
//  ChallengeRankView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 24/04/2025.
//

import SwiftUI

struct ChallengeRankView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var challengeViewModel: ChallengeViewModel

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
                VStack {
                    // Logo at the top
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    .padding(.top, 20)
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

                            ProgressView(value: challengeViewModel.latestChallengeResult!.duration / Double(challengeViewModel.latestChallengeResult!.nextRankValue))
                                .progressViewStyle(LinearProgressViewStyle())
                                .accentColor(Color(hex: "#0CFF00"))
                                .scaleEffect(x: 1, y: 2, anchor: .center) // adjust height multiplier
                                .frame(height: 10) // match height of background
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        HStack{
                            Text(challengeViewModel.latestChallengeResult!.durationDisplay)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                            Text(challengeViewModel.latestChallengeResult!.timeDisplay(duration: challengeViewModel.latestChallengeResult!.nextRankValue))
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                
                
                Button(action: {
                    navigationManager.pop(to: .mainTabView)
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
            Image(challengeViewModel.latestChallengeResult!.rankImage)
                .resizable()
                .scaledToFill()
//                .frame(width: 289)
            ZStack {
                LinearGradient(
                    colors: challengeViewModel.latestChallengeResult!.backgroundColor,
                    startPoint: .top,
                    endPoint: .bottom
                )
                VStack{
                    Text("Duration")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor((challengeViewModel.latestChallengeResult!.rank == .npc || challengeViewModel.latestChallengeResult!.rank == .simp) ? .black : .white)
                    Text(challengeViewModel.latestChallengeResult!.durationDisplay)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor((challengeViewModel.latestChallengeResult!.rank == .npc || challengeViewModel.latestChallengeResult!.rank == .simp) ? .black : .white)
                    Text("Rank")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor((challengeViewModel.latestChallengeResult!.rank == .npc || challengeViewModel.latestChallengeResult!.rank == .simp) ? .black : .white)
                    Text(challengeViewModel.latestChallengeResult!.rankDisplay.uppercased())
                        .italic()
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor((challengeViewModel.latestChallengeResult!.rank == .npc || challengeViewModel.latestChallengeResult!.rank == .simp) ? .black : .white)
                        
                }
                
            }.frame(height: 144)
        }
        .frame(width: UIScreen.main.bounds.width - 32)
        .cornerRadius(25)
    }
}

#Preview {
    ChallengeRankView()
        .environmentObject(ChallengeViewModel())
}
