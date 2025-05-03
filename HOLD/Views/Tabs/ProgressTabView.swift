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
                    HStack {
                        Text("Welcome back")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text("💪")
                            .font(.title)
                        Spacer()
                    }
                    .padding(.horizontal,39)
                    .padding(.bottom,39)
                    .padding(.top,20)
                    
                    
                    
                    progressChart
                    progressIndicator
                    challengeView
                    
                    Spacer(minLength: 80)
                }
                
            }
        }
        .navigationBarHidden(true)
    }
    
    var progressIndicator: some View {
        let minValue = 3.0
        let maxValue = 300.0
        let currentValue = progressViewModel.mostRecentMeaurementTime // most recent
        let progress = (currentValue - minValue) / (maxValue - minValue)

        return VStack(spacing: 6) {
            // Progress slider visualization with moving triangle
            VStack(spacing:0) {
                // Moving triangle
                GeometryReader { geo in
                    VStack(spacing:2) {
                        Text("You")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Image(systemName: "triangle.fill")
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(180))
                    }
                    .offset(x: progress * (geo.size.width - 20))                              // 20 is to avoid going out of bounds
                }.frame(height: 33)
                
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "FF0000"), Color(hex: "FFC800"), Color(hex: "00FF09")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 33)
                    .cornerRadius(20)
                    // Emoji ends
                    HStack {
                        Text("😭")
                            .font(.title)
                        Spacer()
                        Text("😩")
                            .font(.title)
                    }
                }.padding(.top,2)
            }
            
            HStack {
                Text("\(Int(minValue)) sec")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Text("\(Int(maxValue)) sec")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal,28)
        .padding(.top, 16)
        .padding(.bottom, 31)

    }

    
    
    var progressChart: some View {
        VStack(alignment: .leading) {
            Text("Training Progress")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal,39)
                .padding(.bottom,19)
            
            HStack {
                Text("All Time Best: \(formatDuration(progressViewModel.allTimeBest))")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
                Text("Weekly Best: \(formatDuration(progressViewModel.weeklyBest))")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal,39)
            .padding(.bottom,7)
            
            // Progress Chart Container
            
            
            VStack {
                HStack{
                    Text(progressViewModel.weekDateRange)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top,16)
                .padding(.horizontal,21)
                
                Chart {
                    ForEach(progressViewModel.chartDisplayData) { dailyData in
                        BarMark(
                            x: .value("Day", dailyData.day),
                            y: .value("Duration", dailyData.duration ?? 0.0)
                        )
                        .foregroundStyle(Color(hex:"#FF1919")) // red for bars
                        .cornerRadius(5, style: .continuous)
                        
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(.clear)
                        AxisTick()
                            .foregroundStyle(.clear)
                        AxisValueLabel()
                            .foregroundStyle(.white)
                            .font(.system(size: 12, weight: .regular))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(.white.opacity(0.5))
                        AxisTick()
                            .foregroundStyle(.clear)
                        AxisValueLabel {
                            if let val = value.as(Double.self) {
                                Text("\(Int(val)) sec")
                                    .foregroundStyle(.white)
                            }
                        }
                        .font(.system(size: 10, weight: .regular))
                    }
                }
                .foregroundStyle(Color.white)
                .frame(height: 150) // Adjust height as needed
                .padding(.horizontal)
                
                
                // Take Measurement Button
                Button {
                    triggerHaptic()
                    navigationManager.push(to: .measurementView)
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
                .padding(.top,42)
            }
            .background(Color(hex: "#000000").opacity(0.4))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    .cornerRadius(12)
            )
            .padding(.horizontal,28)
        }
        
    }
    
    var challengeView: some View {
        // Challenge section
        VStack(spacing:0) {
            if let latestChallengeResult = challengeViewModel.latestChallengeResult {
                HStack{
                    VStack(alignment: .leading, spacing: 26) {
                        Text("The Challenge")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Last Attempt: \(latestChallengeResult.dateOfChallenge())")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white).opacity(0.4)
                    }
                    Spacer()
                }
                .padding(.horizontal,39)
                .padding(.bottom,9)

                
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
                    Text(latestChallengeResult.challengeDescription)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top,18)
                        .padding(.bottom,17)
                    
                    
                    // Start Challenge Button
                    Button {
                        triggerHaptic()
                        navigationManager.push(to: .challengeActivityView)
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
                        .cornerRadius(12)
                )
                .padding(.horizontal,28)
                
            } else {
                HStack{
                    VStack(alignment: .leading, spacing: 26) {
                        Text("The Challenge")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Last Attempt: Never")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white).opacity(0.4)
                    }
                    Spacer()
                }
                .padding(.horizontal,39)
                .padding(.bottom,9)
                
                
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
                        navigationManager.push(to: .challengeSheetView)
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
                .background(.black.opacity(0.4))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        .cornerRadius(12)
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
}
