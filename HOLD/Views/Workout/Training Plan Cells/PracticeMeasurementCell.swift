//
//  PracticeMeasurementCell.swift
//  HOLD
//
//  Created by Muhammad Ali on 08/07/2025.
//

import SwiftUI

struct PracticeMeasurementCell: View {
    let day: TrainingDay
    let workout: Workout
    let onMeasure: () -> Void
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image("BlueDot")
                        .frame(width: 13, height: 13)
                    Text("Progress Tracking")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                Text("HOLD Measurement")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            Spacer()
            Button(action: onMeasure) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle").foregroundColor(.white)
                        .font(.system(size: 14, weight: .regular))
                    Text("Measure")
                        .font(.system(size: 12, weight: .medium))
                }
                .frame(width: 100, height: 35)
                .background(Color(hex: "#19A7FF"))
                .foregroundColor(.white)
                .cornerRadius(30)
            }
            .frame(width: 100, height: 35)
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color(hex: "#242E3A"))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 0.5))
    }
}

#if DEBUG
struct PracticeMeasurementCell_Previews: PreviewProvider {
    static var previews: some View {
        let mockWorkout = Workout(
            id: "hold_measurement",
            name: "HOLD Measurement",
            difficulty: .easy,
            durationMinutes: 5,
            description: "Progress tracking measurement.",
            exercises: [],
            restSeconds: 30
        )
        let mockDay = TrainingDay(
            dayIndex: 4,
            workoutId: "hold_measurement",
            showPracticeMeasurement: true,
            showPracticeChallenge: false
        )
        PracticeMeasurementCell(day: mockDay, workout: mockWorkout, onMeasure: {})
            .background(Color.black)
            .previewLayout(.sizeThatFits)
    }
}
#endif
