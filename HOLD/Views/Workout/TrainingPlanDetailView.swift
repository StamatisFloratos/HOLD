import SwiftUI

enum TrainingPlanDayCellType: Equatable {
    case today(completed: Bool)
    case missed
    case completed
    case future
    case practiceMeasurement
    case practiceChallenge
}

struct WorkoutLaunchContext: Identifiable {
    let id = UUID()
    let workout: Workout
    let dayIndex: Int
}

struct TrainingPlanDetailView: View {
    @ObservedObject var viewModel: TrainingPlansViewModel
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    let plan: TrainingPlan
    var onClose: (() -> Void)? = nil
    @State private var scrollToToday: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @State private var showSwitchSheet = false
    @State private var showLearnMoreSheet = false

    // New state for workout launching
    @State private var showWorkoutSheet = false
    @State private var workoutToStart: Workout? = nil
    @State private var workoutDayIndexToComplete: Int? = nil
    
    // New state for measurement launching
    @State private var showMeasurementSheet = false
    @State private var measurementDayIndex: Int? = nil
    
    // New state for challenge launching
    @State private var showChallengeSheet = false
    @State private var challengeDayIndex: Int? = nil

    // Use a single context for launching workouts
    @State private var workoutLaunchContext: WorkoutLaunchContext? = nil

    // New state for plan completion/failure modals
    @State private var blurAmount: CGFloat = 0

    // New state for plan completion/failure modals
    @State private var shouldShowFailureModalAfterSwitch = false

    // Weekly update modal state
    @State private var showWeeklyUpdate = false
    @State private var lastWeeklyUpdateWeek: Int? = nil

    var todayIndex: Int? {
        let completed = viewModel.planProgress[plan.id] ?? []
        return plan.days.firstIndex(where: { !completed.contains($0.dayIndex) }) ?? (plan.days.count - 1)
    }

