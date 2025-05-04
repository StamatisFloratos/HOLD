
import SwiftUI

struct MeasurementView: View {
    @State private var showMeasurementActivity = false
    @State private var showMeasurementComplete = false
    @State private var elapsedTime: TimeInterval = 0
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var showMeasurementSheet: Bool = true
    
    var onBack: () -> Void
    
    var body: some View {
        ZStack {
            AppBackground()
            
            if showMeasurementSheet {
                MeasurementSheetView(onBack: {
                    showMeasurementSheet = false
                    showMeasurementActivity = true
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
                        showMeasurementActivity = false
                        showMeasurementComplete = true
                    }
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                .zIndex(1)
            }
            
            if showMeasurementComplete {
                MeasurementCompletionView(totalElapsedTime: elapsedTime, onBack: {
                    withAnimation {
                        showMeasurementComplete = false
                        onBack()
                    }
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
                .zIndex(2)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    MeasurementView(onBack: {})
        .environmentObject(ProgressViewModel())
} 
