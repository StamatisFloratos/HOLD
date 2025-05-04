//
//  MeasurementActivityView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 09/04/2025.
//

import SwiftUI

struct MeasurementActivityView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @State private var hold = false
    @State private var finish = false
    @State private var holdTime: Int = 0
    @State private var hapticTimer: Timer? = nil
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
                
                Spacer().frame(height: 103)
                
                
                Text(hold ? "HOLD" : "Contract & Hold Your PF\nMuscles For as Long as\nYou Can")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .frame(height: 87)
                
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: hold
                                                   ? [Color(hex: "#990F0F"), Color(hex: "#FF1919")]
                                                   : [Color(hex: "#FF1919"), Color(hex: "#990F0F")]
                                                  ),
                                center: .center,
                                startRadius: 10,
                                endRadius: 85
                            )
                        )
                        .frame(height: 170)
                        .animation(.easeInOut(duration: 0.3), value: hold)
                    
                    Text("Press &\nHOLD")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(hold == true ?.white.opacity(0.8) : .white)
                        .multilineTextAlignment(.center)
                }
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !hold {
                            hold = true
                            holdTime = 0
                            startHapticLoop() // Start continuous haptics
                        }
                    }
                    .onEnded { _ in
                        hold = false
                        finish = true
                        stopHapticLoop() // stop continous haptic
                        onBack(Double(holdTime))
                    }
                )
                .padding(.top,106)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Haptic Feedback Methods
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func startHapticLoop() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            holdTime += 1
            generator.impactOccurred()
        }
    }

    func stopHapticLoop() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }
}

#Preview {
    MeasurementActivityView(onBack: { _ in })
        .environmentObject(ProgressViewModel())
}

