import Foundation

class TrainingPlansViewModel: ObservableObject {
    @Published var plans: [TrainingPlan] = []
    @Published var currentPlanId: String?
    @Published var completedPlanIds: Set<String> = []
    
    @Published var planProgress: [String: Set<Int>] = [:]
    @Published var measurementProgress: [String: Set<Int>] = [:] // Track completed measurements
    @Published var measurementData: [String: [Int: Measurement]] = [:] // Store measurement data by planId -> dayIndex -> Measurement
    @Published var challengeProgress: [String: Set<Int>] = [:] // Track completed challenges
    @Published var challengeData: [String: [Int: ChallengeResult]] = [:] // Store challenge data by planId -> dayIndex -> ChallengeResult
    
    @Published var planStartDate: Date? = nil
    @Published var workouts: [String: Workout] = [:]
    
    @Published var showPlanCompletionModal: Bool = false
    @Published var showPlanFailureModal: Bool = false
    @Published var completedPlanForModal: TrainingPlan? = nil
    @Published var nextPlanForModal: TrainingPlan? = nil
    @Published var failedPlanForModal: TrainingPlan? = nil
    @Published var failedPlanPercentComplete: Int = 0
    
    @Published var showWeeklyUpdate: Bool = false
    @Published var weeklyUpdateData: WeeklyUpdateData? = nil
    @Published var weeklyUpdateSchedule: [Int] = []
    
    init() {
        loadPlans()
        loadWorkouts()
        loadUserState()
        restorePlanFailureModalIfNeeded()
        
        if let planID = currentPlanId {
            loadWeeklyUpdateSchedule(for: planID)
        }
    }
    
    private func loadPlans() {
        self.plans = TrainingPlanLoader.loadAllPlans()
    }
    
    private func loadWorkouts() {
        self.workouts = TrainingPlanLoader.loadWorkouts()
    }
    
    private func loadUserState() {
        let defaults = UserDefaults.standard
        self.currentPlanId = defaults.string(forKey: "currentPlanId") ?? plans.first?.id
        if let completed = defaults.array(forKey: "completedPlanIds") as? [String] {
            self.completedPlanIds = Set(completed)
        }
        if let progressData = defaults.data(forKey: "planProgress"),
           let progress = try? JSONDecoder().decode([String: Set<Int>].self, from: progressData) {
            self.planProgress = progress
        }
        if let measurementData = defaults.data(forKey: "measurementProgress"),
           let measurement = try? JSONDecoder().decode([String: Set<Int>].self, from: measurementData) {
            self.measurementProgress = measurement
        }
        if let measurementDataData = defaults.data(forKey: "measurementData"),
           let measurementData = try? JSONDecoder().decode([String: [Int: Measurement]].self, from: measurementDataData) {
            self.measurementData = measurementData
        }
        if let challengeData = defaults.data(forKey: "challengeProgress"),
           let challenge = try? JSONDecoder().decode([String: Set<Int>].self, from: challengeData) {
            self.challengeProgress = challenge
        }
        if let challengeDataData = defaults.data(forKey: "challengeData"),
           let challengeData = try? JSONDecoder().decode([String: [Int: ChallengeResult]].self, from: challengeDataData) {
            self.challengeData = challengeData
        }
        if let startDate = defaults.object(forKey: "planStartDate") as? Date {
            self.planStartDate = startDate
        }
        
        if self.planStartDate == nil, let firstPlan = plans.first {
            self.planStartDate = Date()
            self.currentPlanId = firstPlan.id
            dismissWeeklyUpdate()
            setupWeeklyUpdateSchedule(for: firstPlan.id)
            saveUserState()
        }
    }
    
    func getTodaysDay() -> TrainingDay? {
        guard let startDate = planStartDate else { return nil }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let currentPlan = plans.first(where: { $0.id == currentPlanId }), let day = currentPlan.days.first(where: { day in
            let dayDate = calendar.date(byAdding: .day, value: day.dayIndex - 1, to: startDate)!
            return calendar.isDate(dayDate, inSameDayAs: today)
        }) {
            return day
        }
        return nil
    }
    
