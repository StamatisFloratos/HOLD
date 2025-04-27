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
            LinearGradient(
                colors: [
                    Color(hex:"#10171F"),
                    Color(hex:"#466085")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    HStack {
                        Text("Welcome back")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text("💪")
                            .font(.title)
                    }
                    .padding(.horizontal)
                    
                    
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
        let currentValue = progressViewModel.allTimeBest ?? 0.0 // All time best
        let progress = (currentValue - minValue) / (maxValue - minValue)

        return VStack(spacing: 10) {
            HStack {
                
                Spacer()
            }

            // Progress slider visualization with moving triangle
            VStack(spacing:0) {
                // Moving triangle
                GeometryReader { geo in
                    VStack {
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
                    
                }

                
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
        .padding(.horizontal)
        .padding(.top, 20)
    }

    
    
    var progressChart: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Training Progress")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal)
            
            HStack {
                Text("All Time Best: \(formatDuration(progressViewModel.allTimeBest))")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
                Text("Weekly Best: \(formatDuration(progressViewModel.weeklyBest))")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            // Progress Chart Container
            
            
            VStack(spacing: 30) {
                HStack{
                    Text(progressViewModel.weekDateRange)
                        .foregroundColor(.white)
                        .font(.callout)
                        .padding(.top, 10)
                        .padding(.horizontal)
                    Spacer()
                }
                
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
                        AxisValueLabel()
                            .foregroundStyle(.white)
                            .font(.system(size: 12, weight: .regular))
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(.clear)
                        AxisTick()
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
                    .cornerRadius(25)
                }
                .padding(.horizontal, 50)
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
            .padding(.vertical, 5)
            .padding(.horizontal)
        }
        
    }
    
    var challengeView: some View {
        // Challenge section
        VStack {
            HStack{
                VStack(alignment: .leading, spacing: 30) {
                    Text("The Challenge")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Last Attempt: \(challengeViewModel.latestChallengeResult?.dateOfChallenge() ?? "-")")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white).opacity(0.4)
                }
                Spacer()
            }
            .padding(.horizontal,30)
            
            
            // Progress Chart Container
            
            VStack(spacing: 10) {
                Text("You Are in The Top:")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top)
                
                Text(challengeViewModel.latestChallengeResult?.percentileDisplay ?? "-")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(LinearGradient(
                        colors: [
                            Color(hex:"#16D700"),
                            Color(hex:"#0B7100")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .padding(.top,19)
                
                Text("of Men Globally")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                //                        .padding(.top,6)
                Text("You lasted for \(String(describing: challengeViewModel.latestChallengeResult?.durationDisplay ?? "-"))")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top,6)
                Text("😧 That’s really impressive! ")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top,6)
                
                
                // Start Challenge Button
                Button {
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
                
                Text("This challenge tests your stamina and discipline by practicing different rhythmic patterns on your own so that you're ready when it matters the most.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .background(.black.opacity(0.4))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    .cornerRadius(12)
            )
            .padding(.vertical, 5)
            .padding(.horizontal)
            
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
