//
//  MeasurementActivityView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 09/04/2025.
//

import SwiftUI

struct MeasurementActivityView: View {
    @State private var hold = false
    @State private var finish = false
    @State private var holdTime: Int = 0
    @State private var timer: Timer? = nil
    @EnvironmentObject var navigationManager: NavigationManager

    
    var body: some View {
        ZStack {
            // Background gradient with specified hex colors
            LinearGradient(
                colors: [
                    Color(red: 16/255, green: 23/255, blue: 31/255),  // #10171F
                    Color(red: 70/255, green: 96/255, blue: 133/255)  // #466085
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
                    
                }.padding(.top, 20)
                    .padding(.horizontal)
                
                Spacer().frame(height: 117)
                
                if !finish {
                    Text(hold ? "HOLD" : "Contract & Hold Your PF\nMuscles For as Long as\nYou Can")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .frame(height: 100)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .fill(Color.red)
                                .frame(height: 170)
                            Text("Press &\nHOLD")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .simultaneousGesture(
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
                            }
                    )
                    
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
                        // Handle measurement action
                        navigationManager.pop(to: .progressView)
                    }) {
                        Text("Continue")
                            .font(.system(size: 16, weight: .semibold))
                            .padding()
                            .frame(maxWidth: .infinity,maxHeight: 47)
                            .background(Color.red)
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
}

