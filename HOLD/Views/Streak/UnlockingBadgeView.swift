//
//  UnlockingBadgeView.swift
//  HOLD
//
//  Created by Muhammad Ali on 16/06/2025.
//

import SwiftUI

struct UnlockingBadgeView: View {
    let badge: StreakBadge
    @Binding var showUnlockAnimation: Bool
    @Binding var lockOffset: CGFloat
    @Binding var badgeOpacity: Double
    @Binding var badgeScale: CGFloat
    @Binding var showUnlockIcon: Bool
    @Binding var iconOpacity: Double
    
    var body: some View {
        ZStack {
            Image(badge.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .opacity(badgeOpacity)
                .scaleEffect(badgeScale)
            
            ZStack {
                Image("lockIcon")
                    .frame(width: 48, height: 48)
                    .opacity(showUnlockIcon ? 0 : iconOpacity)
                
                Image("unlockIcon")
                    .frame(width: 48, height: 48)
                    .opacity(showUnlockIcon ? iconOpacity : 0)
            }
            .offset(y: lockOffset)
        }
        .frame(width: 250, height: 250)
    }
}
