//
//  HapticManager.swift
//  HOLD
//
//  Created by Hafiz Muhammad Ali on 04/05/2025.
//

import Foundation
import CoreHaptics
import QuartzCore
import UIKit

class HapticManager {
    private var timer: Timer?
    private var duration: Double = 0
    private var startTime: TimeInterval = 0
    private var pausedTime: TimeInterval = 0
    private var currentTime: TimeInterval = 0
    private var isPlaying: Bool = false
    private var tickInterval: TimeInterval = 0.05

    func playRampUpHaptic(duration: Double) {
        stopHaptic()
        
        self.duration = duration
        self.startTime = CACurrentMediaTime()
        self.currentTime = 0
        self.pausedTime = 0
        self.isPlaying = true

        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentTime += self.tickInterval
            
            if self.currentTime >= self.duration {
                self.stopHaptic()
                return
            }
            
            if let style = self.feedbackStyle(for: self.currentTime) {
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.prepare()
                generator.impactOccurred()
            }
        }
    }

    func pauseHaptic() {
        guard isPlaying else { return }
        pausedTime = currentTime
        timer?.invalidate()
        timer = nil
        isPlaying = false
    }

    func resumeHaptic() {
        guard !isPlaying, pausedTime > 0, pausedTime < duration else { return }

        currentTime = pausedTime
        isPlaying = true

        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentTime += self.tickInterval

            if self.currentTime >= self.duration {
                self.stopHaptic()
                return
            }

            if let style = self.feedbackStyle(for: self.currentTime) {
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.prepare()
                generator.impactOccurred()
            }
        }
    }

    func stopHaptic() {
        timer?.invalidate()
        timer = nil
        isPlaying = false
        pausedTime = 0
        currentTime = 0
    }

    private func feedbackStyle(for time: TimeInterval) -> UIImpactFeedbackGenerator.FeedbackStyle? {
        let progress = time / duration

        if progress < 0.5 {
            return .medium
        } else {
            return nil
        }
    }
}
