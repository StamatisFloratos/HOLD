//
//  MeasurementSheetView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI

struct MeasurementSheetView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var showingActivityView = false
    @EnvironmentObject var viewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode // For dismissing this sheet



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
                    
                    BulletTextView(text: "Start contract your pelvic floor muscle and press the button at the same time.")
                    BulletTextView(text: "Hold as long as you can.")
                    BulletTextView(text: "Let go of the button when you can’t hold any more.")
                   
                }
                .padding(.horizontal)
                
                Spacer()
                Button(action: {
                    // Handle measurement action
//                    navigationManager.push(to: .measurementActivityView)
                    showingActivityView = true
                }) {
                    Text("Start Measurement")
                        .font(.system(size: 16, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity,maxHeight: 47)
                        .background(Color(hex: "#FF1919"))                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 15)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showingActivityView,
                         onDismiss: {
                                         // This code runs *after* MeasurementActivityView is dismissed
                                         print("MeasurementActivityView dismissed, now dismissing MeasurementSheetView.")
                                         // Dismiss MeasurementSheetView itself
                                         self.presentationMode.wrappedValue.dismiss()
                                     }) {
                     MeasurementActivityView()
                         .environmentObject(viewModel) // <<< PASS ViewModel ALONG to the next view's environment
                }
    }
}

#Preview {
    MeasurementSheetView()
}

