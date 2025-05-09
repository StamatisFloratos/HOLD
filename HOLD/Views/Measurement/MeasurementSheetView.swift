//
//  MeasurementSheetView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI

struct MeasurementSheetView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @Environment(\.dismiss) var dismiss
    var onBack: () -> Void


    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(spacing: 0) {
                // Logo at the top
                ZStack {
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    
                    
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image("crossIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 21)
                        }
                        .padding(.trailing,26)
                        
                    }
                    
                }
                .padding(.top, 24)
                .padding(.bottom, 14)
                
                VStack(spacing: 0) {
                    Image("measurementIcon")
                        .resizable()
                        .frame(width: 77, height: 77)
                        .padding(.top,113)
                    Text("You’re about to start a\nmeasurement.")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding(.top,45)
                }
                
                VStack(alignment: .leading,spacing: 0){
                    Text("Make sure that:")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.bottom,18)
                    
                    BulletTextView(text: "Start contracting your pelvic floor muscle and press the button at the same time.")
                    BulletTextView(text: "Hold as long as you can.")
                    BulletTextView(text: "Let go of the button when you can’t hold any more.")
                   
                }
                .padding(.horizontal,38)
                .padding(.top,71)
                
                Spacer()
                Button(action: {
                    triggerHaptic()
                    onBack()
                }) {
                    Text("Start Measurement")
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
        .navigationBarHidden(true)
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    MeasurementSheetView( onBack:{}).environmentObject(ProgressViewModel())
}

