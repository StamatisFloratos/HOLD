//
//  MeasurementSheetView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI

struct MeasurementSheetView: View {
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
                    
                    Image("measurementIcon")
                        .padding(.vertical,45)
                    Text("You’re about to start a\nmeasurement.")
                    //
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                    
                    
                    
                    
                    
                }.padding(.top, 20)
                    .padding(.horizontal)
                
                Spacer()
                
                VStack(alignment: .leading){
                    Text("Make sure that:")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.bottom,18)
                    
                    HStack(alignment:.top) {
                        Text("•")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Start contract your pelvic floor muscle and press the button at the same time.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                    }
                    
                    HStack(alignment:.top) {
                        Text("•")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Hold as long as you can.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                    }
                    
                    HStack(alignment:.top) {
                        Text("•")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Let go of the button when you can’t hold any more.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                Button(action: {
                    // Handle measurement action
                    navigationManager.push(to: .measurementActivityView)
                }) {
                    Text("Start Measurement")
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
        .navigationBarHidden(true)
    }
}

#Preview {
    MeasurementSheetView()
}

