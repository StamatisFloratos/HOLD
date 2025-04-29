//
//  ProgressBarView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation
import SwiftUI

struct ProgressBarView: View {
    
    let value: CGFloat
    let total: CGFloat
    
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack(alignment: .leading, content: {
                Rectangle()
                    .foregroundColor(Color(hex: "#AFAFAF"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(Capsule())
                
                Rectangle()
//                    .foregroundColor(.blue)
                    .frame(maxHeight: .infinity)
                    .frame(width: calculateBarWidth(contentWidth: geometry.size.width))
                    .clipShape(Capsule())
            })
            .clipped()
        })
    }
    
    private func calculateBarWidth(contentWidth: CGFloat) -> CGFloat {
        return (value / total) * contentWidth
    }
}
