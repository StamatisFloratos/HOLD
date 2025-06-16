//
//  LockedBadgeView.swift
//  HOLD
//
//  Created by Muhammad Ali on 16/06/2025.
//

import SwiftUI

struct LockedBadgeView: View {
    let badge: StreakBadge
    
    var body: some View {
        ZStack {
            Image(badge.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .opacity(0.3)
            
            Image("lockIcon")
                .frame(width: 48, height: 48)
        }
        .frame(width: 250, height: 250)
    }
}
