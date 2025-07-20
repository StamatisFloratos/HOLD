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
    
    init() {
        loadPlans()
        loadWorkouts()
        loadUserState()
        restorePlanFailureModalIfNeeded()
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
        // Auto-start the default plan for all users if not started
        if self.planStartDate == nil, let firstPlan = plans.first {
            self.planStartDate = Date()
            self.currentPlanId = firstPlan.id
            saveUserState()
        }
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
        saveUserState()
        
        // Force UI update
        objectWillChange.send()
    }
    
    func markDayCompleted(planId: String, dayIndex: Int) {
        var progress = planProgress[planId] ?? Set<Int>()
        progress.insert(dayIndex)
        planProgress[planId] = progress
        // If all days completed, mark plan as completed
        if let plan = plans.first(where: { $0.id == planId }),
           progress.count == plan.days.count {
            completedPlanIds.insert(planId)
            // Find the next plan: first, try next in list; if not, pick first not completed; if all completed, pick first plan
            let currentIndex = plans.firstIndex(where: { $0.id == planId })
            var nextPlan: TrainingPlan? = nil
            if let currentIndex = currentIndex, currentIndex + 1 < plans.count {
                nextPlan = plans[currentIndex + 1]
            } else if let notCompleted = plans.first(where: { !completedPlanIds.contains($0.id) }) {
                nextPlan = notCompleted
            } else {
                nextPlan = plans.first
            }
            triggerPlanCompletionModal(completedPlan: plan, nextPlan: nextPlan)
        }
        
        // Also save the workout completion to the main workout system
        if let plan = plans.first(where: { $0.id == planId }),
           let day = plan.days.first(where: { $0.dayIndex == dayIndex }),
           let workout = workouts[day.workoutId] {
            WorkoutCompletionManager.saveCompletion(WorkoutCompletion(workoutName: workout.name))
            
            // Update streak data as well
            updateStreakData()
        }
        
        saveUserState()
        
        // Force UI update
        objectWillChange.send()
    }
    
    func markMeasurementCompleted(planId: String, dayIndex: Int, duration: Double) {
        var progress = measurementProgress[planId] ?? Set<Int>()
        progress.insert(dayIndex)
        measurementProgress[planId] = progress
        
        // Save the measurement data
        var planMeasurements = measurementData[planId] ?? [:]
        let measurement = Measurement(id: UUID(), date: Date(), durationSeconds: duration)
        planMeasurements[dayIndex] = measurement
        measurementData[planId] = planMeasurements
        
        saveUserState()
        
        // Force UI update
        objectWillChange.send()
    }
    
    func markChallengeCompleted(planId: String, dayIndex: Int, duration: Double) {
        var progress = challengeProgress[planId] ?? Set<Int>()
        progress.insert(dayIndex)
        challengeProgress[planId] = progress
        
        // Save the challenge data
        var planChallenges = challengeData[planId] ?? [:]
        let challengeResult = ChallengeResult(duration: duration)
        planChallenges[dayIndex] = challengeResult
        challengeData[planId] = planChallenges
        
        saveUserState()
        
        // Force UI update
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
        return calendar.isDate(scheduledDate, inSameDayAs: today)
    }
    
    func isChallengeScheduledForToday(dayIndex: Int) -> Bool {
        guard let startDate = planStartDate else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let scheduledDate = calendar.date(byAdding: .day, value: dayIndex - 1, to: startDate)!
        return calendar.isDate(scheduledDate, inSameDayAs: today)
    }
    
    // MARK: - Progress Calculation Methods for Weekly Updates
    
    func getMeasurementProgress(planId: String) -> MeasurementProgress? {
        guard let planMeasurements = measurementData[planId], !planMeasurements.isEmpty else {
            return nil
        }
        
        let sortedMeasurements = planMeasurements.sorted { $0.key < $1.key }
        guard let firstMeasurement = sortedMeasurements.first?.value,
              let lastMeasurement = sortedMeasurements.last?.value else {
            return nil
        }
        
        let firstDuration = firstMeasurement.durationSeconds
        let lastDuration = lastMeasurement.durationSeconds
        let improvement = lastDuration - firstDuration
        let percentageChange = firstDuration > 0 ? (improvement / firstDuration) * 100 : 0
        
        return MeasurementProgress(
            firstMeasurement: firstDuration,
            lastMeasurement: lastDuration,
            improvement: improvement,
            percentageChange: percentageChange,
            totalMeasurements: planMeasurements.count
        )
    }
    
    func getWeeklyMeasurementProgress(planId: String) -> MeasurementProgress? {
        guard let startDate = planStartDate else { return nil }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
        
        // Get measurements from the last 7 days
        let recentMeasurements = measurementData[planId]?.filter { dayIndex, measurement in
            let scheduledDate = calendar.date(byAdding: .day, value: dayIndex - 1, to: startDate)!
            return scheduledDate >= weekAgo && scheduledDate <= today
        } ?? [:]
        
        guard !recentMeasurements.isEmpty else { return nil }
        
        let sortedMeasurements = recentMeasurements.sorted { $0.key < $1.key }
        guard let firstMeasurement = sortedMeasurements.first?.value,
              let lastMeasurement = sortedMeasurements.last?.value else {
            return nil
        }
        
        let firstDuration = firstMeasurement.durationSeconds
        let lastDuration = lastMeasurement.durationSeconds
        let improvement = lastDuration - firstDuration
        let percentageChange = firstDuration > 0 ? (improvement / firstDuration) * 100 : 0
        
        return MeasurementProgress(
            firstMeasurement: firstDuration,
            lastMeasurement: lastDuration,
            improvement: improvement,
            percentageChange: percentageChange,
            totalMeasurements: recentMeasurements.count
        )
    }
    
    func getChallengeProgress(planId: String) -> ChallengeProgress? {
        guard let planChallenges = challengeData[planId], !planChallenges.isEmpty else {
            return nil
        }
        
        let sortedChallenges = planChallenges.sorted { $0.key < $1.key }
        guard let firstChallenge = sortedChallenges.first?.value,
              let lastChallenge = sortedChallenges.last?.value else {
            return nil
        }
        
        let firstDuration = firstChallenge.duration
        let lastDuration = lastChallenge.duration
        let improvement = lastDuration - firstDuration
        let percentageChange = firstDuration > 0 ? (improvement / firstDuration) * 100 : 0
        
        return ChallengeProgress(
            firstChallenge: firstDuration,
            lastChallenge: lastDuration,
            improvement: improvement,
            percentageChange: percentageChange,
            totalChallenges: planChallenges.count,
            bestRank: planChallenges.values.map { $0.rankDisplay }.min() ?? "Unknown"
        )
    }
    
    func getWeeklyChallengeProgress(planId: String) -> ChallengeProgress? {
        guard let startDate = planStartDate else { return nil }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
        
        // Get challenges from the last 7 days
        let recentChallenges = challengeData[planId]?.filter { dayIndex, challenge in
            let scheduledDate = calendar.date(byAdding: .day, value: dayIndex - 1, to: startDate)!
            return scheduledDate >= weekAgo && scheduledDate <= today
        } ?? [:]
        
        guard !recentChallenges.isEmpty else { return nil }
        
        let sortedChallenges = recentChallenges.sorted { $0.key < $1.key }
        guard let firstChallenge = sortedChallenges.first?.value,
              let lastChallenge = sortedChallenges.last?.value else {
            return nil
        }
        
        let firstDuration = firstChallenge.duration
        let lastDuration = lastChallenge.duration
        let improvement = lastDuration - firstDuration
        let percentageChange = firstDuration > 0 ? (improvement / firstDuration) * 100 : 0
        
        return ChallengeProgress(
            firstChallenge: firstDuration,
            lastChallenge: lastDuration,
            improvement: improvement,
            percentageChange: percentageChange,
            totalChallenges: recentChallenges.count,
            bestRank: recentChallenges.values.map { $0.rankDisplay }.min() ?? "Unknown"
        )
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
    
    // MARK: - Streak Data Management
    
    private func updateStreakData() {
        // This method updates streak data similar to WorkoutViewModel
        let today = Calendar.current.startOfDay(for: Date())
        
        // Load existing streak dates
        var streakDates = loadStreakDatesFromFile()
        
        // Check if we already recorded today
        if !streakDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
            // Add today to streak dates
            streakDates.append(today)
            
            // Save updated streak data
            saveStreakDatesToFile(streakDates)
        }
    }
    
    private var streakDatesFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("workout_streak_dates.json")
    }
    
    private func saveStreakDatesToFile(_ dates: [Date]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(dates)
            try data.write(to: streakDatesFileURL, options: [.atomicWrite])
        } catch {
            // Error saving streak dates
        }
    }
    
    private func loadStreakDatesFromFile() -> [Date] {
        guard FileManager.default.fileExists(atPath: streakDatesFileURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: streakDatesFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let dates = try decoder.decode([Date].self, from: data)
            return dates
        } catch {
            return []
        }
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
        saveUserState()
        objectWillChange.send()
    }
    
    // MARK: - Weekly Update Logic
    /// Returns the start and end date of the current week for the active plan.
    var currentWeekRange: (start: Date, end: Date)? {
        guard let planStart = planStartDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // Find the weekday of the plan start (1 = Sunday, 2 = Monday, ... 7 = Saturday)
        let planStartWeekday = calendar.component(.weekday, from: planStart)
        // Calculate the number of days since the plan started
        let daysSinceStart = calendar.dateComponents([.day], from: planStart, to: today).day ?? 0
        // The week number (0 = first week, 1 = second week, ...)
        let weekNumber = daysSinceStart / 7
        // Start of the current week
        let weekStart = calendar.date(byAdding: .day, value: weekNumber * 7, to: planStart)!
        // End of the current week (inclusive)
        let weekEnd = calendar.date(byAdding: .day, value: (weekNumber + 1) * 7 - 1, to: planStart)!
        return (start: calendar.startOfDay(for: weekStart), end: calendar.startOfDay(for: weekEnd))
    }

    /// Computes the weekly stats for the current plan and week (excluding streak).
    func weeklyStats(for workouts: [Workout]) -> (workoutsCompleted: Int, workoutMinutes: Int)? {
        guard let planId = currentPlanId, let weekRange = currentWeekRange else { return nil }
        // Get all completions for this week
        let completions = WorkoutCompletionManager.getCompletions().filter { completion in
            completion.completed &&
            completion.date >= weekRange.start &&
            completion.date <= weekRange.end &&
            workouts.contains(where: { $0.name == completion.workoutName })
        }
        // Workouts completed this week
        let workoutsCompleted = completions.count
        // Total workout minutes this week
        let workoutMinutes = completions.compactMap { completion in
            workouts.first(where: { $0.name == completion.workoutName })?.durationMinutes
        }.reduce(0, +)
        return (workoutsCompleted, workoutMinutes)
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
        // Find challenge days in the current week
        let weekDayIndices: [Int] = plan.days.compactMap { day in
            let scheduledDate = calendar.date(byAdding: .day, value: day.dayIndex - 1, to: startDate)!
            return (scheduledDate >= weekRange.start && scheduledDate <= weekRange.end) ? day.dayIndex : nil
        }
        let weekChallengeDays = challengeDays.filter { weekDayIndices.contains($0.dayIndex) }
        // Find the challenge result for this week (if any)
        let weekChallengeResults = weekChallengeDays.compactMap { day in
            challengeData[planId]?[day.dayIndex]
        }
        // Find the latest challenge result in the plan before this week (if any)
        let previousChallengeResults = allChallenges.filter { (dayIndex, result) in
            let scheduledDate = calendar.date(byAdding: .day, value: dayIndex - 1, to: startDate)!
            return scheduledDate < weekRange.start
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
        // Find measurement days in the current week
        let weekDayIndices: [Int] = plan.days.compactMap { day in
            let scheduledDate = calendar.date(byAdding: .day, value: day.dayIndex - 1, to: startDate)!
            return (scheduledDate >= weekRange.start && scheduledDate <= weekRange.end) ? day.dayIndex : nil
        }
        let weekMeasurementDays = measurementDays.filter { weekDayIndices.contains($0.dayIndex) }
        // Find the measurement result for this week (if any)
        let weekMeasurementResults = weekMeasurementDays.compactMap { day in
            measurementData[planId]?[day.dayIndex]
        }
        // Find the latest measurement result in the plan before this week (if any)
        let previousMeasurementResults = allMeasurements.filter { (dayIndex, result) in
            let scheduledDate = calendar.date(byAdding: .day, value: dayIndex - 1, to: startDate)!
            return scheduledDate < weekRange.start
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
}

// MARK: - Measurement Progress Data Structure

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
