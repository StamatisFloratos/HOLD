
import SwiftUI

struct MeasurementView: View {
    @State private var showMeasurementActivity = false
    @State private var elapsedTime: TimeInterval = 0
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var showMeasurementSheet: Bool = true
    
    var onBack: (Double) -> Void
    
    var body: some View {
        ZStack {
            AppBackground()
            
            if showMeasurementSheet {
                MeasurementSheetView(onBack: {
                    withAnimation {
                        showMeasurementSheet = false
                        showMeasurementActivity = true
                    }
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                .zIndex(0)
            }
            
            if showMeasurementActivity {
                MeasurementActivityView(onBack: { time in
                    elapsedTime = time
                    withAnimation {
                        progressViewModel.measurementDidFinish(duration: elapsedTime)
                        showMeasurementActivity = false
                        onBack(elapsedTime)
                    }
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                .environmentObject(progressViewModel)
                .zIndex(1)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    MeasurementView(onBack: { _ in })
        .environmentObject(ProgressViewModel())
} 
