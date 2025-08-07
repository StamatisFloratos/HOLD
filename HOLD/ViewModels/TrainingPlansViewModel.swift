import Foundation

class TrainingPlansViewModel: ObservableObject {
    @Published var plans: [TrainingPlan] = []
    @Published var currentPlanId: String?
    @Published var completedPlanIds: Set<String> = []
    
    @Published var planProgress: [String: Set<Int>] = [:]
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
    
    @Published var globalMeasurements: [GlobalMeasurement] = []
    @Published var globalChallenges: [GlobalChallenge] = []
    
    // MARK: - Plan Configuration Constants
    private let planTargets: [String: (challengeMinutes: Double, muscleSeconds: Double)] = [
        "kegel_basics": (challengeMinutes: 5, muscleSeconds: 60),
        "stronger_holds": (challengeMinutes: 15, muscleSeconds: 120),
        "full_control": (challengeMinutes: 20, muscleSeconds: 200),
        "outlast": (challengeMinutes: 30, muscleSeconds: 300),
        "multi_orgasm_protocol": (challengeMinutes: 40, muscleSeconds: 400)
    ]
    
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
        
        // Load global measurements and challenges
        if let measurementsData = defaults.data(forKey: "globalMeasurements"),
           let measurements = try? JSONDecoder().decode([GlobalMeasurement].self, from: measurementsData) {
            self.globalMeasurements = measurements
        }
        
        if let challengesData = defaults.data(forKey: "globalChallenges"),
           let challenges = try? JSONDecoder().decode([GlobalChallenge].self, from: challengesData) {
            self.globalChallenges = challenges
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
        
        // Save global measurements and challenges
        if let measurementsData = try? JSONEncoder().encode(globalMeasurements) {
            defaults.set(measurementsData, forKey: "globalMeasurements")
        }
        
        if let challengesData = try? JSONEncoder().encode(globalChallenges) {
            defaults.set(challengesData, forKey: "globalChallenges")
        }
        
        if let startDate = planStartDate {
            defaults.set(startDate, forKey: "planStartDate")
        }
    }
    
    func switchToPlan(_ planId: String) {
        currentPlanId = planId
        
        planProgress[planId] = []
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
        let newMeasurement = GlobalMeasurement(duration: duration, planId: planId, dayIndex: dayIndex)
        globalMeasurements.append(newMeasurement)
        
        saveUserState()
        objectWillChange.send()
    }
    
    func markChallengeCompleted(planId: String, dayIndex: Int, duration: Double) {
        let newChallenge = GlobalChallenge(duration: duration, planId: planId, dayIndex: dayIndex)
        globalChallenges.append(newChallenge)
        
        saveUserState()
        objectWillChange.send()
        
        checkWeeklyUpdateAfterWorkout()
    }
    
    func isDayCompleted(planId: String, dayIndex: Int) -> Bool {
        return planProgress[planId]?.contains(dayIndex) ?? false
    }
    
    func isMeasurementCompleted(planId: String, dayIndex: Int) -> Bool {
        return globalMeasurements.contains { $0.planId == planId && $0.dayIndex == dayIndex }
    }
    
