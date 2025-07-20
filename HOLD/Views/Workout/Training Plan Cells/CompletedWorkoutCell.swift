//
//  CompletedWorkoutCell.swift
//  HOLD
//
//  Created by Muhammad Ali on 08/07/2025.
//

import SwiftUI

struct CompletedWorkoutCell: View {
    let day: TrainingDay
    let workout: Workout
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Completed Workout")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#16D700"))
                Text(workout.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            Spacer()
            Image(systemName: "checkmark.circle")
                .padding(.trailing)
                .font(.system(size: 32))
                .foregroundColor(Color(hex: "#06A800"))
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color.black.opacity(0.7))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "#16D700"), lineWidth: 0.5))
    }
}

#if DEBUG
struct CompletedWorkoutCell_Previews: PreviewProvider {
    static var previews: some View {
        let mockWorkout = Workout(
            id: "kegel_max",
            name: "Kegel Max",
            difficulty: .hard,
            durationMinutes: 15,
            description: "Completed workout.",
            exercises: [],
            restSeconds: 30
        )
        let mockDay = TrainingDay(
            dayIndex: 3,
            workoutId: "kegel_max",
            showPracticeMeasurement: false,
            showPracticeChallenge: false
        )
        CompletedWorkoutCell(day: mockDay, workout: mockWorkout)
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
}
#endif