    private func saveUserState() {
        let defaults = UserDefaults.standard
        defaults.set(currentPlanId, forKey: "currentPlanId")
        defaults.set(Array(completedPlanIds), forKey: "completedPlanIds")
        if let data = try? JSONEncoder().encode(planProgress) {
            defaults.set(data, forKey: "planProgress")
        }
        if let measurementData = try? JSONEncoder().encode(measurementProgress) {
            defaults.set(measurementData, forKey: "measurementProgress")
        }
        if let measurementDataData = try? JSONEncoder().encode(self.measurementData) {
            defaults.set(measurementDataData, forKey: "measurementData")
        }
        if let challengeData = try? JSONEncoder().encode(challengeProgress) {
            defaults.set(challengeData, forKey: "challengeProgress")
        }
        if let challengeDataData = try? JSONEncoder().encode(self.challengeData) {
            defaults.set(challengeDataData, forKey: "challengeData")
        }
        if let startDate = planStartDate {
            defaults.set(startDate, forKey: "planStartDate")
        }
    }
    
    func switchToPlan(_ planId: String) {
        currentPlanId = planId
        
        planProgress[planId] = []
        measurementProgress[planId] = []
        measurementData[planId] = [:]
        challengeProgress[planId] = []
        challengeData[planId] = [:]
        planStartDate = Date()
        
        clearPlanFailureModal()
        saveUserState()
        
        dismissWeeklyUpdate()
        setupWeeklyUpdateSchedule(for: planId)
        
        objectWillChange.send()
    }
    
    func markDayCompleted(dayIndex: Int) {
        guard let currentPlanId = currentPlanId else { return }
        
        var progress = planProgress[currentPlanId] ?? Set<Int>()
        progress.insert(dayIndex)
        planProgress[currentPlanId] = progress
        
        saveUserState()
        objectWillChange.send()
    }
    
    func checkForTrainingPlansUpdate() {
        guard let currentPlanId = currentPlanId else { return }
        
        if let plan = plans.first(where: { $0.id == currentPlanId }),
           planProgress[currentPlanId]?.count == plan.days.count {
            completedPlanIds.insert(currentPlanId)
            
            let currentIndex = plans.firstIndex(where: { $0.id == currentPlanId })
            var nextPlan: TrainingPlan? = nil
            if let currentIndex = currentIndex, currentIndex + 1 < plans.count {
                nextPlan = plans[currentIndex + 1]
            } else if let notCompleted = plans.first(where: { !completedPlanIds.contains($0.id) }) {
                nextPlan = notCompleted
            } else {
                nextPlan = plans.first
            }
            triggerPlanCompletionModal(completedPlan: plan, nextPlan: nextPlan)
        } else {
            checkWeeklyUpdateAfterWorkout()
        }
        
        saveUserState()
        objectWillChange.send()
    }
    
    func markMeasurementCompleted(planId: String, dayIndex: Int, duration: Double) {
        var progress = measurementProgress[planId] ?? Set<Int>()
        progress.insert(dayIndex)
        measurementProgress[planId] = progress
        
        var planMeasurements = measurementData[planId] ?? [:]
        let measurement = Measurement(id: UUID(), date: Date(), durationSeconds: duration)
        planMeasurements[dayIndex] = measurement
        measurementData[planId] = planMeasurements
        
        saveUserState()
        
        objectWillChange.send()
    }
    
    func markChallengeCompleted(planId: String, dayIndex: Int, duration: Double) {
        var progress = challengeProgress[planId] ?? Set<Int>()
        progress.insert(dayIndex)
        challengeProgress[planId] = progress
        
        var planChallenges = challengeData[planId] ?? [:]
        let challengeResult = ChallengeResult(duration: duration)
        planChallenges[dayIndex] = challengeResult
        challengeData[planId] = planChallenges
        
        saveUserState()
        
        objectWillChange.send()
    }
    
