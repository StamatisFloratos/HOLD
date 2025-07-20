//
//  FutureWorkoutCell.swift
//  HOLD
//
//  Created by Muhammad Ali on 08/07/2025.
//

import SwiftUI

struct FutureWorkoutCell: View {
    let day: TrainingDay
    let workout: Workout
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Upcoming Workout")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                Text(workout.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            Spacer()
            Image(systemName: "lock.fill")
                .padding(.trailing)
                .font(.system(size: 24))
                .foregroundColor(.white)
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color.black.opacity(0.7))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.2), lineWidth: 0.5))
    }
}

#if DEBUG
struct FutureWorkoutCell_Previews: PreviewProvider {
    static var previews: some View {
        let mockWorkout = Workout(
            id: "control_power",
            name: "Control Power",
            difficulty: .medium,
            durationMinutes: 10,
            description: "Upcoming workout for control.",
            exercises: [],
            restSeconds: 30
        )
        let mockDay = TrainingDay(
            dayIndex: 2,
            workoutId: "control_power",
            showPracticeMeasurement: false,
            showPracticeChallenge: false
        )
        FutureWorkoutCell(day: mockDay, workout: mockWorkout)
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
}
#endif
