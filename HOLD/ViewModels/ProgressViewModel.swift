//
//  ProgressViewModel.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import Foundation
import Combine // Needed for ObservableObject

// --- Helper Date Extensions (Add outside the class or in a separate file) ---
extension Date {
    // Get the start of the week (Sunday or Monday) for a given date
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }

    // Get the previous week's start date (e.g., last Monday)
    func startOfPreviousWeek(using calendar: Calendar = .current) -> Date {
        let currentWeekStart = self.startOfWeek(using: calendar)
        return calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart)!
    }

    // Get date by adding days
    func addingDays(_ days: Int, using calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: days, to: self)!
    }
}


// --- ViewModel ---
class ProgressViewModel: ObservableObject {

    @Published var chartData: [Double?] = Array(repeating: nil, count: 7) // Mon-Sun durations (seconds)
    @Published var weekDateRange: String = ""
    @Published var allTimeBest: Double? = nil
    @Published var weeklyBest: Double? = nil

    let daysOfWeekLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    // Placeholder for your actual measurement data store
    // In a real app, this would come from CoreData, Realm, a Service, etc.
    private var allMeasurements: [Measurement] = []
    struct DailyDuration: Identifiable {
        let id = UUID() // Make it identifiable for ForEach
        let day: String // Mon, Tue, etc.
        let duration: Double? // Keep it optional
    }

    // Computed property to transform data for the chart view
    var chartDisplayData: [DailyDuration] {
        // Zip the labels and data together, handling potential mismatch
        let count = min(daysOfWeekLabels.count, chartData.count)
        return (0..<count).map { index in
            DailyDuration(day: daysOfWeekLabels[index], duration: chartData[index])
        }
    }

    init() {
        // Load initial data when the ViewModel is created
        loadData()
    }
    
    // Inside ProgressViewModel class

    func measurementDidFinish(duration: Double) {
        print("ViewModel received finished measurement: \(duration) seconds.")

        let today = Calendar.current.startOfDay(for: Date())

        // Check if there's already a measurement for today
        if let index = allMeasurements.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }) {
            // Update the existing measurement's duration
            allMeasurements[index].durationSeconds += duration
            print("Updated existing measurement for today. New duration: \(allMeasurements[index].durationSeconds) seconds.")
        } else {
            // Create new measurement if no entry exists for today
            let newMeasurement = Measurement(id: UUID(), date: today, durationSeconds: duration)
            allMeasurements.append(newMeasurement)
            print("Appended new measurement. Total measurements in memory: \(allMeasurements.count)")
        }

        // Save updated measurements
        saveMeasurementsToFile()

        // Process updated data
        processLatestWeekData()
        print("ViewModel data processing complete after new measurement.")
    }


    // --- Public method to call when new data is available ---
    func loadData() {
        // 1. Simulate fetching all historical measurements
        fetchMeasurements() // Replace with your actual data fetching

        // 2. Process data for the most recent *completed* week
        processLatestWeekData()
    }

    // --- Simulation of fetching data ---
    private func fetchMeasurements() {
        print("Loading measurements from file...")
        self.allMeasurements = loadMeasurementsFromFile()
        // No need to print count here, loadMeasurementsFromFile does it
    }

    // --- Process data for the chart ---
    private func processLatestWeekData() {
        let calendar = Calendar.current
        let today = Date()

        // Calculate Start of Current Week (Monday)
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2 // Monday
        let startOfTargetWeek = calendar.date(from: components)!

        // Filter measurements for the current week (Monday up to Today inclusive)
        let measurementsThisWeek = allMeasurements.filter { measurement in
            let measurementDayStart = calendar.startOfDay(for: measurement.date)
            let todayEnd = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: today))!
            return measurementDayStart >= startOfTargetWeek && measurement.date < todayEnd
        }
        print("Found \(measurementsThisWeek.count) measurements for the current week starting \(startOfTargetWeek)")


        // Prepare chart data array (Mon=0, ..., Sun=6) - Initialize with 0.0 for summing
        var weeklyDurations: [Double] = Array(repeating: 0.0, count: 7) // Use 0.0 for summing

        // Track the best *single* measurement duration within this week
        var currentWeeklyBestSession: Double = 0.0

        for measurement in measurementsThisWeek {
            let weekday = calendar.component(.weekday, from: measurement.date)
            // Adjust weekday: Sunday (1) -> index 6, Monday (2) -> index 0, etc.
            let index = (weekday + 5) % 7
            if index >= 0 && index < 7 {
                // --- Sum the durations for the day ---
                weeklyDurations[index] += measurement.durationSeconds
                // --- End Summing ---

                // --- Update the best single session for the week ---
                currentWeeklyBestSession = max(currentWeeklyBestSession, measurement.durationSeconds)
                // --- End Best Session Update ---
            }
        }

        // Calculate all-time best (based on single sessions)
        let currentAllTimeBest = allMeasurements.map { $0.durationSeconds }.max()

        // Format the date range string (remains the same - shows Mon-Sun)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM"
        let startDateString = dateFormatter.string(from: startOfTargetWeek)
        let endOfWeekDisplayDate = calendar.date(byAdding: .day, value: 6, to: startOfTargetWeek)!
        dateFormatter.dateFormat = "d MMM yyyy"
        let endDateString = dateFormatter.string(from: endOfWeekDisplayDate)
        let weekRangeStr = "\(startDateString) - \(endDateString)"

        // Update published properties on the main thread
        DispatchQueue.main.async {
            // Convert 0.0 back to nil for days with no measurements for chart display? Optional.
            // If you want bars to only appear if there was a measurement:
            self.chartData = weeklyDurations.map { $0 > 0 ? $0 : nil }
            // If you want 0-height bars for days with 0 total duration:
            // self.chartData = weeklyDurations

            self.weekDateRange = weekRangeStr
            self.allTimeBest = currentAllTimeBest
            self.weeklyBest = currentWeeklyBestSession > 0 ? currentWeeklyBestSession : nil // Weekly best is the best SINGLE session
            print("Chart data updated (summed daily): \(self.chartData)")
            print("Weekly Best Session: \(self.weeklyBest ?? 0.0)")
        }
    }
    
    private var measurementsFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("measurements.json")
    }

    // Function to save measurements to the JSON file
    private func saveMeasurementsToFile() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // Makes the file readable

        do {
            // Encode the current in-memory measurements
            let data = try encoder.encode(allMeasurements)
            // Write the data to the file URL
            try data.write(to: measurementsFileURL, options: [.atomicWrite]) // atomicWrite ensures integrity
            print("Successfully saved \(allMeasurements.count) measurements to \(measurementsFileURL.lastPathComponent)")
        } catch {
            print("Error saving measurements: \(error)")
        }
    }

    // Function to load measurements from the JSON file
    private func loadMeasurementsFromFile() -> [Measurement] {
        // Check if the file exists
        guard FileManager.default.fileExists(atPath: measurementsFileURL.path) else {
            print("Measurements file not found, starting fresh.")
            return [] // Return empty array if file doesn't exist
        }

        do {
            // Read the data from the file
            let data = try Data(contentsOf: measurementsFileURL)
            // Decode the data into an array of Measurement objects
            let decoder = JSONDecoder()
            let loadedMeasurements = try decoder.decode([Measurement].self, from: data)
            print("Successfully loaded \(loadedMeasurements.count) measurements from \(measurementsFileURL.lastPathComponent)")
            return loadedMeasurements
        } catch {
            print("Error loading or decoding measurements: \(error)")
            return [] // Return empty array on error
        }
    }
    // --- End Persistence Helpers ---
    
    
}
