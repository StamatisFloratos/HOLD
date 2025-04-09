//
//  ProfileTabView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI

struct ProfileTabView: View {
    var body: some View {
        NavigationStack {
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
                    // Logo at the top
                    Image("holdIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .padding(.top, 30)
                    
                    Spacer()
                    
                    // Content
                    Text("Profile Tab")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ProfileTabView()
}