    func isChallengeCompleted(planId: String, dayIndex: Int) -> Bool {
        return globalChallenges.contains { $0.planId == planId && $0.dayIndex == dayIndex }
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
    
    /// Calculate challenge progress comparing this week's challenge to the last challenge taken (completely global)
    /// Returns: (hasProgress: Bool, currentPercent: Double, previousPercent: Double, timeIncrease: String)
    func calculateWeeklyChallengeProgress() -> ProgressBarModel {
        guard let planId = currentPlanId,
              let planTarget = planTargets[planId] else {
            return ProgressBarModel(currentPercentage: 0, previousPercentage: 0, hasProgress: false, isMax: false, displayText: "No Measurement")
        }
        
        let calendar = Calendar.current
        let currentWeekRange = getCurrentWeekDateRange()
        
        let thisWeekChallenges = globalChallenges.filter { challenge in
            let challengeDate = calendar.startOfDay(for: challenge.date)
            return challengeDate >= currentWeekRange.start && challengeDate <= currentWeekRange.end
        }.sorted { $0.date > $1.date }
        
        let previousChallenges = globalChallenges.filter { challenge in
            let challengeDate = calendar.startOfDay(for: challenge.date)
            return challengeDate < currentWeekRange.start
        }.sorted { $0.date > $1.date }
        
        let targetSeconds = planTarget.challengeMinutes * 60
        let previousChallengeDuration = previousChallenges.first?.duration ?? 0
        let previousPercent = min((previousChallengeDuration / targetSeconds) * 100, 100)
        
        guard let thisWeekChallenge = thisWeekChallenges.first else {
            return ProgressBarModel(currentPercentage: 0, previousPercentage: previousPercent, hasProgress: false, isMax: false, displayText: "No Measurement")
        }
        
        let currentPercent = min((thisWeekChallenge.duration / targetSeconds) * 100, 100)
        
        guard thisWeekChallenge.duration > previousChallengeDuration else {
            return ProgressBarModel(currentPercentage: 0, previousPercentage: currentPercent, hasProgress: false, isMax: false, displayText: "No Progress")
            
        }
        
        if thisWeekChallenge.duration >= targetSeconds {
            return ProgressBarModel(currentPercentage: 100, previousPercentage: previousPercent, hasProgress: true, isMax: true, displayText: "MAX")
        }
        
        let timeIncrease = thisWeekChallenge.duration - previousChallengeDuration
        let timeIncreaseText = formatTimeIncrease(timeIncrease)
        
        return ProgressBarModel(currentPercentage: currentPercent, previousPercentage: previousPercent, hasProgress: true, isMax: false, displayText: timeIncreaseText)
    }
    
    /// Calculate muscle progress comparing this week's measurement to the last measurement taken (completely global)
    func calculateWeeklyMuscleProgress() -> ProgressBarModel {
        guard let planId = currentPlanId,
              let planTarget = planTargets[planId] else {
            return ProgressBarModel(currentPercentage: 0, previousPercentage: 0, hasProgress: false, isMax: false, displayText: "No Measurement")
        }
        
        let calendar = Calendar.current
        let currentWeekRange = getCurrentWeekDateRange()
        
        let thisWeekMeasurements = globalMeasurements.filter { measurement in
            let measurementDate = calendar.startOfDay(for: measurement.date)
            return measurementDate >= currentWeekRange.start && measurementDate <= currentWeekRange.end
        }.sorted { $0.date > $1.date }
        
        let previousMeasurements = globalMeasurements.filter { measurement in
            let measurementDate = calendar.startOfDay(for: measurement.date)
            return measurementDate < currentWeekRange.start
        }.sorted { $0.date > $1.date }

        let targetSeconds = planTarget.muscleSeconds
        let previousMeasurementDuration = previousMeasurements.first?.duration ?? 0
        let previousPercent = min((previousMeasurementDuration / targetSeconds) * 100, 100)
        
        guard let thisWeekMeasurement = thisWeekMeasurements.first else {
            return ProgressBarModel(currentPercentage: 0, previousPercentage: previousPercent, hasProgress: false, isMax: false, displayText: "No Measurement")
        }
        
        let currentPercent = min((thisWeekMeasurement.duration / targetSeconds) * 100, 100)
        
        guard thisWeekMeasurement.duration > previousMeasurementDuration else {
            return ProgressBarModel(currentPercentage: 0, previousPercentage: currentPercent, hasProgress: false, isMax: false, displayText: "No Progress")
        }
        
        if thisWeekMeasurement.duration >= targetSeconds {
            return ProgressBarModel(currentPercentage: 100, previousPercentage: previousPercent, hasProgress: true, isMax: true, displayText: "MAX")
        }
        
        let timeIncrease = thisWeekMeasurement.duration - previousMeasurementDuration
        let timeIncreaseText = formatTimeIncrease(timeIncrease)
        
        return ProgressBarModel(currentPercentage: currentPercent, previousPercentage: previousPercent, hasProgress: true, isMax: false, displayText: timeIncreaseText)
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
                if let day = getTodaysDay(), isChallengeScheduledForToday(dayIndex: day.dayIndex) {
                    if isChallengeCompleted(planId: planId, dayIndex: day.dayIndex) {
                        generateWeeklyUpdateData(for: planId, weekNumber: currentWeekNumber)
                    }
                } else {
                    generateWeeklyUpdateData(for: planId, weekNumber: currentWeekNumber)
                }
            }
        }
    }
    
    /// Generates the weekly update data for display using new logic
    private func generateWeeklyUpdateData(for planId: String, weekNumber: Int) {
        guard let plan = plans.first(where: { $0.id == planId }),
              let startDate = planStartDate else { return }
        
        let calendar = Calendar.current
        
        // Calculate week boundaries
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
        
        // Get challenge and muscle progress using new methods
        let challengeProgress = calculateWeeklyChallengeProgress()
        let muscleProgress = calculateWeeklyMuscleProgress()
        
        // Create weekly update data with new progress structure
        let updateData = WeeklyUpdateData(
            weekNumber: weekNumber,
            weekStartDate: weekStart,
            weekEndDate: weekEnd,
            workoutsCompleted: completedWorkouts,
            totalWorkoutsInWeek: weekDays.count,
            workoutMinutes: workoutMinutes,
            challengeProgress: calculateWeeklyChallengeProgress(),
            muscleProgress: calculateWeeklyMuscleProgress()
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
    
    // MARK: - Helper Methods
    
    private func getCurrentWeekDateRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get the start of the current week (Monday)
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7  // Convert Sunday=1 to Monday=0 system
        let weekStart = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        
        // Get the end of the current week (Sunday)
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? today
        let weekEndWithTime = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: weekEnd) ?? weekEnd
        
        return (start: weekStart, end: weekEndWithTime)
    }
    
    private func formatTimeIncrease(_ seconds: Double) -> String {
        if seconds < 60 {
            return "+\(String(format: "%.0f", seconds))s"
        } else {
            let minutes = seconds / 60
            if minutes.truncatingRemainder(dividingBy: 1) == 0 {
                return "+\(String(format: "%.0f", minutes))min"
            } else {
                return "+\(String(format: "%.1f", minutes))min"
            }
        }
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
    let challengeProgress: ProgressBarModel
    let muscleProgress: ProgressBarModel
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

struct GlobalMeasurement: Codable {
    let id: UUID
    let duration: Double
    let date: Date
    let planId: String
    let dayIndex: Int
    
    init(duration: Double, planId: String, dayIndex: Int) {
        self.id = UUID()
        self.duration = duration
        self.date = Date()
        self.planId = planId
        self.dayIndex = dayIndex
    }
}

struct GlobalChallenge: Codable {
    let id: UUID
    let duration: Double
    let date: Date
    let planId: String
    let dayIndex: Int
    
    init(duration: Double, planId: String, dayIndex: Int) {
        self.id = UUID()
        self.duration = duration
        self.date = Date()
        self.planId = planId
        self.dayIndex = dayIndex
    }
}

struct ProgressBarModel: Codable {
    let currentPercentage: Double
    let previousPercentage: Double
    let hasProgress: Bool
    let isMax: Bool
    let displayText: String
}
