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

    var body: some View {
        ZStack {
            // Background gradient with specified hex colors
            AppBackground()
            
            VStack {
                VStack {
                    // Logo at the top
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 14)
                    
                    Image("measurementIcon")
                        .padding(.vertical,45)
                    Text("You’re about to start a\nmeasurement.")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                    
                }
                
                
                
                VStack(alignment: .leading){
                    Text("Make sure that:")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.bottom,18)
                    
                    BulletTextView(text: "Start contract your pelvic floor muscle and press the button at the same time.")
                    BulletTextView(text: "Hold as long as you can.")
                    BulletTextView(text: "Let go of the button when you can’t hold any more.")
                   
                }
                .padding(.horizontal,38)
                .padding(.top,71)
                
                Spacer()
                Button(action: {
                    navigationManager.push(to: .measurementActivityView)
                }) {
                    Text("Start Measurement")
                        .font(.system(size: 16, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity,maxHeight: 47)
                        .background(Color(hex: "#FF1919"))
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                .padding(.horizontal, 56)
                .padding(.bottom, 15)
            }
        }
        .navigationBarHidden(true)
        
    }
}

#Preview {
    MeasurementSheetView().environmentObject(ProgressViewModel())
}