    func isDayCompleted(planId: String, dayIndex: Int) -> Bool {
        return planProgress[planId]?.contains(dayIndex) ?? false
    }
    
    func isMeasurementCompleted(planId: String, dayIndex: Int) -> Bool {
        return measurementProgress[planId]?.contains(dayIndex) ?? false
    }
    
    func isChallengeCompleted(planId: String, dayIndex: Int) -> Bool {
        return challengeProgress[planId]?.contains(dayIndex) ?? false
    }
    
    func isMeasurementScheduledForToday(dayIndex: Int) -> Bool {
        guard let startDate = planStartDate else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let scheduledDate = calendar.date(byAdding: .day, value: dayIndex - 1, to: startDate)!
        return calendar.isDate(scheduledDate, inSameDayAs: today) || scheduledDate <= today
    }
    
    func isChallengeScheduledForToday(dayIndex: Int) -> Bool {
        guard let startDate = planStartDate else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let scheduledDate = calendar.date(byAdding: .day, value: dayIndex - 1, to: startDate)!
        return calendar.isDate(scheduledDate, inSameDayAs: today) || scheduledDate <= today
    }
    
    func isPlanCompleted(_ planId: String) -> Bool {
        return completedPlanIds.contains(planId)
    }
    
    func isPlanLocked(_ plan: TrainingPlan) -> Bool {
        if plan.unlockRequirement == nil { return false }
        
        if plan.unlockRequirement == "outlast_completed" {
            return !isPlanCompleted("outlast")
        }
        return false
    }
    
    // Call this when a plan is completed
    func triggerPlanCompletionModal(completedPlan: TrainingPlan, nextPlan: TrainingPlan?) {
        self.completedPlanForModal = completedPlan
        self.nextPlanForModal = nextPlan
        self.showPlanCompletionModal = true
    }
    // Call this when a plan is failed
    func triggerPlanFailureModal(failedPlan: TrainingPlan, percentComplete: Int) {
        self.failedPlanForModal = failedPlan
        self.failedPlanPercentComplete = percentComplete
        self.showPlanFailureModal = true
        UserDefaults.standard.set(true, forKey: "showPlanFailureModal")
        UserDefaults.standard.set(failedPlan.id, forKey: "failedPlanId")
        UserDefaults.standard.set(percentComplete, forKey: "failedPlanPercentComplete")
    }
    // Call this after user acts on failure modal
    func clearPlanFailureModal() {
        self.showPlanFailureModal = false
        self.failedPlanForModal = nil
        self.failedPlanPercentComplete = 0
        UserDefaults.standard.set(false, forKey: "showPlanFailureModal")
        UserDefaults.standard.removeObject(forKey: "failedPlanId")
        UserDefaults.standard.removeObject(forKey: "failedPlanPercentComplete")
    }
    // Restore failure modal state on launch
    func restorePlanFailureModalIfNeeded() {
        let shouldShow = UserDefaults.standard.bool(forKey: "showPlanFailureModal")
        if shouldShow,
           let failedPlanId = UserDefaults.standard.string(forKey: "failedPlanId"),
           let plan = plans.first(where: { $0.id == failedPlanId }) {
            let percent = UserDefaults.standard.integer(forKey: "failedPlanPercentComplete")
            self.triggerPlanFailureModal(failedPlan: plan, percentComplete: percent)
        }
    }
    
    // Re-enroll a plan from the start (reset all progress and set as current)
    func reenrollPlanFromStart(plan: TrainingPlan) {
        let planId = plan.id
        planProgress[planId] = []
        measurementProgress[planId] = []
        measurementData[planId] = [:]
        challengeProgress[planId] = []
        challengeData[planId] = [:]
        planStartDate = Date()
        currentPlanId = planId
        completedPlanIds.remove(planId)
        
        dismissWeeklyUpdate()
        setupWeeklyUpdateSchedule(for: planId)
        
        saveUserState()
        objectWillChange.send()
    }
    
