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
    @State private var timer: Timer? = nil
   
    
    var body: some View {
        ZStack {
            // Background gradient with specified hex colors
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
                HStack {
                    Spacer()
                    Image("holdIcon")
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.bottom, 14)
                
                Spacer().frame(height: 117)
                
                if !finish {
                    Text(hold ? "HOLD" : "Contract & Hold Your PF\nMuscles For as Long as\nYou Can")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .frame(height: 100)
                    
                    
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
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !hold {
                                    hold = true
                                    holdTime = 0
                                    startTimer()
                                    triggerHaptic()
                                }
                            }
                            .onEnded { _ in
                                hold = false
                                finish = true
                                stopTimer()
                                progressViewModel.measurementDidFinish(duration: Double(holdTime))
                            }
                    )
                    .padding(.top,106)
                    
                    Spacer()
                    
                }
                else {
                    VStack(spacing:37) {
                        Text("💪")
                            .font(.system(size: 64, weight: .semibold))
                        Text("You held for:")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text(holdTime.description + " seconds")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                    Button(action: {
                        navigationManager.pop(to: .mainTabView)
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
                    .padding(.bottom, 15)
                }
            }
            
            
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Timer Methods
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            holdTime += 1
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    MeasurementActivityView()
        .environmentObject(ProgressViewModel())
}

