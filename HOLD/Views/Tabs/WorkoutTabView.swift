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
                    
                    if !workoutViewModel.workouts.isEmpty {
                        TabView(selection: $selectedWorkoutIndex) {
                            ForEach(0..<workoutViewModel.workouts.count, id: \.self) { index in
                                workoutCard(workout: workoutViewModel.workouts[index])
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
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
            .onAppear {
                workoutViewModel.loadWorkoutsFromJSON()
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
                
                Circle()
                    .fill(difficultyColor(workout.difficulty))
                    .frame(height: 88)
                    .overlay(
                        Image(systemName: difficultyIcon(workout.difficulty))
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    )
                
                Text(workoutViewModel.isWorkoutCompletedToday(workout) ? 
                     "Status: Completed Today" : "Status: Not Completed")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("**Difficulty:** \(workout.difficulty.description)")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                
                Text("**Duration:** \(workout.durationMinutes) minutes")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                
                Text("**Description:** \(workout.description)")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
               
            }
            .padding(.horizontal)
            
            Button(action: {
                workoutViewModel.selectWorkout(workout)
                navigationManager.push(to: .workoutView)
//                flowManager.isShowingWorkoutView = true
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
        .background(Color(hex: "#161616").opacity(0.4))
        .cornerRadius(20)
    }
    
    func difficultyColor(_ difficulty: WorkoutDifficulty) -> Color {
        switch difficulty {
        case .easy:
            return Color.green
        case .medium:
            return Color.orange
        case .hard:
            return Color.red
        }
    }
    
    func difficultyIcon(_ difficulty: WorkoutDifficulty) -> String {
        switch difficulty {
        case .easy:
            return "figure.walk"
        case .medium:
            return "figure.run"
        case .hard:
            return "flame.fill"
        }
    }
    
    var streakView: some View {
        VStack(alignment:.leading, spacing: 23) {
            VStack(alignment:.leading, spacing: 0) {
                Text("Keep Going!")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("You're on a 12-day streak!")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                
            }
            .padding(.leading)
            
            // Week Streak View
            HStack() {
                Spacer()
                let completedDays = [true, false, true, false, true, false, false]
                let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sut"]
                
                ForEach(0..<7) { index in
                    DayCircleView(day: daysOfWeek[index], isCompleted: completedDays[index])
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
}

struct DayCircleView: View {
    let day: String
    let isCompleted: Bool

    var body: some View {
        VStack(spacing: 5) {
            

            if isCompleted {
                // Filled circle/icon for completed days
                Image(systemName: "checkmark.circle.fill") // Using a checkmark icon
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(hex: "#FF1919")) // Your accent color
            } else {
                // Outline circle for incomplete days
                Circle()
//                    .strokeBorder(Color.gray, lineWidth: 1.5)
                    .foregroundStyle(Color(hex: "#606060")) // Ensure transparent background
                    .frame(width: 30, height: 30)
            }
            Text(day)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    WorkoutTabView()
        .environmentObject(TabManager())
}
