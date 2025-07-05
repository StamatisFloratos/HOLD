//
//  ProgressTabView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI
import Charts

struct ProgressTabView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    @EnvironmentObject var workoutViewModel: WorkoutViewModel

    @State private var showChallengeView = false
    @State private var showMeasurementView = false
    @State private var dragOffset: CGFloat = 0.0
    let segmentModes = ProgressChartMode.allCases
    
    var body: some View {
        ZStack {
            AppBackground()
            
            
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Image("holdIcon")
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.bottom, 14)
                
                ScrollView(showsIndicators: false) {
                    badgesView
                    progressChartWithPaging
                    challengeView
                    
                    Spacer(minLength: 80)
                }
                
            }
            
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showChallengeView) {
            ChallengeView(onBack: {
                showChallengeView = false
            })
        }
        .fullScreenCover(isPresented: $showMeasurementView) {
            MeasurementView(onBack: {
                showMeasurementView = false
            })
            .environmentObject(progressViewModel)
        }
    }
    
    var badgesView: some View {
        VStack(spacing: 15) {
            Text("Badges")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(workoutViewModel.badgeManager.badges) { badge in
                        if badge.isEarned {
                            Image(badge.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 88, height: 88)
                        } else {
                            Image("badge_locked")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 88, height: 88)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
    }
    
    var progressChartWithPaging: some View {
        VStack(alignment: .center) {
            HStack {
                Text("Training Progress")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
            
            HStack {
                Image("BestResultsIcon")
                    .frame(width: 35, height: 35)
                
                VStack (alignment: .leading, spacing: 2) {
                    Text("Best Result")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text(formatDuration(progressViewModel.bestResult))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                
                
                Spacer()
                
                VStack (alignment: .trailing, spacing: 2) {
                    Text("Last Measurement")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text(progressViewModel.latestMeasurementDateString())
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal,40)
            .padding(.bottom,8)
            
            VStack {
                HStack {
                    Button(action: { 
                        progressViewModel.goToPreviousPage()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(progressViewModel.canGoToPreviousPage() ? .white : .gray)
                    }
                    .disabled(!progressViewModel.canGoToPreviousPage())
                    Spacer()
                    Text(progressViewModel.chartDateRangeString)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { 
                        progressViewModel.goToNextPage()
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(progressViewModel.canGoToNextPage() ? .white : .gray)
                    }
                    .disabled(!progressViewModel.canGoToNextPage())
                }
                .padding(.top,16)
                .padding(.horizontal,21)
                
                Chart {
                    ForEach(progressViewModel.chartDisplayData) { data in
                        BarMark(
                            x: .value("Label", data.day),
                            y: .value("Duration", data.duration ?? 0.0)
                        )
                        .foregroundStyle(Color(hex:"#FF1919"))
                        .cornerRadius(5, style: .continuous)
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine().foregroundStyle(.clear)
                        AxisTick().foregroundStyle(.clear)
                        AxisValueLabel().foregroundStyle(.white).font(.system(size: 10, weight: .regular))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine().foregroundStyle(.white)
                        AxisTick().foregroundStyle(.clear)
                        AxisValueLabel().foregroundStyle(.white).font(.system(size: 10, weight: .regular))
                    }
                }
                .frame(height: 180)
                .padding(.horizontal)
                .padding(.vertical, 40)
                
                Button {
                    triggerHaptic()
                    showMeasurementView = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Take Measurement")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex:"#FF1919"))
                    .foregroundColor(.white)
                    .cornerRadius(30)
                }
                .frame(width: 214, height: 47)
                .padding(.bottom, 24)
            }
            .background(Color(hex: "#242E3A"))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white, lineWidth: 0.5)
            )
            .padding(.horizontal, 16)
            
            HStack(spacing: 8) {
                ForEach(segmentModes) { mode in
                    Button(action: {
                        progressViewModel.chartMode = mode
                    }) {
                        Text(mode.displayName.capitalized)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(progressViewModel.chartMode == mode ? Color.white : Color.white.opacity(0.5))
                            .frame(width: 75)
                            .padding(.vertical, 8)
                            .background(progressViewModel.chartMode == mode ? Color(hex: "#0D151F") : Color.clear)
                            .cornerRadius(20)
                    }
                }
            }
            .background(Color(hex: "#242E3A"))
            .cornerRadius(20)
            .padding(.top, 8)
        }
    }
    
    var challengeView: some View {
        // Challenge section
        VStack(spacing:0) {
            if let latestChallengeResult = challengeViewModel.latestChallengeResult {
                HStack {
                    Text("The Challenge")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 10)
                .padding(.top, 50)
                
                HStack {
                    Image("BestResultsIcon")
                        .frame(width: 35, height: 35)
                    
                    VStack (alignment: .leading, spacing: 2) {
                        Text("Best Performance")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(challengeViewModel.bestChallengeResult.durationDisplay)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    
                    Spacer()
                    
                    VStack (alignment: .trailing, spacing: 2) {
                        Text("Last Attempt")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(challengeViewModel.lastAttemptedChallengeDateString())
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal,40)
                .padding(.bottom,8)
                
                // Progress Chart Container
                
                VStack(spacing: 0) {
                    Text("You Are in The Top:")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top,21)
                    
                    Text(latestChallengeResult.percentileDisplay)
                        .font(.system(size: 64, weight: .semibold))
                        .foregroundStyle(LinearGradient(
                            colors: latestChallengeResult.challengeColor,
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .padding(.top,19)
                    
                    Text("of Men Globally")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top,5)
                    
                    Text("You lasted for \(String(describing: latestChallengeResult.durationDisplay))")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top,18)
                        .padding(.bottom,26)
                    
                    // Start Challenge Button
                    Button {
                        triggerHaptic()
                        showChallengeView = true
                    } label: {
                        HStack {
                            Text("Start Challenge")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex:"#FF5E00"))
                        .foregroundColor(.white)
                        .cornerRadius(25)
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom,36)
                }
//                .frame(height: 350)
                .background(.black.opacity(0.4))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        .cornerRadius(20)
                )
                .padding(.horizontal,28)
                
            } else {
                HStack {
                    Text("The Challenge")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 10)
                .padding(.top, 50)
                
                HStack {
                    Image("BestResultsIcon")
                        .frame(width: 35, height: 35)
                    
                    VStack (alignment: .leading, spacing: 2) {
                        Text("Best Performance")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(challengeViewModel.bestChallengeResult.durationDisplay)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    
                    Spacer()
                    
                    VStack (alignment: .trailing, spacing: 2) {
                        Text("Last Attempt")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(challengeViewModel.lastAttemptedChallengeDateString())
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal,40)
                .padding(.bottom,8)
                
                // Progress Chart Container
                
                VStack(spacing: 10) {
                    Text("Are you ready?")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top,21)
                    
                    Spacer()
                        .frame(height: 82)
                    
                    Text("Tests your stamina by practicing different rhythmic patterns on your own so that you're ready when it matters the most.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal,17)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                        .frame(height: 82)
                    
                    // Start Challenge Button
                    Button {
                        triggerHaptic()
                        showChallengeView = true
                    } label: {
                        HStack {
                            Text("Start Challenge")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex:"#FF5E00"))
                        .foregroundColor(.white)
                        .cornerRadius(30)
                    }
                    .frame(width: 214, height: 47)
                    .padding(.bottom,36)
                }
                .background(.black.opacity(0.2))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        .cornerRadius(20)
                )
                .padding(.horizontal,28)
            }
            
        }
        
    }
    
    private func formatDuration(_ duration: Double?) -> String {
        guard let duration = duration, duration > 0 else { return "- sec" }
        return String(format: "%.0f sec", duration)
    }
    
    private func calculateHeightPercent(duration: Double?, maxDuration: Double) -> Double {
        guard let duration = duration, duration > 0, maxDuration > 0 else { return 0.0 }
        return min(1.0, duration / maxDuration)
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

// Bar component for the chart
struct Bar: View {
    let height: CGFloat
    let day: String
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 25, height: 100)
                
                Rectangle()
                    .foregroundColor(Color(hex:"#FF1919"))
                    .frame(width: 25, height: height * 100)
            }
            
            Text(day)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ProgressTabView()
        .environmentObject(TabManager())
        .environmentObject(ProgressViewModel())
        .environmentObject(ChallengeViewModel())
        .environmentObject(WorkoutViewModel())
}
