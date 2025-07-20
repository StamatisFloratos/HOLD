//
//  TodayWorkoutCell.swift
//  HOLD
//
//  Created by Muhammad Ali on 08/07/2025.
//

import SwiftUI

struct TodayWorkoutCell: View {
    let day: TrainingDay
    let workout: Workout
    let onStart: () -> Void
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Image("RedDot")
                        .frame(width: 13, height: 13)
                    Text("Workout")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                Text(workout.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.bottom, 2)
                Text(workout.difficulty.descriptionSimple)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(LinearGradient(
                        colors: workout.difficulty.color,
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
            }
            Spacer()
            Button(action: onStart) {
                Text("Start Workout")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 100, height: 35)
                    .background(Color(red: 1, green: 0.1, blue: 0.1))
                    .cornerRadius(30)
            }
            .frame(width: 100, height: 35)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(hex: "#242E3A"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 0.5))
    }
}

#if DEBUG
struct TodayWorkoutCell_Previews: PreviewProvider {
    static var previews: some View {
        let mockWorkout = Workout(
            id: "kegel_forge",
            name: "Kegel Forge",
            difficulty: .easy,
            durationMinutes: 5,
            description: "Lay the foundation for a stronger core.",
            exercises: [],
            restSeconds: 30
        )
        let mockDay = TrainingDay(
            dayIndex: 1,
            workoutId: "kegel_forge",
            showPracticeMeasurement: false,
            showPracticeChallenge: false
        )
        TodayWorkoutCell(day: mockDay, workout: mockWorkout, onStart: {})
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
}
#endif
