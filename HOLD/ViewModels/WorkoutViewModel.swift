//
//  WorkoutViewModel.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation
import SwiftUI

class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var isWorkoutInProgress: Bool = false
    @Published var currentExerciseIndex: Int = 0
    @Published var todaysWorkout: Workout?
    
    // MARK: - Streak Tracking
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var totalWorkoutsCompleted: Int = 0
    @Published var streakDates: [Date] = []
    
    @Published var badgeManager = BadgeManager()
    
    @Published var newBadges: [StreakBadge] = []
    
    private let shownWorkoutsKey = "shownWorkoutsKey"
    private let todaysDateKey = "todaysDateKey"
    
    init() {
        loadWorkoutsFromJSON()
        loadTodaysWorkout()
        loadStreakData()
    }
    
    // MARK: - Workout Loading
    func loadTodaysWorkout() {
        let today = formattedDate(Date())
        
        if let savedDate = UserDefaults.standard.string(forKey: todaysDateKey),
           let savedWorkoutName = UserDefaults.standard.string(forKey: "workoutFor_\(savedDate)"),
           savedDate == today {
            // If today's workout is already assigned, fetch it by NAME instead of UUID
            if let workout = workouts.first(where: { $0.name == savedWorkoutName }) {
                self.todaysWorkout = workout
                return
            }
        }
        
        // If not assigned yet, pick a new one
        assignNewWorkoutForToday()
    }
    
    private func assignNewWorkoutForToday() {
        var shownWorkoutNames = UserDefaults.standard.array(forKey: shownWorkoutsKey) as? [String] ?? []
        
        // Filter workouts that haven't been shown yet (by name, not UUID)
        let unshownWorkouts = workouts.filter { !shownWorkoutNames.contains($0.name) }
        
        if let newWorkout = unshownWorkouts.randomElement() {
            // Assign this workout
            todaysWorkout = newWorkout
            
            // Save the workout NAME for today (not UUID)
            let today = formattedDate(Date())
            UserDefaults.standard.set(today, forKey: todaysDateKey)
            UserDefaults.standard.set(newWorkout.name, forKey: "workoutFor_\(today)")
            
            // Update shown workouts list with names
            shownWorkoutNames.append(newWorkout.name)
            UserDefaults.standard.set(shownWorkoutNames, forKey: shownWorkoutsKey)
        } else {
            // All workouts have been shown
            print("All workouts have been shown. Resetting.")
            resetShownWorkouts()
            assignNewWorkoutForToday()
        }
    }
    
    private func resetShownWorkouts() {
        UserDefaults.standard.removeObject(forKey: shownWorkoutsKey)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func loadWorkoutsFromJSON() {
        guard let workouts = loadWorkoutsFromBundle() else {
            // If file loading fails, use sample data
            self.workouts = Workout.sampleWorkouts
            print("Failed to load JSON, using sample workouts")
            return
        }
        
        self.workouts = workouts
        print("Successfully loaded \(workouts.count) workouts from JSON")
    }
    
    private func loadWorkoutsFromBundle() -> [Workout]? {
        guard let url = Bundle.main.url(forResource: "test_workout_hold", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load test_workout_hold.json from bundle")
            return nil
        }
        
        do {
            // Create temporary struct that matches JSON structure exactly
            struct TempWorkout: Codable {
                let id: String
                let name: String
                let difficulty: String
                let durationMinutes: Int
                let restSeconds: Int
                let description: String
                let exercises: [TempExercise]
            }
            
            struct TempExercise: Codable {
                let name: String
                let reps: Int?
                let seconds: Int?
            }
            
            // Decode JSON to temporary structs
            let decoder = JSONDecoder()
            let tempWorkouts = try decoder.decode([TempWorkout].self, from: data)
            
            // Convert to your model objects with generated UUIDs
            var workouts: [Workout] = []
            
            for tempWorkout in tempWorkouts {
                // Parse the difficulty enum
                let difficultyEnum: WorkoutDifficulty
                switch tempWorkout.difficulty.lowercased() {
                case "easy":
                    difficultyEnum = .easy
                case "medium":
                    difficultyEnum = .medium
                case "hard":
                    difficultyEnum = .hard
                default:
                    difficultyEnum = .medium
                }
                
                // Convert exercises and add rest periods
                var exercisesList: [Exercise] = []
                
                for (index, tempExercise) in tempWorkout.exercises.enumerated() {
                    // Determine exercise type from name
                    let exerciseType: ExerciseType
                    switch tempExercise.name.lowercased() {
                    case "clamp":
                        exerciseType = .clamp
                    case "rapid fire":
                        exerciseType = .rapidFire
                    case "flash":
                        exerciseType = .flash
                    case "hold":
                        exerciseType = .hold
                    case "rest":
                        exerciseType = .rest
                    default:
                        // Default to matching name with type
                        if let matchingType = ExerciseType(rawValue: tempExercise.name.lowercased()) {
                            exerciseType = matchingType
                        } else {
                            exerciseType = .clamp // Default fallback
                        }
                    }
                    
                    // Create exercise with generated UUID
                    let exercise = Exercise(
                        id: UUID(),
                        name: tempExercise.name,
                        type: exerciseType,
                        description: getDescriptionForExercise(type: exerciseType),
                        reps: tempExercise.reps,
                        seconds: tempExercise.seconds
                    )
                    
                    exercisesList.append(exercise)
                }
                
                // Create workout with generated UUID
                let workout = Workout(
                    id: tempWorkout.id,
                    name: tempWorkout.name,
                    difficulty: difficultyEnum,
                    durationMinutes: tempWorkout.durationMinutes,
                    description: tempWorkout.description,
                    exercises: exercisesList,
                    restSeconds: tempWorkout.restSeconds
                )
                
                workouts.append(workout)
            }
            
            return workouts
        } catch {
            print("Error decoding workouts from JSON: \(error)")
            return nil
        }
    }
    
    // Helper function to get descriptions
    private func getDescriptionForExercise(type: ExerciseType) -> String {
        switch type {
        case .clamp:
            return "Slow and controlled contractions"
        case .rapidFire:
            return "Quick, rhythmic contractions"
        case .flash:
            return "Sharp, distinct contractions"
        case .hold:
            return "Sustained contraction"
        case .rest:
            return "Rest between exercises"
        }
    }
    
    // MARK: - Workout Management
    
//    func selectWorkout(_ workout: Workout) {
//        self.selectedWorkout = workout
//    }
    
    func startWorkout() {
        guard todaysWorkout != nil else { return }
        isWorkoutInProgress = true
        currentExerciseIndex = 0
    }
    
    func checkAndAwardBadges() {
        newBadges = badgeManager.checkAndAwardBadges(for: currentStreak)
        if !newBadges.isEmpty {
            handleNewlyEarnedBadges(newBadges)
        }
    }
    
    func handleNewlyEarnedBadges(_ badges: [StreakBadge]) {
        for badge in badges {
            print("🎉 Congratulations! You've earned the '\(badge.name)' badge!")
        }
    }
    
    func getNextBatchToUnlock() -> StreakBadge? {
        return badgeManager.nextBadgeToUnlock
    }
    
    func cancelWorkout() {
        isWorkoutInProgress = false
        currentExerciseIndex = 0
    }
    
    // MARK: - Workout Status
    
    func isWorkoutCompletedToday(_ workout: Workout) -> Bool {
        return WorkoutCompletionManager.isWorkoutCompletedToday(workoutName: workout.name)
    }
    
    // MARK: - Current Exercise Information
    
    var currentExercise: Exercise? {
        guard let workout = todaysWorkout,
              currentExerciseIndex < workout.exercises.count else {
            return nil
        }
        
        return workout.exercises[currentExerciseIndex]
    }
    
    var exerciseProgress: Double {
        guard let workout = todaysWorkout else { return 0.0 }
        return Double(currentExerciseIndex) / Double(workout.exercises.count)
    }
    
    var nextExerciseText: String {
        guard let workout = todaysWorkout,
              currentExerciseIndex < workout.exercises.count - 1 else {
            return "Complete Workout"
        }
        
        return "Next: \(workout.exercises[currentExerciseIndex + 1].name)"
    }
    
    // MARK: - Filtered Workouts
    
    func workoutsByDifficulty(_ difficulty: WorkoutDifficulty) -> [Workout] {
        return workouts.filter { $0.difficulty == difficulty }
    }
    
    // Load JSON from a string (for testing purposes)
    func loadWorkoutsFromString(jsonString: String) -> [Workout]? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Failed to convert JSON string to data")
            return nil
        }
        
        let decoder = JSONDecoder()
        
        do {
            let workouts = try decoder.decode([Workout].self, from: jsonData)
            self.workouts = workouts
            return workouts
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
    
    // MARK: - Streak Tracking
    private func loadStreakData() {
        streakDates = loadStreakDatesFromFile()
        calculateStreaks()
        totalWorkoutsCompleted = WorkoutCompletionManager.getCompletions().count
    }
    
    func updateStreakAfterWorkout() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Check if we already recorded today
        if !streakDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
            // Add today to streak dates
            streakDates.append(today)
            
            // Save updated streak data
            saveStreakDatesToFile()
            
            // Recalculate streaks
            calculateStreaks()
        }
        
        // Update total completed count
        totalWorkoutsCompleted = WorkoutCompletionManager.getCompletions().count
    }
    
    // Public method to refresh workout completion status
    func refreshWorkoutCompletionStatus() {
        // This will trigger UI updates for workout completion status
        objectWillChange.send()
    }
    
    private func calculateStreaks() {
        // Sort dates chronologically
        let sortedDates = streakDates.sorted()
        
        // Calculate current streak
        currentStreak = calculateCurrentStreak(from: sortedDates)
        
        // Calculate longest streak
        longestStreak = calculateLongestStreak(from: sortedDates)
    }
    
    private func calculateCurrentStreak(from dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Check if today or yesterday is in the streak
        let hasTodayOrYesterday = dates.contains(where: { 
            calendar.isDate($0, inSameDayAs: today) || 
            calendar.isDate($0, inSameDayAs: yesterday) 
        })
        
        if !hasTodayOrYesterday {
            return 0 // Streak broken if neither today nor yesterday is present
        }
        
        // Count consecutive days backwards from today/yesterday
        var currentDate = today
        var streak = 0
        
        // Check if today is in the streak
        if dates.contains(where: { calendar.isDate($0, inSameDayAs: today) }) {
            streak = 1
            currentDate = yesterday
        } else {
            // Start from yesterday
            currentDate = yesterday
        }
        
        // Count backwards
        while true {
            if dates.contains(where: { calendar.isDate($0, inSameDayAs: currentDate) }) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func calculateLongestStreak(from dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var longestStreak = 1
        var currentStreak = 1
        
        for i in 1..<dates.count {
            let previousDate = dates[i-1]
            let currentDate = dates[i]
            
            let daysBetween = calendar.dateComponents([.day], from: previousDate, to: currentDate).day ?? 0
            
            if daysBetween == 1 {
                // Consecutive days
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else if daysBetween > 1 {
                // Streak broken
                currentStreak = 1
            }
        }
        
        return longestStreak
    }
    
    private var streakDatesFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("workout_streak_dates.json")
    }
    
    private func saveStreakDatesToFile() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(streakDates)
            try data.write(to: streakDatesFileURL, options: [.atomicWrite])
            print("Successfully saved \(streakDates.count) streak dates")
        } catch {
            print("Error saving streak dates: \(error)")
        }
    }
    
    private func loadStreakDatesFromFile() -> [Date] {
        guard FileManager.default.fileExists(atPath: streakDatesFileURL.path) else {
            print("Streak dates file not found, starting fresh.")
            return []
        }
        
        do {
            let data = try Data(contentsOf: streakDatesFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let dates = try decoder.decode([Date].self, from: data)
            print("Successfully loaded \(dates.count) streak dates")
            return dates
        } catch {
            print("Error loading or decoding streak dates: \(error)")
            return []
        }
    }
}

// Extension with test/debugging methods
extension WorkoutViewModel {
    // For debugging: print workout details
    func printWorkoutDetails() {
        for workout in workouts {
            print("Workout: \(workout.name)")
            print("- Difficulty: \(workout.difficulty.description)")
            print("- Duration: \(workout.durationMinutes) minutes")
            print("- Rest between exercises: \(workout.restSeconds) seconds")
            print("- Total exercises: \(workout.exercises.count)")
            
            for (index, exercise) in workout.exercises.enumerated() {
                print("  Exercise \(index + 1): \(exercise.name) (\(exercise.type.rawValue))")
                if let reps = exercise.reps {
                    print("  - Repetitions: \(reps)")
                }
                if let seconds = exercise.seconds {
                    print("  - Duration: \(seconds) seconds")
                }
            }
            print("")
        }
    }
    
    func createStreakStub() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var testStreakDates: [Date] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            testStreakDates.append(date)
        }
        
        testStreakDates.sort()
        
        self.streakDates = testStreakDates
        
        calculateStreaks()
        saveStreakDatesToFile()
    }
}