    var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Image("holdIcon")
                    Spacer()
                }
                .padding(.top, 24)
                .padding(.bottom, 14)
                
                HStack {
                    Button(action: {
                        if let onClose = onClose {
                            onClose()
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                            Text("Training Plan")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.vertical, 25)
                    .padding(.leading, 5)
                    Spacer()
                }
                
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            ZStack(alignment: .center) {
                                if let cardImage = plan.image {
                                    Image(cardImage)
                                        .resizable()
                                        .frame(height: 245)
                                        .cornerRadius(20)
                                        .clipped()
                                }
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(plan.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.top, 16)
                                        .padding(.horizontal, 16)
                                    Spacer()
                                    ZStack(alignment: .bottom) {
                                        VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark, alpha: 0.9)
                                            .frame(height: 85)
                                        VStack(spacing: 10) {
                                            HStack {
                                                Text("Progress")
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.white)
                                                Spacer()
                                                Text("\(daysLeft) days left")
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.white)
                                            }
                                            HStack(spacing: 8) {
                                                GeometryReader { geo in
                                                    ZStack(alignment: .leading) {
                                                        Capsule()
                                                            .frame(height: 14)
                                                            .foregroundColor(Color.white.opacity(0.25))
                                                        Capsule()
                                                            .frame(width: geo.size.width * progress, height: 14)
                                                            .foregroundStyle(
                                                                LinearGradient(
                                                                    gradient: Gradient(colors: [Color(hex: "#990F0F"), Color(hex: "#FF1919")]),
                                                                    startPoint: .leading,
                                                                    endPoint: .trailing
                                                                )
                                                            )
                                                            .animation(.easeInOut(duration: 0.6), value: progress)
                                                    }
                                                }
                                                .frame(height: 14)
                                                Text("\(Int(progress * 100))%")
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.white)
                                                    .frame(height: 22, alignment: .center)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.top, 15)
                                        .padding(.bottom, 15)
                                    }
                                    .frame(height: 85)
                                }
                            }
                            .frame(height: 245)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 0.5)
                            )
                            .padding(.bottom, 18)
                            
                            HStack(spacing: 12) {
                                Button(action: { showSwitchSheet = true }) {
                                    HStack(spacing: 8) {
                                        Text("Switch Program")
                                        Image("switchIcon")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(.vertical, 12)
                                    .background(Color(hex: "#424242"))
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                                    .contentShape(Rectangle())
                                }
                                Button(action: { showLearnMoreSheet = true }) {
                                    HStack(spacing: 8) {
                                        Text("Learn More")
                                        Image(systemName: "info.circle")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(30)
                                    .contentShape(Rectangle())
                                }
                            }
                            .padding(.bottom, 18)
                            
                            VStack(spacing: 0) {
                                ForEach(plan.days, id: \.dayIndex) { day in
                                    TrainingPlanDayCell(
                                        day: day,
                                        workout: viewModel.workouts[day.workoutId] ?? Workout(id: day.workoutId, name: "Unknown Workout", difficulty: .easy, durationMinutes: 0, description: "", exercises: [], restSeconds: 30),
                                        status: dayStatus(for: day),
                                        isCompleted: isDayCompleted(day.dayIndex),
                                        planId: plan.id,
                                        viewModel: viewModel,
                                        onStart: {
                                            if let workout = viewModel.workouts[day.workoutId] {
                                                self.workoutLaunchContext = WorkoutLaunchContext(workout: workout, dayIndex: day.dayIndex)
                                            }
                                        },
                                        onMeasure: { dayIndex in
                                            self.measurementDayIndex = dayIndex
                                            self.showMeasurementSheet = true
                                        },
                                        onChallenge: { dayIndex in
                                            self.challengeDayIndex = dayIndex
                                            self.showChallengeSheet = true
                                        }
                                    )
                                    .id(day.dayIndex)
                                    .padding(.bottom, 20)
                                }
                            }
                            .padding(.bottom, 24)
                        }
                        .padding(.horizontal, 0)
                    }
                    .onAppear {
                        if scrollToToday, let today = todayDayId {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    proxy.scrollTo(today, anchor: .center)
                                }
                            }
                            scrollToToday = false
                        }
                        
                        if isPlanFailed() {
                            viewModel.triggerPlanFailureModal(failedPlan: plan, percentComplete: getPlanPercentComplete())
                        }
                        checkAndShowWeeklyUpdate()
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 28)
            .blur(radius: blurAmount)
            .animation(.easeInOut(duration: 0.5), value: blurAmount)
            .animation(.easeInOut(duration: 0.5), value: showWeeklyUpdate)

            if viewModel.showPlanCompletionModal, let completedPlan = viewModel.completedPlanForModal {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
                PlanCompletionModalView(
                    completedPlan: completedPlan,
                    nextPlan: viewModel.nextPlanForModal,
                    onDone: {
                        withAnimation { blurAmount = 0 }
                        viewModel.showPlanCompletionModal = false
                        viewModel.completedPlanForModal = nil
                        viewModel.nextPlanForModal = nil
                    },
                    onSwitchProgram: {
                        withAnimation { blurAmount = 0 }
                        viewModel.showPlanCompletionModal = false
                        viewModel.completedPlanForModal = nil
                        viewModel.nextPlanForModal = nil
                        showSwitchSheet = true
                    }
                )
                .transition(.opacity)
                .zIndex(100)
                .onAppear { withAnimation { blurAmount = 30 } }
            }

            if viewModel.showPlanFailureModal, let failedPlan = viewModel.failedPlanForModal {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
                PlanFailureModalView(
                    failedPlan: failedPlan,
                    percentComplete: viewModel.failedPlanPercentComplete,
                    onRetry: {
                        withAnimation { blurAmount = 0 }
                        // Re-enroll current program from start
                        viewModel.reenrollPlanFromStart(plan: failedPlan)
                        viewModel.clearPlanFailureModal()
                    },
                    onSwitchProgram: {
                        withAnimation { blurAmount = 0 }
                        viewModel.clearPlanFailureModal()
                        shouldShowFailureModalAfterSwitch = true
                        showSwitchSheet = true
                    }
                )
                .transition(.opacity)
                .zIndex(100)
                .onAppear { withAnimation { blurAmount = 30 } }
            }

            if showWeeklyUpdate, let statsTuple = viewModel.weeklyStats(for: viewModel.workouts.values.map { $0 }) {
                let stats = WeeklyUpdateStats(
                    workoutsCompletedThisWeek: statsTuple.workoutsCompleted,
                    currentStreak: workoutViewModel.currentStreak,
                    workoutMinutesThisWeek: statsTuple.workoutMinutes
                )
                let challengeProgress = viewModel.challengeProgressBarPercentagesForCurrentWeek()
                let muscleProgress = viewModel.muscleProgressBarPercentagesForCurrentWeek()

                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .allowsHitTesting(true)
                WeeklyUpdateView(
                    stats: stats,
                    challengeProgress: challengeProgress,
                    muscleProgress: muscleProgress,
                    onBack: {
                        showWeeklyUpdate = false
                        withAnimation { blurAmount = 0 }
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(200)
                .onAppear { withAnimation { blurAmount = 30 } }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(item: $workoutLaunchContext, onDismiss: {}) { context in
            WorkoutView(selectedWorkout: context.workout, onBack: {
                viewModel.markDayCompleted(planId: plan.id, dayIndex: context.dayIndex)
                workoutLaunchContext = nil
            })
        }
        .fullScreenCover(isPresented: $showMeasurementSheet) {
            MeasurementView(onBack: { duration in
                // Only mark as completed if measurement was done on the scheduled day
                if let dayIndex = measurementDayIndex,
                   viewModel.isMeasurementScheduledForToday(dayIndex: dayIndex) {
                    viewModel.markMeasurementCompleted(planId: plan.id, dayIndex: dayIndex, duration: duration)
                }
                showMeasurementSheet = false
                measurementDayIndex = nil
            })
        }
        .fullScreenCover(isPresented: $showChallengeSheet) {
            ChallengeView(onBack: { duration in
                // Only mark as completed if challenge was done on the scheduled day
                if let dayIndex = challengeDayIndex,
                   viewModel.isChallengeScheduledForToday(dayIndex: dayIndex) {
                    viewModel.markChallengeCompleted(planId: plan.id, dayIndex: dayIndex, duration: duration)
                }
                showChallengeSheet = false
                challengeDayIndex = nil
            })
        }
        .sheet(isPresented: $showLearnMoreSheet) {
            TrainingPlanLearnMoreView(
                plan: plan,
                trainingPlansViewModel: viewModel,
                onClose: {
                    showLearnMoreSheet = false
                }
            )
        }
        .sheet(isPresented: $showSwitchSheet, onDismiss: {
            if shouldShowFailureModalAfterSwitch {
                shouldShowFailureModalAfterSwitch = false
                if viewModel.failedPlanForModal != nil {
                    withAnimation { blurAmount = 30 }
                    viewModel.showPlanFailureModal = true
                }
            }
        }) {
            SwitchProgramSheet(viewModel: viewModel, onSelect: { plan in
                viewModel.switchToPlan(plan.id)
                showSwitchSheet = false
                shouldShowFailureModalAfterSwitch = false
            })
        }
    }

    // Helpers
    var progress: Double {
        let completed = viewModel.planProgress[plan.id]?.count ?? 0
        return plan.days.isEmpty ? 0 : Double(completed) / Double(plan.days.count)
    }
    var daysLeft: Int {
        let completed = viewModel.planProgress[plan.id]?.count ?? 0
        return max(0, plan.duration - completed)
    }
    var todayDayId: Int? {
        guard let startDate = viewModel.planStartDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let day = plan.days.first(where: { day in
            let dayDate = calendar.date(byAdding: .day, value: day.dayIndex - 1, to: startDate)!
            return calendar.isDate(dayDate, inSameDayAs: today)
        }) {
            return day.dayIndex
        }
        return nil
    }
    func isDayCompleted(_ id: Int) -> Bool {
        viewModel.planProgress[plan.id]?.contains(id) ?? false
    }
    
    func isDayLocked(_ id: Int) -> Bool {
        guard let today = todayDayId else { return true }
        return id > today
    }
    
    func dayLabel(for date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        if calendar.isDate(date, inSameDayAs: today) {
            return "Today"
        } else if calendar.isDate(date, inSameDayAs: tomorrow) {
            return "Tomorrow"
        } else if calendar.isDate(date, equalTo: today, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            let dayNum = calendar.component(.day, from: date)
            let suffix = dayNum.ordinalSuffix()
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            let restOfDate = formatter.string(from: date)
            return "\(dayNum)\(suffix) \(restOfDate)"
        }
    }

    func dayStatus(for day: TrainingDay) -> (TrainingPlanDayCellType, Date) {
        guard let startDate = viewModel.planStartDate else {
            return (.future, Date())
        }
        let calendar = Calendar.current
        let dayDate = calendar.date(byAdding: .day, value: day.dayIndex - 1, to: startDate)!
        let today = calendar.startOfDay(for: Date())
        let completed = isDayCompleted(day.dayIndex)
        if completed {
            return (.completed, dayDate)
        } else if dayDate < today {
            return (.missed, dayDate)
        } else if calendar.isDate(dayDate, inSameDayAs: today) {
            return (.today(completed: false), dayDate)
        } else {
            return (.future, dayDate)
        }
    }

    // Helper to check if plan has ended and is not completed
    private func isPlanFailed() -> Bool {
        guard let startDate = viewModel.planStartDate else { return false }
        let calendar = Calendar.current
        let lastDay = plan.days.map { $0.dayIndex }.max() ?? 0
        let lastDayDate = calendar.date(byAdding: .day, value: lastDay - 1, to: startDate)!
        let today = calendar.startOfDay(for: Date())
        let completedCount = viewModel.planProgress[plan.id]?.count ?? 0
        return today > lastDayDate && completedCount < plan.days.count
    }
    // Helper to get percent complete
    private func getPlanPercentComplete() -> Int {
        let completedCount = viewModel.planProgress[plan.id]?.count ?? 0
        return plan.days.count > 0 ? Int((Double(completedCount) / Double(plan.days.count)) * 100) : 0
    }

    // Helper: Get the current week number since plan start
    var currentPlanWeekNumber: Int? {
        guard let startDate = viewModel.planStartDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: today).day ?? 0
        return daysSinceStart / 7
    }

    // Helper: Is the last day of the week completed?
    func isLastDayOfWeekCompleted() -> Bool {
        guard let weekRange = viewModel.currentWeekRange else { return false }
        let calendar = Calendar.current
        let startDate = viewModel.planStartDate ?? Date()
        // Find the last day in the current week
        let weekDayIndices = plan.days.compactMap { day in
            let scheduledDate = calendar.date(byAdding: .day, value: day.dayIndex - 1, to: startDate)!
            return (scheduledDate >= weekRange.start && scheduledDate <= weekRange.end) ? day.dayIndex : nil
        }
        guard let lastDayIndex = weekDayIndices.max() else { return false }
        return viewModel.planProgress[plan.id]?.contains(lastDayIndex) ?? false
    }

    // Helper: Did the user miss the last day of the week?
    func didMissLastDayOfWeek() -> Bool {
        guard let weekRange = viewModel.currentWeekRange else { return false }
        let calendar = Calendar.current
        let startDate = viewModel.planStartDate ?? Date()
        let weekDayIndices = plan.days.compactMap { day in
            let scheduledDate = calendar.date(byAdding: .day, value: day.dayIndex - 1, to: startDate)!
            return (scheduledDate >= weekRange.start && scheduledDate <= weekRange.end) ? day.dayIndex : nil
        }
        guard let lastDayIndex = weekDayIndices.max() else { return false }
        // If today is after the last day of the week and not completed
        let lastDayDate = calendar.date(byAdding: .day, value: lastDayIndex - 1, to: startDate)!
        let today = calendar.startOfDay(for: Date())
        let missed = today > lastDayDate && !(viewModel.planProgress[plan.id]?.contains(lastDayIndex) ?? false)
        return missed
    }

    // Logic to check and show the weekly update modal
    func checkAndShowWeeklyUpdate() {
        guard let weekNum = currentPlanWeekNumber else { return }
        // Only show if not already shown for this week
        if lastWeeklyUpdateWeek == weekNum { return }
        if isLastDayOfWeekCompleted() || didMissLastDayOfWeek() {
            withAnimation { showWeeklyUpdate = true }
        }
    }
}

