//
//  TypewriterText.swift
//  HOLD
//
//  Created by Hafiz Muhammad Ali on 09/05/2025.
//

import SwiftUI

struct TypewriterText: View {
    let texts: [String]
    @State private var currentTextIndex = 0
    @State private var displayedText = ""
    @State private var isAnimating = true
    @State private var opacity = 1.0
    @State private var isCompleted = false
    
    var onCompletion: (() -> Void)?

    let typingSpeed: Double = 0.05
    let pauseBetweenTexts: Double = 1.0
    
    var body: some View {
        Text(displayedText)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .opacity(opacity)
            .onAppear {
                startTypingAnimation()
            }
    }
    
    private func startTypingAnimation() {
        guard currentTextIndex < texts.count else { return }
        
        let text = texts[currentTextIndex]
        displayedText = ""
        opacity = 1.0
        isAnimating = true
        
        for (index, _) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + typingSpeed * Double(index)) {
                if isAnimating {
                    let nextIndex = text.index(text.startIndex, offsetBy: index)
                    displayedText = String(text[...nextIndex])
                    
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                
                if index == text.count - 1 {
                    prepareForNextText()
                }
            }
        }
    }
    
    private func prepareForNextText() {
        let isLastText = currentTextIndex == texts.count - 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + pauseBetweenTexts) {
            if !isLastText {
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 0.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    currentTextIndex += 1
                    startTypingAnimation()
                }
            } else {
                isCompleted = true
                onCompletion?()
            }
        }
    }
}
