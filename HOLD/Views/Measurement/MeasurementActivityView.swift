//
//  MeasurementActivityView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 09/04/2025.
//

import SwiftUI
import UIKit

struct MeasurementActivityView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @State private var userProfile: UserProfile = UserProfile.load()
    
    @State private var hold = false
    @State private var finish = false
    @State private var holdTime: Double = 0
    @State private var hapticTimer: Timer? = nil
    
    @State private var isExpanded = false
    @State private var shakeTrigger: CGFloat = 0
    @State private var trembleTimer: Timer? = nil
    @State private var showResults = false
    @State private var blurAmount: CGFloat = 0
    @State private var hasHeld = false
    var onBack: (TimeInterval) -> Void

    var body: some View {
        ZStack {
            AppBackground()
            
            VStack {
                HStack {
                    Spacer()
                    Image("holdIcon")
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.bottom, 14)
                
                Spacer().frame(height: 100)
                
                
                Text("Contract & Hold Your PF Muscles For as Long as you Can")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 50)
                
                ZStack {
                    Circle()
                        .fill(
                            EllipticalGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.6, green: 0.06, blue: 0.06).opacity(0), location: 0.51),
                                    Gradient.Stop(color: Color(red: 1, green: 0.1, blue: 0.1), location: 1.00),
                                ],
                                center: UnitPoint(x: 0.5, y: 0.5)
                            )
                        )
                        .frame(width: 170, height: 170)
                        .scaleEffect(isExpanded ? 1.3 : 1)
                        .modifier(ShakeEffect(animatableData: shakeTrigger))
                        .animation(.easeInOut(duration: 0.5), value: isExpanded)

                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        .frame(width: 300, height: 300)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 1, green: 0.1, blue: 0.1), location: 0.00),
                                    Gradient.Stop(color: Color(red: 0.6, green: 0.06, blue: 0.06), location: 1.00),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: 0),
                                endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                        )
                        .stroke(.white, lineWidth: 1)
                        .frame(height: 170)
                        .animation(.easeInOut(duration: 0.3), value: hold)
                    
                    Text("Press &\nHOLD")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(hold == true ?.white.opacity(0.5) : .white)
                        .multilineTextAlignment(.center)
                }
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !hold {
                            hold = true
                            holdTime = 0
                            isExpanded = true
                            startTrembleLoop()
                            startHapticLoop()
                            hasHeld = true
                        }
                    }
                    .onEnded { _ in
                        hold = false
                        finish = true
                        isExpanded = false
                        stopTrembleLoop()
                        stopHapticLoop()
                        withAnimation(.easeInOut(duration: 0.6)) {
                            blurAmount = 30
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                showResults = true
                            }
                        }
                    }
                )
                .padding(.top,66)
                
                Spacer()
                
                if !hold && !hasHeld {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .regular))
                        Text("Hold the red button and contract the PF Muscle for as long as you can")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .regular))
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.19, green: 0.19, blue: 0.19))
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.6), value: hold)
            .blur(radius: blurAmount)
        }
        .overlay(
            Group {
                if showResults {
                    VStack {
                        Spacer()
                        resultsView
                        Spacer()
                        Button(action: {
                            triggerHaptic()
                            withAnimation(.easeInOut(duration: 0.6)) {
                                blurAmount = 0
                                onBack(holdTime)
                            }
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
                        .padding(.bottom, 32)
                    }
                    .padding(.horizontal, 20)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.6), value: showResults)
                }
            }
        )
        .navigationBarHidden(true)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    var resultsView: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#990000"), Color(hex: "#FF0000")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Holder")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.4))
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                        Spacer()
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Held for:")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Text(String(format: "%.fs", holdTime))
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
            .frame(height: 265)
            
            HStack {
                Color.white
            }
            .frame(height: 1)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Name")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                    Text(userProfile.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .center, spacing: 2) {
                    Text("All-time Best")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                    Text(formatDuration(progressViewModel.allTimeBest))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .frame(height: 87)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex: "#393939"))
            .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
            
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white, lineWidth: 1)
        )
        .frame(width: 269)
        .shadow(radius: 8)
        .padding(.top, 50)
    }
    
    func formatDuration(_ duration: Double?) -> String {
        guard let duration = duration, duration > 0 else { return "0 sec" }
        return String(format: "%.0fs", duration)
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func startHapticLoop() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            holdTime += 0.1
            generator.impactOccurred()
        }
    }

    func stopHapticLoop() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }

    // MARK: - Animation Methods
    func startTrembleLoop() {
        trembleTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.linear(duration: 0.1)) {
                shakeTrigger += 1
            }
        }
    }

    func stopTrembleLoop() {
        shakeTrigger = 0
        trembleTimer?.invalidate()
        trembleTimer = nil
    }
}

#Preview {
    MeasurementActivityView(onBack: { _ in })
        .environmentObject(ProgressViewModel())
}

