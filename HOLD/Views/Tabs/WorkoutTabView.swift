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
    @State private var selectedWorkoutIndex = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex:"#10171F"),
                    Color(hex:"#466085")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    Text("Workouts")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if let todaysWorkout = workoutViewModel.todaysWorkout {
                        workoutCard(workout: todaysWorkout)
                            .frame(height: 500)
                    } else {
                        Text("No workouts available")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(hex: "#161616").opacity(0.4))
                            .cornerRadius(20)
                    }
                    
                    streakView
                    
                }
                .padding(.horizontal)                
                Spacer(minLength: 80) // Space for tab bar
            }
        }
        .navigationBarHidden(true)
    }
    
    func workoutCard(workout: Workout) -> some View {
        VStack(spacing: 36) {
            VStack(spacing: 20) {
                Text(workout.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                if workoutViewModel.isWorkoutCompletedToday(workout) {
                    Image(systemName: "checkmark.circle.fill") // Using a checkmark icon
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
                } else {
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 88,height: 88)
                }
                
                
                Text(workoutViewModel.isWorkoutCompletedToday(workout) ?
                     "Status: Completed Today" : "Status: Not Completed")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("**Difficulty:**")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                    Text("\(workout.difficulty.description)")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(LinearGradient(
                            colors: [
                                Color(hex:"#14C101"),
                                Color(hex:"#0E8601")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                }
                
                Text("**Duration:** \(workout.durationMinutes) minutes")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                
                Text("**Description:** \(workout.description)")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                
            }
            .padding(.horizontal)
            
            Button(action: {
                navigationManager.push(to: .workoutView)
            }) {
                Text("Start Workout")
                    .font(.system(size: 16, weight: .semibold))
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 47)
                    .background(Color(hex: "#FF1919"))
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }
            .padding(.horizontal, 50)
            .padding(.bottom, 15)
        }
        .padding(.vertical)
        .background(Color(hex: "#000000").opacity(0.4))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                .cornerRadius(12)
        )
    }
    
    var streakView: some View {
        VStack(alignment:.leading, spacing: 23) {
            VStack(alignment:.leading, spacing: 0) {
                Text("Keep Going!")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("You're on a \(workoutViewModel.longestStreak) day streak!")
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
        .background(Color(hex: "#161616").opacity(0.4))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 1)
                .cornerRadius(12)
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
}
