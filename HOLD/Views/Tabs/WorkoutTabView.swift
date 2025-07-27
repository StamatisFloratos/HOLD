//
//  WorkoutTabView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI

struct WorkoutTabView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @EnvironmentObject var trainingPlansViewModel: TrainingPlansViewModel
    @EnvironmentObject var tabManager: TabManager
    @State private var showWorkoutView = false
    @State private var showBadgesView = false
    @State private var showPlanDetail = false
    
    @State private var showChallengeSheet = false
    @State private var showMeasurementSheet = false
    @State private var measurementDayIndex: Int? = nil
    @State private var challengeDayIndex: Int? = nil
    
    @State private var showSwitchProgramSheet = false
    @State private var pendingModalToDismiss: String? = nil
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack{
                HStack {
                    Spacer()
                    Image("holdIcon")
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.bottom, 14)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Today's Workout")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.top,39)
                            .padding(.leading,10)
                        
                        if let selectedDay = trainingPlansViewModel.getTodaysDay(), let workout = trainingPlansViewModel.workouts[selectedDay.workoutId] {
                            workoutCard(workout: workout)
                                .padding(.top,17)
                        } else {
                            Text("No workouts available")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(hex: "#161616").opacity(0.4))
                                .cornerRadius(20)
                        }
                        
                        if let todaysDay = getTodaysScheduledDay() {
                            let hasChallenge = todaysDay.showPracticeChallenge
                            let hasMeasurement = todaysDay.showPracticeMeasurement
                            
                            if hasChallenge || hasMeasurement {
                                Text("Measure your progress")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.top, 40)
                                    .padding(.leading, 10)
                                
                                VStack(spacing: 20) {
                                    if hasChallenge {
                                        if trainingPlansViewModel.isChallengeCompleted(planId: trainingPlansViewModel.currentPlanId ?? "", dayIndex: todaysDay.dayIndex) {
                                            PracticeChallengeCompletedCell(
                                                day: todaysDay,
                                                workout: Workout(id: "the_challenge", name: "The Challenge", difficulty: .medium, durationMinutes: 10, description: "Practice challenge.", exercises: [], restSeconds: 30),
                                                onMeasure: {}
                                            )
                                        } else {
                                            PracticeChallengeCell(
                                                day: todaysDay,
                                                workout: Workout(id: "the_challenge", name: "The Challenge", difficulty: .medium, durationMinutes: 10, description: "Practice challenge.", exercises: [], restSeconds: 30),
                                                onMeasure: {
                                                    challengeDayIndex = todaysDay.dayIndex
                                                    showChallengeSheet = true
                                                }
                                            )
                                        }
                                    }
                                    
                                    if hasMeasurement {
                                        if trainingPlansViewModel.isMeasurementCompleted(planId: trainingPlansViewModel.currentPlanId ?? "", dayIndex: todaysDay.dayIndex) {
                                            PracticeMeasurementCompletedCell(
                                                day: todaysDay,
                                                workout: Workout(id: "hold_measurement", name: "HOLD Measurement", difficulty: .easy, durationMinutes: 5, description: "Progress tracking measurement.", exercises: [], restSeconds: 30),
                                                onMeasure: {}
                                            )
                                        } else {
                                            PracticeMeasurementCell(
                                                day: todaysDay,
                                                workout: Workout(id: "hold_measurement", name: "HOLD Measurement", difficulty: .easy, durationMinutes: 5, description: "Progress tracking measurement.", exercises: [], restSeconds: 30),
                                                onMeasure: {
                                                    measurementDayIndex = todaysDay.dayIndex
                                                    showMeasurementSheet = true
                                                }
                                            )
                                        }
                                    }
                                }
                                .padding(.top, 16)
                            }
                        }
                        
                        if let currentPlanId = trainingPlansViewModel.currentPlanId,
                           let currentPlan = trainingPlansViewModel.plans.first(where: { $0.id == currentPlanId }) {
                            
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        tabManager.isTabBarHidden = true
                                        showPlanDetail = true
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Text("Training Plan")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.white)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .regular))
                                    }
                                    .padding(.leading, 10)
                                    .padding(.vertical, 8)
                                }
                                Spacer()
                            }
                            .padding(.top, 40)
                            .padding(.bottom, 15)
                            
                            TrainingPlanCard(
                                planName: currentPlan.name,
                                daysLeft: max(0, trainingPlansViewModel.daysLeft(planStartDate: trainingPlansViewModel.planStartDate ?? Date(), currentDate: Date(), planDurationDays: currentPlan.duration)),
                                percentComplete: currentPlan.days.count > 0 ? Int((Double(trainingPlansViewModel.planProgress[currentPlan.id]?.count ?? 0) / Double(currentPlan.days.count)) * 100) : 0,
                                progress: currentPlan.days.count > 0 ? Double(trainingPlansViewModel.planProgress[currentPlan.id]?.count ?? 0) / Double(currentPlan.days.count) : 0.0,
                                image: currentPlan.image,
                                height: 180,
                                onTap: {
                                    withAnimation {
                                        tabManager.isTabBarHidden = true
                                        showPlanDetail = true
                                    }
                                }
                            )
                            .padding(.bottom, 24)
                        }
                        
                        streakView
                            .padding(.top,17)
                        Spacer(minLength: 14)
                    }
                }
                
            }
            .padding(.horizontal,28)
            .navigationBarHidden(true)
            .onAppear {
                // Refresh workout completion status when view appears
                workoutViewModel.refreshWorkoutCompletionStatus()
            }
            .onReceive(trainingPlansViewModel.$planProgress) { _ in
                // Refresh when plan progress changes
                workoutViewModel.refreshWorkoutCompletionStatus()
            }
            .onReceive(trainingPlansViewModel.$currentPlanId) { _ in
                // Refresh when current plan changes
                workoutViewModel.refreshWorkoutCompletionStatus()
            }
            .fullScreenCover(isPresented: $showWorkoutView) {
                Group {
                    if let selectedDay = trainingPlansViewModel.getTodaysDay(), let workout = trainingPlansViewModel.workouts[selectedDay.workoutId] {
                        WorkoutView(selectedWorkout: workout, onBack: {
                            trainingPlansViewModel.markDayCompleted(dayIndex: selectedDay.dayIndex)
                            showWorkoutView = false
                            showBadgesView = true
                        })
                    } else {
                        EmptyView()
                            .onAppear {
                                showWorkoutView = false
                            }
                    }
                }
            }
            .fullScreenCover(isPresented: $showChallengeSheet) {
                ChallengeView(onBack: { duration in
                    // Only mark as completed if challenge was done on the scheduled day
                    if let dayIndex = challengeDayIndex,
                       let planId = trainingPlansViewModel.currentPlanId,
                       trainingPlansViewModel.isChallengeScheduledForToday(dayIndex: dayIndex) {
                        trainingPlansViewModel.markChallengeCompleted(planId: planId, dayIndex: dayIndex, duration: duration)
                    }
                    showChallengeSheet = false
                    challengeDayIndex = nil
                })
            }
            .fullScreenCover(isPresented: $showMeasurementSheet) {
                MeasurementView(onBack: { duration in
                    // Only mark as completed if measurement was done on the scheduled day
                    if let dayIndex = measurementDayIndex,
                       let planId = trainingPlansViewModel.currentPlanId,
                       trainingPlansViewModel.isMeasurementScheduledForToday(dayIndex: dayIndex) {
                        trainingPlansViewModel.markMeasurementCompleted(planId: planId, dayIndex: dayIndex, duration: duration)
                    }
                    showMeasurementSheet = false
                    measurementDayIndex = nil
                })
            }
            .sheet(isPresented: $showBadgesView) {
                let badge = workoutViewModel.newBadges.last
                StreakBadgeView(
                    unlockedBadge: badge,
                    nextBadge: workoutViewModel.getNextBatchToUnlock(),
                    showUnlockedBadge: badge != nil ? true : false,
                    onBack: {
                        showBadgesView = false
                        workoutViewModel.newBadges = []
                        trainingPlansViewModel.checkForTrainingPlansUpdate()
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
            }
            
            if showPlanDetail, let currentPlan = trainingPlansViewModel.plans.first(where: { $0.id == trainingPlansViewModel.currentPlanId }) {
                TrainingPlanDetailView(
                    viewModel: trainingPlansViewModel,
                    plan: currentPlan,
                    onClose: {
                        withAnimation {
                            showPlanDetail = false
                        }
                        tabManager.isTabBarHidden = false
                        workoutViewModel.refreshWorkoutCompletionStatus()
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .trailing)
                ))
                .zIndex(1)
            }
        }
    }
    
    func workoutCard(workout: Workout) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Text(workout.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.top,19)
                
                if workoutViewModel.isWorkoutCompletedToday(workout) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 88, height: 88)
                        .foregroundStyle(LinearGradient(
                            colors: [
                                Color(hex:"#FF1919"),
                                Color(hex:"#990F0F")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .padding(.vertical,14)
                } else {
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 88,height: 88)
                        .padding(.vertical,21)
                }
                
                
                Text(workoutViewModel.isWorkoutCompletedToday(workout) ?
                     "Status: Completed Today" : "Status: Not Completed")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.bottom,36)
                .padding(.top,14)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("**Difficulty:**")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                    Text("\(workout.difficulty.description)")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(LinearGradient(
                            colors: workout.difficulty.color,
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                }
                
                Text("**Duration:** \(workout.durationMinutes) minutes")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                
                Text("**Description:** \(workout.description)")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                
            }
            .padding(.horizontal,10)
            
            
            Button(action: {
                triggerHaptic()
                showWorkoutView = true
            }) {
                Text("Start Workout")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 214, height: 47)
                    .frame(maxWidth: .infinity, maxHeight: 47)
                    .background(Color(hex: "#FF1919"))
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }
            .padding(.horizontal, 60)
            .padding(.bottom, 18)
            .padding(.top, 40)
            
        }
        .background(Color(hex: "#242E3A"))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white, lineWidth: 0.5)
                .cornerRadius(20)
        )
    }
    
    var streakView: some View {
        VStack(alignment:.leading, spacing: 23) {
            VStack(alignment:.leading, spacing: 0) {
                Text("Keep Going!")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("You're on a \(workoutViewModel.currentStreak) day streak!")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                
            }
            .padding(.leading)
            
            
            // Week Streak View
            HStack() {
                Spacer()
                ForEach(0..<7) { index in
                    let date = getWeekday(for: index)
                    let isToday = isDateToday(date)
                    let hasWorkout = hasWorkoutOnDate(date)
                    DayCircleView(day: getDayShortName(for: index), isCompleted: hasWorkout)
                    Spacer()
                    
                }
            }
        }
        .padding(.vertical)
        .background(Color(hex: "#242E3A"))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white, lineWidth: 0.5)
                .cornerRadius(20)
        )
    }
    
    // Helper functions for the weekly streak view
    private func getWeekday(for index: Int) -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        
        // Calculate the date for Monday (assuming Monday is the first day of the week)
        let daysToMonday = (weekday + 5) % 7 // Convert to 0-indexed where Monday is 0
        let mondayDate = calendar.date(byAdding: .day, value: -daysToMonday, to: today)!
        
        // Get the date for the requested day of the week
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
        // Check if the date is in the viewModel's streakDates array
        return workoutViewModel.streakDates.contains { streakDate in
            Calendar.current.isDate(streakDate, inSameDayAs: date)
        }
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    // MARK: - Today's Scheduled Activities
    
    func getTodaysScheduledDay() -> TrainingDay? {
        guard let currentPlanId = trainingPlansViewModel.currentPlanId,
              let currentPlan = trainingPlansViewModel.plans.first(where: { $0.id == currentPlanId }),
              let startDate = trainingPlansViewModel.planStartDate else {
            return nil
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find today's day in the plan
        return currentPlan.days.first(where: { day in
            let dayDate = calendar.date(byAdding: .day, value: day.dayIndex - 1, to: startDate)!
            return calendar.isDate(dayDate, inSameDayAs: today)
        })
    }
}

struct DayCircleView: View {
    let day: String
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(LinearGradient(
                        colors: [
                            Color(hex:"#FF1919"),
                            Color(hex:"#990F0F")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
            } else {
                Circle()
                    .foregroundStyle(Color(hex: "#606060"))
                    .frame(width: 30, height: 30)
            }
            Text(day)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    WorkoutTabView()
        .environmentObject(TabManager())
        .environmentObject(WorkoutViewModel())
        .environmentObject(TrainingPlansViewModel.preview)
}
