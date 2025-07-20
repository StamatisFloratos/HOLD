import SwiftUI

struct TrainingPlanCardModal: View {
    let planName: String
    let daysLeft: Int
    let percentComplete: Int
    let progress: Double
    let image: String?
    let height: CGFloat
    let completed: Bool
    let onTap: () -> Void
    
    @State private var animatedProgress: Double = 0.0
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                ZStack(alignment: .center) {
                    if let imageName = image {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width - 60, height: height)
                            .clipped()
                    } else {
                        Color.gray.frame(height: height)
                    }
                    VStack(alignment: .center, spacing: 0) {
                        Text(planName)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.top, 16)
                            .padding(.horizontal, 16)
                        if completed {
                            Text("Completed")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "#00FF22"))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 5)
                                .background(Color(red: 0, green: 1, blue: 0.13).opacity(0.3))
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .inset(by: 0.25)
                                        .stroke(Color(red: 0, green: 1, blue: 0.13), lineWidth: 0.5)
                                    
                                )
                                .padding(.top, 5)
                        }
                        Spacer()
                        ZStack(alignment: .bottom) {
                            VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark, alpha: 0.9)
                                .frame(height: 85)
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Progress")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(daysLeft) days left")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                HStack(spacing: 8) {
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .frame(height: 14)
                                                .foregroundColor(Color.white.opacity(0.25))
                                            Capsule()
                                                .frame(width: geo.size.width * animatedProgress, height: 14)
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [Color(hex: "#990F0F"), Color(hex: "#FF1919")]),
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .animation(.easeInOut(duration: 0.6), value: animatedProgress)
                                        }
                                    }
                                    .frame(height: 14)
                                    Text("\(percentComplete)%")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(height: 22, alignment: .center)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                            .padding(.bottom, 12)
                        }
                        .frame(height: 85)
                    }
                }
                .frame(height: height)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white, lineWidth: 0.5)
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { _, newProgress in
            animatedProgress = newProgress
        }
    }
}

#Preview {
    TrainingPlanCardModal(planName: "Stronger Holds", daysLeft: 0, percentComplete: 100, progress: 1.0, image: "stronger_holds", height: 250, completed: true, onTap: {})
        .padding()
        .background(Color.black)
} 
