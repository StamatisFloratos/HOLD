import SwiftUI

struct WorkoutView: View {
    @State private var showWorkoutDetail = false
    @State private var showWorkoutFinish = false
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @State private var showWorkoutSheet: Bool = true
    var selectedWorkout: Workout
    
    var onBack: () -> Void
    
    var body: some View {
        ZStack {
            AppBackground()
            
            if showWorkoutSheet {
                WorkoutSheetView(onBack: {
                    withAnimation {
                        showWorkoutSheet = false
                        showWorkoutDetail = true
                    }
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                .zIndex(0)
            }
            
            if showWorkoutDetail {
                WorkoutDetailView(selectedWorkout: selectedWorkout, onBack: {
                    withAnimation {
                        onBack()
                    }
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                .zIndex(1)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    let workout = Workout(id: "workout_detail", name: "Workout Detail", difficulty: .easy, durationMinutes: 5, description: "", exercises: [], restSeconds: 30)
    WorkoutView(selectedWorkout: workout, onBack: {})
        .environmentObject(ProgressViewModel())
} 
