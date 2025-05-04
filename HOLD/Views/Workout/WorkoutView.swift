import SwiftUI

struct WorkoutView: View {
    @State private var showWorkoutDetail = false
    @State private var showWorkoutFinish = false
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @State private var showWorkoutSheet: Bool = true
    
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
                .transition(.move(edge: .trailing))
                .zIndex(0)
            }
            
            if showWorkoutDetail {
                if let selectedWorkout = workoutViewModel.todaysWorkout {
                    WorkoutDetailView(selectedWorkout: selectedWorkout, onBack: {
                        withAnimation {
                            showWorkoutDetail = false
                            showWorkoutFinish = true
                        }
                    })
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
                }
            }
            
            if showWorkoutFinish {
                WorkoutFinishView(onBack: {
                    withAnimation {
                        showWorkoutFinish = false
                        onBack()
                    }
                })
                .transition(.move(edge: .trailing))
                .zIndex(2)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    WorkoutView(onBack: {})
        .environmentObject(ProgressViewModel())
} 
