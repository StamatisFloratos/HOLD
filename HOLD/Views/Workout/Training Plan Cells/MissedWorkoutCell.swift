//
//  MissedWorkoutCell.swift
//  HOLD
//
//  Created by Muhammad Ali on 08/07/2025.
//

import SwiftUI

struct MissedWorkoutCell: View {
    let day: TrainingDay
    let workout: Workout
    let onStart: () -> Void
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Missed Workout")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                Text(workout.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            Spacer()
            Button(action: onStart) {
                Text("Start Workout")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 100, height: 35)
                    .background(Color(hex: "#AB0000"))
                    .cornerRadius(30)
            }
            .frame(width: 100, height: 35)
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color.black.opacity(0.7))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.2), lineWidth: 0.5))
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

#if DEBUG
struct MissedWorkoutCell_Previews: PreviewProvider {
    static var previews: some View {
        let mockWorkout = Workout(
            id: "kegel_forge",
            name: "Kegel Forge",
            difficulty: .easy,
            durationMinutes: 5,
            description: "Missed workout.",
            exercises: [],
            restSeconds: 30
        )
        let mockDay = TrainingDay(
            dayIndex: 1,
            workoutId: "kegel_forge",
            showPracticeMeasurement: false,
            showPracticeChallenge: false
        )
        MissedWorkoutCell(day: mockDay, workout: mockWorkout, onStart: {})
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
}
#endif
