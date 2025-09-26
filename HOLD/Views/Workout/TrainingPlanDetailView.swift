import SwiftUI
import StoreKit

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

    @State private var showBadgesView = false
    
    // Use a single context for launching workouts
    @State private var workoutLaunchContext: WorkoutLaunchContext? = nil

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
                        triggerHaptic()
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
                                Button(action: {
                                    triggerHaptic()
                                    showSwitchSheet = true
                                }) {
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
                                Button(action: {
                                    triggerHaptic()
                                    showLearnMoreSheet = true
                                }) {
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
                                            triggerHaptic()
                                            if let workout = viewModel.workouts[day.workoutId] {
                                                self.workoutLaunchContext = WorkoutLaunchContext(workout: workout, dayIndex: day.dayIndex)
                                            }
                                        },
                                        onMeasure: { dayIndex in
                                            triggerHaptic()
                                            self.measurementDayIndex = dayIndex
                                            self.showMeasurementSheet = true
                                        },
                                        onChallenge: { dayIndex in
                                            triggerHaptic()
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
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 28)
        }
        .navigationBarHidden(true)
        .fullScreenCover(item: $workoutLaunchContext, onDismiss: {}) { context in
            WorkoutView(selectedWorkout: context.workout, onBack: {
                viewModel.markDayCompleted(dayIndex: context.dayIndex)
                workoutLaunchContext = nil
                showBadgesView = true
                requestReview()
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
        .sheet(isPresented: $showSwitchSheet, onDismiss: {}) {
            SwitchProgramSheet(viewModel: viewModel, onSelect: { plan in
                viewModel.switchToPlan(plan.id)
                showSwitchSheet = false
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
                    viewModel.checkForTrainingPlansUpdate()
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
        .onAppear {
            viewModel.checkAndTriggerWeeklyUpdate()
        }
    }

    // Helpers
    var progress: Double {
        let completed = viewModel.planProgress[plan.id]?.count ?? 0
        return plan.days.isEmpty ? 0 : Double(completed) / Double(plan.days.count)
    }
    var daysLeft: Int {
        return max(0, viewModel.daysLeft(planStartDate: viewModel.planStartDate ?? Date(), currentDate: Date(), planDurationDays: plan.duration))
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
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func requestReview() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
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