    // MARK: - Weekly Update Logic
    /// Returns the start and end date of the current week for the active plan.
    var currentWeekRange: (start: Date, end: Date)? {
        guard let planStart = planStartDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Calculate the number of days since the plan started (1-based, since day indices start from 1)
        let daysSinceStart = (calendar.dateComponents([.day], from: planStart, to: today).day ?? 0) + 1
        
        // The week number (1 = first week, 2 = second week, ...)
        let weekNumber = ((daysSinceStart - 1) / 7) + 1
        
        // Start of the current week (week 1 starts on day 1, week 2 starts on day 8, etc.)
        let weekStartDayIndex = ((weekNumber - 1) * 7) + 1
        let weekStart = calendar.date(byAdding: .day, value: weekStartDayIndex - 1, to: planStart)!
        
        // End of the current week (week 1 ends on day 7, week 2 ends on day 14, etc.)
        let weekEndDayIndex = weekNumber * 7
        let weekEndDay = calendar.date(byAdding: .day, value: weekEndDayIndex - 1, to: planStart)!
        let weekEnd = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: weekEndDay) ?? weekEndDay
        
        return (start: calendar.startOfDay(for: weekStart), end: weekEnd)
    }
    
    /// Computes the progress bar percentages for 'The Challenge' for the current and previous week.
    /// - Returns: (currentPercent, previousPercent)
    func challengeProgressBarPercentagesForCurrentWeek() -> (current: Double, previous: Double) {
        guard let planId = currentPlanId,
              let plan = plans.first(where: { $0.id == planId }),
              let weekRange = currentWeekRange,
              let startDate = planStartDate else {
            return (0, 0)
        }
        
        let calendar = Calendar.current
        
        // Get all challenge days in the plan
        let challengeDays = plan.days.filter { $0.showPracticeChallenge }
        
        // Get all challenge results for this plan
        let allChallenges = (challengeData[planId] ?? [:]).map { (dayIndex, result) in (dayIndex, result) }
        
        // Find challenge days in the current week - Fixed logic for 1-based indexing
        let weekDayIndices: [Int] = plan.days.compactMap { day in
            // Since day.dayIndex is 1-based, we subtract 1 to get the correct offset from planStart
            let scheduledDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: day.dayIndex - 1, to: startDate)!)
            let weekStart = calendar.startOfDay(for: weekRange.start)
            let weekEnd = calendar.startOfDay(for: weekRange.end)
            
            // Use start of day comparison to avoid time precision issues
            return (scheduledDate >= weekStart && scheduledDate <= weekEnd) ? day.dayIndex : nil
        }
        
        let weekChallengeDays = challengeDays.filter { weekDayIndices.contains($0.dayIndex) }
        
        // Find the challenge result for this week (if any)
        let weekChallengeResults = weekChallengeDays.compactMap { day in
            challengeData[planId]?[day.dayIndex]
        }
        
        // Find the latest challenge result in the plan before this week (if any)
        let previousChallengeResults = allChallenges.filter { (dayIndex, result) in
            // Since dayIndex is 1-based, we subtract 1 to get the correct offset from planStart
            let scheduledDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: dayIndex - 1, to: startDate)!)
            let weekStart = calendar.startOfDay(for: weekRange.start)
            return scheduledDate < weekStart
        }.map { $0.1 }
        
        // Helper to map duration to percent (non-linear)
        func durationToPercent(_ duration: TimeInterval) -> Double {
            let minutes = duration / 60.0
            if minutes <= 0 { return 0 }
            if minutes < 15 {
                return (minutes / 15.0) * 50.0
            } else if minutes < 40 {
                return 50.0 + ((minutes - 15.0) / 25.0) * 50.0
            } else {
                return 100.0
            }
        }
        
        // --- Logic per user rules ---
        // 1. No challenge this week and no previous: both 0
        if weekChallengeDays.isEmpty && previousChallengeResults.isEmpty {
            return (0, 0)
        }
        
        // 2. No challenge this week, but previous exists: both = previous percent
        if weekChallengeDays.isEmpty, let lastPrev = previousChallengeResults.last {
            let prevPercent = durationToPercent(lastPrev.duration)
            return (prevPercent, prevPercent)
        }
        
        // 3. Challenge this week, but not completed: both = previous percent (if any)
        if !weekChallengeDays.isEmpty && weekChallengeResults.isEmpty {
            let prevPercent = previousChallengeResults.last.map { durationToPercent($0.duration) } ?? 0
            return (prevPercent, prevPercent)
        }
        
        // 4. Challenge this week, completed: current = this week, previous = previous (if any)
        if let thisWeek = weekChallengeResults.last {
            let prevPercent = previousChallengeResults.last.map { durationToPercent($0.duration) } ?? 0
            let currPercent = durationToPercent(thisWeek.duration)
            return (currPercent, prevPercent)
        }
        
        // Fallback
        return (0, 0)
    }
    
    /// Computes the progress bar percentages for 'Muscle Progress' (measurement) for the current and previous week.
    /// - Returns: (currentPercent, previousPercent)
    func muscleProgressBarPercentagesForCurrentWeek() -> (current: Double, previous: Double) {
        guard let planId = currentPlanId,
              let plan = plans.first(where: { $0.id == planId }),
              let weekRange = currentWeekRange,
              let startDate = planStartDate else {
            return (0, 0)
        }
        
        let calendar = Calendar.current
        
        // Get all measurement days in the plan
        let measurementDays = plan.days.filter { $0.showPracticeMeasurement }
        
        // Get all measurement results for this plan
        let allMeasurements = (measurementData[planId] ?? [:]).map { (dayIndex, result) in (dayIndex, result) }
        
        // Find measurement days in the current week - Fixed logic for 1-based indexing
        let weekDayIndices: [Int] = plan.days.compactMap { day in
            // Since day.dayIndex is 1-based, we subtract 1 to get the correct offset from planStart
            let scheduledDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: day.dayIndex - 1, to: startDate)!)
            let weekStart = calendar.startOfDay(for: weekRange.start)
            let weekEnd = calendar.startOfDay(for: weekRange.end)
            
            // Use start of day comparison to avoid time precision issues
            return (scheduledDate >= weekStart && scheduledDate <= weekEnd) ? day.dayIndex : nil
        }
        
        let weekMeasurementDays = measurementDays.filter { weekDayIndices.contains($0.dayIndex) }
        
        // Find the measurement result for this week (if any)
        let weekMeasurementResults = weekMeasurementDays.compactMap { day in
            measurementData[planId]?[day.dayIndex]
        }
        
        // Find the latest measurement result in the plan before this week (if any)
        let previousMeasurementResults = allMeasurements.filter { (dayIndex, result) in
            // Since dayIndex is 1-based, we subtract 1 to get the correct offset from planStart
            let scheduledDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: dayIndex - 1, to: startDate)!)
            let weekStart = calendar.startOfDay(for: weekRange.start)
            return scheduledDate < weekStart
        }.map { $0.1 }
        
        // Helper to map duration to percent (linear, 0–300s = 0–100%)
        func durationToPercent(_ duration: Double) -> Double {
            let percent = (duration / 300.0) * 100.0
            return min(max(percent, 0), 100)
        }
        
        // --- Logic per user rules ---
        // 1. No measurement this week and no previous: both 0
        if weekMeasurementDays.isEmpty && previousMeasurementResults.isEmpty {
            return (0, 0)
        }
        
        // 2. No measurement this week, but previous exists: both = previous percent
        if weekMeasurementDays.isEmpty, let lastPrev = previousMeasurementResults.last {
            let prevPercent = durationToPercent(lastPrev.durationSeconds)
            return (prevPercent, prevPercent)
        }
        
        // 3. Measurement this week, but not completed: both = previous percent (if any)
        if !weekMeasurementDays.isEmpty && weekMeasurementResults.isEmpty {
            let prevPercent = previousMeasurementResults.last.map { durationToPercent($0.durationSeconds) } ?? 0
            return (prevPercent, prevPercent)
        }
        
        // 4. Measurement this week, completed: current = this week, previous = previous (if any)
        if let thisWeek = weekMeasurementResults.last {
            let prevPercent = previousMeasurementResults.last.map { durationToPercent($0.durationSeconds) } ?? 0
            let currPercent = durationToPercent(thisWeek.durationSeconds)
            return (currPercent, prevPercent)
        }
        
        // Fallback
        return (0, 0)
    }
    
    func daysLeft(planStartDate: Date, currentDate: Date, planDurationDays: Int) -> Int {
        let planEndDate = Calendar.current.date(byAdding: .day, value: planDurationDays, to: planStartDate) ?? planStartDate
        
        let components = Calendar.current.dateComponents([.day], from: currentDate, to: planEndDate)
        return ((components.day ?? 0) + 1)
    }
    
    // MARK: - Weekly Update New Logic
    
    func setupWeeklyUpdateSchedule(for planId: String) {
        guard let plan = plans.first(where: { $0.id == planId }) else { return }
        
        let planDuration = plan.days.count
        let totalWeeks = (planDuration + 6) / 7
        let weeklyUpdateCount = totalWeeks - 1
        
        weeklyUpdateSchedule = Array(1...weeklyUpdateCount)
        
        clearWeeklyUpdateTracking(for: planId)
        
        saveWeeklyUpdateSchedule(for: planId)
    }
    
    func checkAndTriggerWeeklyUpdate() {
        guard let planId = currentPlanId,
              let startDate = planStartDate else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Calculate current week number (1-based)
        let daysSinceStart = (calendar.dateComponents([.day], from: startDate, to: today).day ?? 0) + 1
        let currentWeekNumber = (daysSinceStart / 7) + 1
        
        // Check if current week is the last day of a week that should show update
        if isLastDayOfWeek(currentDate: today, startDate: startDate) {
            let weekToCheck = currentWeekNumber
            if weeklyUpdateSchedule.contains(weekToCheck) &&
                !hasShownWeeklyUpdate(planId: planId, weekNumber: weekToCheck) {
                // Don't show immediately - will be triggered after workout completion
                return
            }
        }
        
        // Check if we should show update for any previous week
        for weekNumber in weeklyUpdateSchedule {
            if weekNumber + 1 == currentWeekNumber &&
                !hasShownWeeklyUpdate(planId: planId, weekNumber: weekNumber) {
                // Show the weekly update for this missed week
                generateWeeklyUpdateData(for: planId, weekNumber: weekNumber)
                return // Show only one update at a time
            }
        }
    }
    
    /// Call this after every workout completion to check if we should show weekly update
    func checkWeeklyUpdateAfterWorkout() {
        guard let planId = currentPlanId,
              let startDate = planStartDate else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Calculate current week number (1-based)
        let daysSinceStart = (calendar.dateComponents([.day], from: startDate, to: today).day ?? 0) + 1
        let currentWeekNumber = (daysSinceStart / 7) + 1
        
        // Check if today is the last day of a week that should show update
        if isLastDayOfWeek(currentDate: today, startDate: startDate) {
            if weeklyUpdateSchedule.contains(currentWeekNumber) &&
                !hasShownWeeklyUpdate(planId: planId, weekNumber: currentWeekNumber) &&
                hasCompletedTodaysWorkout(planId: planId, date: today) {
                // Show weekly update immediately
                generateWeeklyUpdateData(for: planId, weekNumber: currentWeekNumber)
            }
        }
    }
    
    /// Generates the weekly update data for display
    private func generateWeeklyUpdateData(for planId: String, weekNumber: Int) {
        guard let plan = plans.first(where: { $0.id == planId }),
              let startDate = planStartDate else { return }
        
        let calendar = Calendar.current
        
        // Calculate week boundaries (weekNumber is 1-based)
        let weekStart = calendar.date(byAdding: .day, value: (weekNumber - 1) * 7, to: startDate)!
        let weekEnd = calendar.date(byAdding: .day, value: (weekNumber * 7) - 1, to: startDate)!
        
        // Get workouts for this week
        let weekDays = plan.days.filter { day in
            let dayDate = calendar.date(byAdding: .day, value: day.dayIndex - 1, to: startDate)!
            return dayDate >= weekStart && dayDate <= weekEnd
        }
        
        // Calculate completed workouts in this week
        let completedWorkouts = weekDays.filter { day in
            isDayCompleted(planId: planId, dayIndex: day.dayIndex)
        }.count
        
        // Calculate total workout minutes
        let workoutMinutes = calculateWorkoutMinutes(for: weekDays, planId: planId)
        
        // Get challenge and muscle progress for this specific week
        let challengeProgress = getChallengeProgressForWeek(planId: planId, weekNumber: weekNumber)
        let muscleProgress = getMuscleProgressForWeek(planId: planId, weekNumber: weekNumber)
        
        // Create weekly update data
        let updateData = WeeklyUpdateData(
            weekNumber: weekNumber,
            weekStartDate: weekStart,
            weekEndDate: weekEnd,
            workoutsCompleted: completedWorkouts,
            totalWorkoutsInWeek: weekDays.count,
            workoutMinutes: workoutMinutes,
            challengeProgress: challengeProgress,
            muscleProgress: muscleProgress
        )
        
        // Trigger the weekly update modal
        self.weeklyUpdateData = updateData
        self.showWeeklyUpdate = true
        
        // Mark this week's update as shown
        markWeeklyUpdateShown(planId: planId, weekNumber: weekNumber)
    }
    
    private func isLastDayOfWeek(currentDate: Date, startDate: Date) -> Bool {
        let calendar = Calendar.current
        let daysSinceStart = (calendar.dateComponents([.day], from: startDate, to: currentDate).day ?? 0) + 1
        return (daysSinceStart + 1) % 7 == 0 // daysSinceStart is 0-based, so add 1
    }
    
    /// Checks if today's workout has been completed
    private func hasCompletedTodaysWorkout(planId: String, date: Date) -> Bool {
        guard let startDate = planStartDate else { return false }
        
        let calendar = Calendar.current
        let daysSinceStart = (calendar.dateComponents([.day], from: startDate, to: date).day ?? 0) + 1
        let dayIndex = daysSinceStart + 1 // dayIndex is 1-based
        
        return isDayCompleted(planId: planId, dayIndex: dayIndex)
    }
    
    /// Calculates workout minutes for given days
    private func calculateWorkoutMinutes(for days: [TrainingDay], planId: String) -> Int {
        var totalMinutes = 0
        for day in days {
            if isDayCompleted(planId: planId, dayIndex: day.dayIndex) {
                if let workout = workouts[day.workoutId] {
                    totalMinutes += workout.durationMinutes
                } else {
                    totalMinutes += 30
                }
            }
        }
        return totalMinutes
    }
    
    /// Gets challenge progress for a specific week
    private func getChallengeProgressForWeek(planId: String, weekNumber: Int) -> (current: Double, previous: Double)? {
        // You can adapt your existing challenge progress methods for specific weeks
        // For now, using the existing method as placeholder
        return challengeProgressBarPercentagesForCurrentWeek()
    }
    
    /// Gets muscle progress for a specific week
    private func getMuscleProgressForWeek(planId: String, weekNumber: Int) -> (current: Double, previous: Double)? {
        // You can adapt your existing muscle progress methods for specific weeks
        // For now, using the existing method as placeholder
        return muscleProgressBarPercentagesForCurrentWeek()
    }
    
    // MARK: - UserDefaults Management for Weekly Updates
    
    /// Saves the weekly update schedule for a plan
    private func saveWeeklyUpdateSchedule(for planId: String) {
        UserDefaults.standard.set(weeklyUpdateSchedule, forKey: "weeklyUpdateSchedule_\(planId)")
    }
    
    /// Loads the weekly update schedule for a plan
    private func loadWeeklyUpdateSchedule(for planId: String) {
        weeklyUpdateSchedule = UserDefaults.standard.array(forKey: "weeklyUpdateSchedule_\(planId)") as? [Int] ?? []
    }
    
    /// Marks a weekly update as shown for a specific plan and week
    private func markWeeklyUpdateShown(planId: String, weekNumber: Int) {
        var shownUpdates = getShownWeeklyUpdates()
        let key = "\(planId)_week_\(weekNumber)"
        shownUpdates.insert(key)
        
        UserDefaults.standard.set(Array(shownUpdates), forKey: "shownWeeklyUpdates")
    }
    
    /// Checks if a weekly update has been shown for a specific plan and week
    private func hasShownWeeklyUpdate(planId: String, weekNumber: Int) -> Bool {
        let shownUpdates = getShownWeeklyUpdates()
        let key = "\(planId)_week_\(weekNumber)"
        return shownUpdates.contains(key)
    }
    
    /// Gets all shown weekly updates from UserDefaults
    private func getShownWeeklyUpdates() -> Set<String> {
        let updates = UserDefaults.standard.array(forKey: "shownWeeklyUpdates") as? [String] ?? []
        return Set(updates)
    }
    
    /// Clears weekly update tracking for a plan (call when switching plans)
    func clearWeeklyUpdateTracking(for planId: String) {
        var shownUpdates = getShownWeeklyUpdates()
        shownUpdates = shownUpdates.filter { !$0.hasPrefix("\(planId)_week_") }
        UserDefaults.standard.set(Array(shownUpdates), forKey: "shownWeeklyUpdates")
        
        // Also clear the schedule
        UserDefaults.standard.removeObject(forKey: "weeklyUpdateSchedule_\(planId)")
    }
    
    /// Call this when user dismisses the weekly update modal
    func dismissWeeklyUpdate() {
        self.showWeeklyUpdate = false
        self.weeklyUpdateData = nil
    }
}

