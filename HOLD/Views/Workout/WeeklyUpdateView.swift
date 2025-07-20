import SwiftUI

struct WeeklyUpdateStats {
    let workoutsCompletedThisWeek: Int
    let currentStreak: Int
    let workoutMinutesThisWeek: Int
}

struct WeeklyUpdateView: View {
    let stats: WeeklyUpdateStats
    let challengeProgress: (current: Double, previous: Double)
    let muscleProgress: (current: Double, previous: Double)
    
    var onBack: () -> Void
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
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
                        StatCardView(title: "\(stats.workoutsCompletedThisWeek)", subtitle: "Workouts\nCompleted")
                        StatCardView(title: "\(stats.currentStreak)", subtitle: "Current\nStreak")
                        StatCardView(title: "\(stats.workoutMinutesThisWeek) mins", subtitle: "Workout\nTime")
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
                        ProgressBarCardView(title: "The Challenge", currentPercent: challengeProgress.current, previousPercent: challengeProgress.previous)
                        ProgressBarCardView(title: "Muscle Progress", currentPercent: muscleProgress.current, previousPercent: muscleProgress.previous)
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
                    
                    Text("Consistency is key. You are showing clear progress and you seem on track to meet your goal of lasting **\(UserStorage.wantToLastTime)**. Stay focused and keep working. Results speak for themselves.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                        .padding(.bottom, 16)
                        .padding(.horizontal, 16)
                }
                .background(Color(red: 0.18, green: 0.18, blue: 0.18))
                .cornerRadius(10)
                
                Spacer()
            }
            .padding(.horizontal, 40)
        }
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
    let currentPercent: Double
    let previousPercent: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                Text("\(progressLabel)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(progressLabelColor)
            }
            
            WeeklyUpdateProgressBarView(currentPercent: currentPercent, previousPercent: previousPercent)
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
        if currentPercent == 0 {
            return "no measurement"
        } else if currentPercent == previousPercent {
            return "no progress"
        } else {
            let diff = currentPercent - previousPercent
            let sign = diff > 0 ? "+" : ""
            return "\(sign)\(Int(diff))%"
        }
    }
    private var progressLabelColor: Color {
        if currentPercent == 0 || currentPercent == previousPercent {
            return Color.white.opacity(0.7)
        } else {
            return Color(hex: "#0CFF00")
        }
    }
}

struct WeeklyUpdateProgressBarView: View {
    let currentPercent: Double
    let previousPercent: Double
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(hex: "#AFAFAF"))
                if currentPercent > 0 {
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
        stats: WeeklyUpdateStats(workoutsCompletedThisWeek: 7, currentStreak: 21, workoutMinutesThisWeek: 45),
        challengeProgress: (current: 32, previous: 25),
        muscleProgress: (current: 60, previous: 40), onBack: {}
    )
} 