struct TrainingPlanDayCell: View {
    let day: TrainingDay
    let workout: Workout
    let status: (TrainingPlanDayCellType, Date)
    let isCompleted: Bool
    let planId: String
    let viewModel: TrainingPlansViewModel
    var onStart: (() -> Void)? = nil
    var onMeasure: ((Int) -> Void)? = nil
    var onChallenge: ((Int) -> Void)? = nil

    var body: some View {
        let (cellType, dayDate) = status
        let isTodayLabel = cellType == .today(completed: isCompleted)
        let hasWorkout = day.workoutId != ""
        let hasChallenge = day.showPracticeChallenge
        let hasMeasurement = day.showPracticeMeasurement
        VStack(alignment: .leading, spacing: 0) {
            Text(dayLabel(for: dayDate))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isTodayLabel ? .white : Color.white.opacity(0.7))
                .padding(.leading, 14)
                .padding(.bottom, 20)
            if hasWorkout {
                switch cellType {
                case .completed:
                    CompletedWorkoutCell(day: day, workout: workout)
                case .missed:
                    MissedWorkoutCell(day: day, workout: workout, onStart: { onStart?() })
                case .today(let done):
                    if done {
                        CompletedWorkoutCell(day: day, workout: workout)
                    } else {
                        TodayWorkoutCell(day: day, workout: workout, onStart: { onStart?() })
                    }
                case .future:
                    FutureWorkoutCell(day: day, workout: workout)
                default:
                    EmptyView()
                }
                if hasChallenge || hasMeasurement {
                    Spacer().frame(height: 20)
                }
            }
            if hasChallenge {
                if viewModel.isChallengeCompleted(planId: planId, dayIndex: day.dayIndex) {
                    PracticeChallengeCompletedCell(day: day, workout: workout, onMeasure: {})
                } else {
                    PracticeChallengeCell(day: day, workout: workout, onMeasure: {
                        onChallenge?(day.dayIndex)
                    })
                }
                if hasMeasurement {
                    Spacer().frame(height: 20)
                }
            }
            if hasMeasurement {
                if viewModel.isMeasurementCompleted(planId: planId, dayIndex: day.dayIndex) {
                    PracticeMeasurementCompletedCell(day: day, workout: workout, onMeasure: {})
                } else {
                    PracticeMeasurementCell(day: day, workout: workout, onMeasure: {
                        onMeasure?(day.dayIndex)
                    })
                }
            }
        }
    }

    private func dayLabel(for date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        if calendar.isDate(date, inSameDayAs: today) {
            return "Today"
        } else if calendar.isDate(date, inSameDayAs: tomorrow) {
            return "Tomorrow"
        } else if calendar.isDate(date, equalTo: today, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            let dayNum = calendar.component(.day, from: date)
            let suffix = dayNum.ordinalSuffix()
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            let restOfDate = formatter.string(from: date)
            return "\(dayNum)\(suffix) \(restOfDate)"
        }
    }
}

#if DEBUG
struct TrainingPlanDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let mockWorkout = Workout(
            id: "mock_workout",
            name: "Mock Workout",
            difficulty: .easy,
            durationMinutes: 5,
            description: "A simple mock workout.",
            exercises: [],
            restSeconds: 30
        )
        let mockDay = TrainingDay(dayIndex: 1, workoutId: "mock_workout", showPracticeMeasurement: false, showPracticeChallenge: false)
        let mockPlan = TrainingPlan(
            id: "mock_plan",
            name: "Mock Plan",
            duration: 1,
            difficulty: "Easy",
            summary: "A simple mock plan.",
            description: "This is a mock training plan for preview.",
            unlockRequirement: nil,
            days: [mockDay],
            image: nil
        )
        let vm = TrainingPlansViewModel()
        vm.plans = [mockPlan]
        vm.currentPlanId = "mock_plan"
        vm.workouts = ["mock_workout": mockWorkout]
        return TrainingPlanDetailView(viewModel: vm, plan: mockPlan)
            .background(Color.black)
            .environmentObject(vm)
            .environmentObject(WorkoutViewModel())
    }
}
#endif 
