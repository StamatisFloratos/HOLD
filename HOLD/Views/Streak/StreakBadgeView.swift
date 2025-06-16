//
//  StreakBadgeView.swift
//  HOLD
//
//  Created by Muhammad Ali on 16/06/2025.
//

import SwiftUI

struct StreakBadgeView: View {
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    
    @State var unlockedBadge: StreakBadge? = nil
    @State var nextBadge: StreakBadge? = nil
    
    @State var showUnlockedBadge: Bool = false
    
    var onBack: () -> Void
    
    @State private var showUnlockAnimation = false
    @State private var lockOffset: CGFloat = 0
    @State private var badgeOpacity: Double = 0.3
    @State private var badgeScale: CGFloat = 1.0
    @State private var showUnlockIcon = false
    @State private var iconOpacity: Double = 1.0
    
    @State private var unlockedBadgeOffset: CGFloat = 0
    @State private var lockedBadgeOffset: CGFloat = UIScreen.main.bounds.width
    @State private var congratulationsOpacity: Double = 1.0
    @State private var nextBadgeTextOpacity: Double = 0.0
    @State private var isTransitioning = false
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(spacing: 25) {
                HStack {
                    Spacer()
                    Button {
                        onBack()
                    } label: {
                        Image("crossIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 21)
                    }
                    .padding(.trailing, 26)
                }
                .padding(.top, 20)
                
                Spacer()
                
                ZStack {
                    Text("Congratulations")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(showUnlockedBadge ? congratulationsOpacity : 0)
                    
                    Text("Next Badge")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(showUnlockedBadge ? nextBadgeTextOpacity : 1)
                }
                
                VStack(spacing: 32) {
                    ZStack {
                        if let badge = unlockedBadge, showUnlockedBadge {
                            UnlockingBadgeView(
                                badge: badge,
                                showUnlockAnimation: $showUnlockAnimation,
                                lockOffset: $lockOffset,
                                badgeOpacity: $badgeOpacity,
                                badgeScale: $badgeScale,
                                showUnlockIcon: $showUnlockIcon,
                                iconOpacity: $iconOpacity
                            )
                            .offset(x: unlockedBadgeOffset)
                            .opacity(isTransitioning ? 0 : 1)
                            .onAppear {
                                startUnlockAnimation()
                            }
                        }
                        
                        if let badge = nextBadge {
                            LockedBadgeView(badge: badge)
                                .offset(x: showUnlockedBadge ? lockedBadgeOffset : 0)
                                .opacity(showUnlockedBadge && !isTransitioning ? 0 : 1)
                        }
                    }
                }
                
                Text("\(workoutViewModel.currentStreak) Day streak")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Keep going to unlock even more badges.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                HStack() {
                    Spacer()
                    ForEach(0..<7) { index in
                        let date = getWeekday(for: index)
                        let hasWorkout = hasWorkoutOnDate(date)
                        DayCircleView(day: getDayShortName(for: index), isCompleted: hasWorkout)
                        Spacer()
                        
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    triggerHaptic()
                    withAnimation {
                        if nextBadge != nil, showUnlockedBadge, !isTransitioning {
                            startTransitionToNextBadge()
                        } else {
                            onBack()
                        }
                    }
                }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity, maxHeight: 47)
                        .background(Color(hex: "#FF1919"))
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        .padding(.horizontal, 56)
                }
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            if showUnlockedBadge {
                unlockedBadgeOffset = 0
                lockedBadgeOffset = UIScreen.main.bounds.width
                congratulationsOpacity = 1.0
                nextBadgeTextOpacity = 0.0
            } else {
                unlockedBadgeOffset = -UIScreen.main.bounds.width
                lockedBadgeOffset = 0
                congratulationsOpacity = 0.0
                nextBadgeTextOpacity = 1.0
            }
        }
    }
    
    private func startUnlockAnimation() {
        badgeOpacity = 0.3
        lockOffset = 0
        badgeScale = 1.0
        showUnlockIcon = false
        iconOpacity = 1.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showUnlockIcon = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    lockOffset = 80
                    iconOpacity = 0
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.easeOut(duration: 0.8)) {
                    badgeOpacity = 1.0
                    badgeScale = 1.1
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    badgeScale = 1.0
                }
            }
        }
    }
    
    private func startTransitionToNextBadge() {
        isTransitioning = true
        
        withAnimation(.easeInOut(duration: 0.5)) {
            unlockedBadgeOffset = -UIScreen.main.bounds.width
            
            lockedBadgeOffset = 0
            
            congratulationsOpacity = 0.0
            nextBadgeTextOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showUnlockedBadge = false
            isTransitioning = false
        }
    }
    
    private func getWeekday(for index: Int) -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        
        let daysToMonday = (weekday + 5) % 7
        let mondayDate = calendar.date(byAdding: .day, value: -daysToMonday, to: today)!
        
        return calendar.date(byAdding: .day, value: index, to: mondayDate)!
    }

    private func getDayShortName(for index: Int) -> String {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return days[index]
    }

    private func getDateNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private func isDateToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    private func hasWorkoutOnDate(_ date: Date) -> Bool {
        return workoutViewModel.streakDates.contains { streakDate in
            Calendar.current.isDate(streakDate, inSameDayAs: date)
        }
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct StreakBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        StreakBadgeView(
            unlockedBadge: StreakBadge(
                name: "Week Warrior",
                description: "Complete 7 days in a row",
                requiredDays: 7,
                imageName: "badge_1_week",
                isEarned: true,
                earnedDate: Date()
            ),
            nextBadge: StreakBadge(
                name: "Two Week Champion",
                description: "Complete 14 days in a row",
                requiredDays: 14,
                imageName: "badge_2_weeks"
            ),
            showUnlockedBadge: true,
            onBack: {}
        )
        .environmentObject(WorkoutViewModel())
    }
}
