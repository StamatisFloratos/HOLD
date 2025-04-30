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
        ZStack {
            AppBackground()
            VStack(spacing:0) {
                HStack {
                    Spacer()
                    Image("holdIcon")
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.bottom, 14)
                
                ScrollView(showsIndicators: false) {
                    
                    Spacer(minLength: 80)
                }
            }
            
            
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ProfileTabView()
        .environmentObject(TabManager())
}