// MARK: - Weekly Update and Measurement Progress Data Structure

struct WeeklyUpdateData {
    let weekNumber: Int
    let weekStartDate: Date
    let weekEndDate: Date
    let workoutsCompleted: Int
    let totalWorkoutsInWeek: Int
    let workoutMinutes: Int
    let challengeProgress: (current: Double, previous: Double)?
    let muscleProgress: (current: Double, previous: Double)?
}

struct MeasurementProgress {
    let firstMeasurement: Double
    let lastMeasurement: Double
    let improvement: Double
    let percentageChange: Double
    let totalMeasurements: Int
    
    var isImprovement: Bool {
        return improvement > 0
    }
    
    var formattedPercentageChange: String {
        let sign = percentageChange >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", percentageChange))%"
    }
    
    var formattedImprovement: String {
        let sign = improvement >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", improvement))s"
    }
}

// MARK: - Challenge Progress Data Structure

struct ChallengeProgress {
    let firstChallenge: Double
    let lastChallenge: Double
    let improvement: Double
    let percentageChange: Double
    let totalChallenges: Int
    let bestRank: String
    
    var isImprovement: Bool {
        return improvement > 0
    }
    
    var formattedPercentageChange: String {
        let sign = percentageChange >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", percentageChange))%"
    }
    
    var formattedImprovement: String {
        let sign = improvement >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", improvement))s"
    }
}

extension TrainingPlansViewModel {
    static var preview: TrainingPlansViewModel {
        let vm = TrainingPlansViewModel()
        let mockPlan = TrainingPlan(
            id: "kegel_basics",
            name: "Kegel Basics",
            duration: 35,
            difficulty: "Easy",
            summary: "A beginner program to build pelvic floor strength.",
            description: "This is a detailed description of the Kegel Basics plan.",
            unlockRequirement: nil,
            days: [],
            image: "trainingPlanBgSmall"
        )
        vm.plans = [mockPlan]
        vm.currentPlanId = "kegel_basics"
        return vm
    }
} 
