import SwiftUI

struct WeeklyUpdateStats {
    let workoutsCompletedThisWeek: Int
    let currentStreak: Int
    let workoutMinutesThisWeek: Int
}

struct WeeklyUpdateView: View {
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    
    let stats: WeeklyUpdateData
    let challengeProgress: ProgressBarModel
    let muscleProgress: ProgressBarModel
    
    var onBack: () -> Void
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        triggerHaptic()
                        onBack()
                    } label: {
                        Image("crossIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 21)
                    }
                    .padding(.trailing, 26)
                }
                .padding(.top, 20)
                
                Spacer()
                
                Text("Weekly Update")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Stats")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        Spacer()
                        StatCardView(title: "\(stats.workoutsCompleted)", subtitle: "Workouts\nCompleted")
                        StatCardView(title: "\(workoutViewModel.currentStreak)", subtitle: "Current\nStreak")
                        StatCardView(title: "\(stats.workoutMinutes) mins", subtitle: "Workout\nTime")
                        Spacer()
                    }
                    .padding(.vertical, 18)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Progress")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    VStack(spacing: 20) {
                        ProgressBarCardView(title: "The Challenge", progressBarModel: challengeProgress)
                        ProgressBarCardView(title: "Muscle Progress", progressBarModel: muscleProgress)
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Overview")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top, 12)
                        .padding(.horizontal, 16)
                    
                    if challengeProgress.hasProgress && muscleProgress.hasProgress {
                        Text("Consistency is key. You are showing clear progress and you seem on track to meet your goal of lasting **\(UserStorage.wantToLastTime)**. Stay focused and keep working. Results speak for themselves.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                            .padding(.bottom, 16)
                            .padding(.horizontal, 16)
                    } else {
                        Text("Measuring your progress is important to know where you stand. Remember your goal is to last **\(UserStorage.wantToLastTime)**. Stay focused and keep working. Results will speak for themselves.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                            .padding(.bottom, 16)
                            .padding(.horizontal, 16)
                    }
                }
                .background(Color(red: 0.18, green: 0.18, blue: 0.18))
                .cornerRadius(10)
                
                Spacer()
            }
            .padding(.horizontal, 40)
        }
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct StatCardView: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            Text(title)
                .font(.system(size: 22, weight: .black))
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.bottom, 18)
                .padding(.top, 10)
        }
        .frame(width: 100, height: 120)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#FF1919"),
                    Color(hex: "#990F0F")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .inset(by: 0.25)
                .stroke(.white, lineWidth: 0.5)
            
        )
    }
}

struct ProgressBarCardView: View {
    let title: String
    let progressBarModel: ProgressBarModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                Text("\(progressLabel)")
                    .font(progressLabelFont)
                    .foregroundColor(progressLabelColor)
            }
            
            WeeklyUpdateProgressBarView(currentPercent: calculateCurrentPercentage(), previousPercent: calculatePreviousPercentage(), isMax: progressBarModel.isMax)
                .frame(height: 10)
                .cornerRadius(5)
        }
        .frame(height: 70)
        .padding(12)
        .background(Color(red: 0.08, green: 0.08, blue: 0.08))
        .cornerRadius(13)
        .overlay(
            RoundedRectangle(cornerRadius: 13)
                .inset(by: 0.25)
                .stroke(.white, lineWidth: 0.5)
            
        )
    }
    
    private var progressLabel: String {
        return progressBarModel.displayText
    }
    
    private var progressLabelColor: Color {
        if progressBarModel.isMax {
            return Color(hex: "#0CFF00")
        } else {
            if progressBarModel.hasProgress {
                return Color(hex: "#0CFF00")
            } else {
                return Color.white.opacity(0.7)
            }
        }
    }
    
    private var progressLabelFont: Font {
        if progressBarModel.isMax {
            return Font.system(size: 20, weight: .medium)
        } else {
            if progressBarModel.hasProgress {
                return Font.system(size: 20, weight: .medium)
            } else {
                return Font.system(size: 12, weight: .medium)
            }
        }
    }
    
    func calculateCurrentPercentage() -> Double {
        if progressBarModel.isMax {
            return 0
        } else {
            if progressBarModel.hasProgress {
                return progressBarModel.currentPercentage
            } else {
                return progressBarModel.previousPercentage
            }
        }
    }
    
    func calculatePreviousPercentage() -> Double {
        if progressBarModel.isMax {
            return 100
        } else {
            if progressBarModel.hasProgress {
                return progressBarModel.previousPercentage
            } else {
                return progressBarModel.previousPercentage
            }
        }
    }
}

struct WeeklyUpdateProgressBarView: View {
    let currentPercent: Double
    let previousPercent: Double
    let isMax: Bool
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(hex: "#AFAFAF"))
                
                if isMax {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(hex: "#079700"))
                        .frame(width: geo.size.width * 100)
                } else {
                    if currentPercent > previousPercent {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(hex: "#0CFF00"))
                            .frame(width: geo.size.width * CGFloat(currentPercent / 100))
                    }
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(hex: "#079700"))
                        .frame(width: geo.size.width * CGFloat(min(previousPercent, currentPercent) / 100))
                }
            }
        }
    }
}

#Preview {
    WeeklyUpdateView(
        stats: WeeklyUpdateData(weekNumber: 1, weekStartDate: Date().addingDays(-6), weekEndDate: Date(), workoutsCompleted: 5, totalWorkoutsInWeek: 7, workoutMinutes: 30, challengeProgress: ProgressBarModel(currentPercentage: 50, previousPercentage: 50, hasProgress: false, isMax: false, displayText: "No Progress"), muscleProgress: ProgressBarModel(currentPercentage: 20, previousPercentage: 10, hasProgress: true, isMax: false, displayText: "+2min 30sec")),
        challengeProgress: ProgressBarModel(currentPercentage: 50, previousPercentage: 50, hasProgress: false, isMax: false, displayText: "No Progress"),
        muscleProgress: ProgressBarModel(currentPercentage: 20, previousPercentage: 10, hasProgress: true, isMax: false, displayText: "+2min 30sec"), onBack: {}
    )
    .environmentObject(WorkoutViewModel())
}
