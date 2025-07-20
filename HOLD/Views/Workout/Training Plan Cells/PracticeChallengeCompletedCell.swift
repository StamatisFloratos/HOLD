//
//  PracticeChallengeCompletedCell.swift
//  HOLD
//
//  Created by Muhammad Ali on 13/07/2025.
//

import SwiftUI

struct PracticeChallengeCompletedCell: View {
    let day: TrainingDay
    let workout: Workout
    let onMeasure: () -> Void
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image("OrangeDot")
                        .frame(width: 13, height: 13)
                    Text("Practice")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                Text("The Challenge")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(LinearGradient(
                    colors: [
                        Color(hex:"#FF5E00"),
                        Color(hex:"#993800")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .padding(.horizontal)
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color(hex: "#242E3A"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 0.5))
    }
}

#if DEBUG
struct PracticeChallengeCompletedCell_Previews: PreviewProvider {
    static var previews: some View {
        let mockWorkout = Workout(
            id: "the_challenge",
            name: "The Challenge",
            difficulty: .medium,
            durationMinutes: 10,
            description: "Practice challenge.",
            exercises: [],
            restSeconds: 30
        )
        let mockDay = TrainingDay(
            dayIndex: 5,
            workoutId: "the_challenge",
            showPracticeMeasurement: false,
            showPracticeChallenge: true
        )
        PracticeChallengeCompletedCell(day: mockDay, workout: mockWorkout, onMeasure: {})
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
}
#endif
