//
//  ProfileTabView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI

struct ProfileTabView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var tabManager: TabManager
    
    var body: some View {
        NavigationStack {
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
