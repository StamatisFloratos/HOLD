import SwiftUI

struct TrainingPlanCard: View {
    let planName: String
    let daysLeft: Int
    let percentComplete: Int
    let progress: Double
    let image: String?
    let height: CGFloat
    let onTap: () -> Void
    
    @State private var animatedProgress: Double = 0.0
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .center) {
                if let imageName = image {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: height)
                        .clipped()
                } else {
                    Color.gray.frame(height: height)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(planName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                    Spacer()
                    ZStack(alignment: .bottom) {
                        VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark, alpha: 0.9)
                            .frame(height: 70)
                        VStack(spacing: 4) {
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
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                    }
                    .frame(height: 70)
                }
            }
            .frame(height: height)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white, lineWidth: 0.5)
            )
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
    TrainingPlanCard(planName: "Kegel Basics", daysLeft: 27, percentComplete: 10, progress: 0.1, image: "kegel_basics", height: 180, onTap: {})
        .padding()
        .background(Color.black)
}
