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
            AppBackground()
            
            VStack {
                VStack(spacing:0) {
                    // Logo at the top
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 14)
                    

                    Text("Your Rank is:")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding(.bottom,42)
                        .padding(.top,10)
                    
                    
                    rankView
                    
                    if challengeViewModel.latestChallengeResult.rank == .gigaChad {
                        Spacer()
                        Text("This is the top rank.\nYou’re in a league of your own.")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(height: 48)
                            .multilineTextAlignment(.center)
                            .padding(.top,40)
                        Spacer()
                    }
                    else {
                        
                        Text("Progress Until Next Rank")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.top,20)
                            .padding(.bottom,17)
                        VStack(spacing:0) {
                            ProgressBarView(value: challengeViewModel.latestChallengeResult.duration, total: Double(challengeViewModel.latestChallengeResult.nextRankValue))
                                .frame(maxWidth: .infinity)
                                .frame(height: 12)
                                .foregroundColor(Color(hex: "#0CFF00"))
                            HStack{
                                Text(challengeViewModel.latestChallengeResult.timeDisplayForProgress(duration: challengeViewModel.latestChallengeResult.duration))
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                                Text(challengeViewModel.latestChallengeResult.timeDisplayForProgress(duration: challengeViewModel.latestChallengeResult.nextRankValue))
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.top,17)
                            .padding(.horizontal,20)
                        }
                        .padding(.horizontal,52)
                    }
                }
                
                
                Spacer()
                    .frame(minWidth: 0, maxWidth: 44)

                Button(action: {
                    triggerHaptic()
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
                .padding(.horizontal, 55)
                .padding(.bottom, 15)
            }
        }
        .onAppear{
            challengeViewModel.challengeDidFinish(duration: 400)
        }
        .navigationBarHidden(true)
    }
    
    var rankView: some View {
        VStack(spacing:0) {
            Image(challengeViewModel.latestChallengeResult.rankImage)
                .resizable()
                .scaledToFill()
                .frame(height: 208)
            ZStack {
                LinearGradient(
                    colors: challengeViewModel.latestChallengeResult.backgroundColor,
                    startPoint: .top,
                    endPoint: .bottom
                )
                VStack(spacing:0){
                    Text("Duration")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor((challengeViewModel.latestChallengeResult.rank == .npc || challengeViewModel.latestChallengeResult.rank == .simp) ? .black : .white)
                    
                    Text(challengeViewModel.latestChallengeResult.durationDisplay)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor((challengeViewModel.latestChallengeResult.rank == .npc || challengeViewModel.latestChallengeResult.rank == .simp) ? .black : .white)
                    
                    Text("Rank")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor((challengeViewModel.latestChallengeResult.rank == .npc || challengeViewModel.latestChallengeResult.rank == .simp) ? .black : .white)
                        .padding(.top,19)
                    
                    Text(challengeViewModel.latestChallengeResult.rankDisplay.uppercased())
                        .italic()
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor((challengeViewModel.latestChallengeResult.rank == .npc || challengeViewModel.latestChallengeResult.rank == .simp) ? .black : .white)
                        .padding(.top,0)
                        
                }
                
            }.frame(height: 164)
        }
        .frame(width: 289)
        .cornerRadius(25)
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    ChallengeRankView()
        .environmentObject(ChallengeViewModel())
}
