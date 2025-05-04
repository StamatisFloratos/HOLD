import SwiftUI

struct OnboardingView: View {
    @State private var currentIndex: Int = 0
    @State private var selections: [UUID: Set<String>] = [:]
    @State private var textInputs: [UUID: String] = [:]
    @State private var name: String = ""
    @State private var age: String = ""
    @EnvironmentObject var navigationManager: NavigationManager

    
    private let questions = OnboardingQuestion.sampleScreens
    
    var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Image("holdIcon")
                    Spacer()
                }
                .padding(.top, 24)

                // Progress Bar
                progressBar
                    .padding(.top, 32)
                    .padding(.bottom, 49)
                
                // Title & Subtitle
                Text(questions[currentIndex].title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                if let subtitle = questions[currentIndex].subtitle {
                    Text(subtitle)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 30)
                        .padding(.horizontal, 24)
                }
                
                // Image (if any)
                if let imageName = questions[currentIndex].imageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal,42)
                        .padding(.top, 32)
                }
                
//                Spacer()
                
                // Options, Text Fields, or Info
                if currentIndex == questions.count - 1 {
                    // Last question with text fields
                    VStack(spacing: 20) {
                        TextField("Name", text: $name)
                            .textFieldStyle(CustomTextFieldStyle())
                            .padding(.horizontal, 33)
                            .foregroundColor(Color.white)
                        
                        TextField("Age", text: $age)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.numberPad)
                            .padding(.horizontal, 33)
                    }
                    .padding(.top, 30)
                } else if !questions[currentIndex].options.isEmpty {
                    optionsView(for: questions[currentIndex])
                }
                
                Spacer()
                
                // Next Button - Only show on first question, questions with images, or last question
                if currentIndex == 0 || questions[currentIndex].imageName != nil || currentIndex == questions.count - 1 {
                    Button(action: {
                        if currentIndex < questions.count - 1 {
                            currentIndex += 1
                        } else {
                            // Handle completion (e.g., save answers, navigate away)
                            navigationManager.push(to: .mainTabView)
                        }
                    }) {
                        Text(currentIndex == questions.count - 1 ? "Make Personalized Plan" : "Next")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity, maxHeight: 47)
                            .background(currentIndex == questions.count - 1 && (name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                                                                age.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? Color(hex: "#FF1919").opacity(0.7) :Color(hex: "#FF1919"))
                            .foregroundColor(.white)
                            .cornerRadius(30)
                            .padding(.horizontal, 56)
                    }
                    .padding(.bottom, 32)
                    .disabled(!canProceed(for: questions[currentIndex]))
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var progressBar: some View {
        let progress = Double(currentIndex + 1) / Double(questions.count)
        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 13)
                    .foregroundColor(Color(hex: "#525252"))
                withAnimation {
                    Capsule()
                        .frame(width: geo.size.width * progress, height: 13)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#FF1919"),
                                    Color(hex: "#990F0F")
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
        }
        .frame(height: 13)
        .padding(.horizontal, 33)
    }
    
    @ViewBuilder
    private func optionsView(for question: OnboardingQuestion) -> some View {
        ScrollView {
            VStack(spacing: 18) {
                ForEach(question.options, id: \.self) { option in
                    Button(action: {
                        handleSelection(for: question, option: option)
                    }) {
                        HStack {
                            Text(option)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    selected(for: question, option: option) ?
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "#FF1919"),
                                            Color(hex: "#990F0F")
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: "#525252"),
                                            Color(hex: "#525252")
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                    }
                }
            }
            .padding(.horizontal, 33)
            .padding(.top, 30)
        }
    }
    
    private func handleSelection(for question: OnboardingQuestion, option: String) {
        let qid = question.id
        if question.allowsMultipleSelection {
            var set = selections[qid] ?? []
            if set.contains(option) {
                set.remove(option)
            } else {
                set.insert(option)
            }
            selections[qid] = set
        } else {
            selections[qid] = [option]
            // Auto-proceed to next question if not first question and no image
            if currentIndex != 0 && question.imageName == nil && currentIndex < questions.count - 1 {
                currentIndex += 1
            }
        }
    }
    
    private func selected(for question: OnboardingQuestion, option: String) -> Bool {
        selections[question.id]?.contains(option) ?? false
    }
    
    private func canProceed(for question: OnboardingQuestion) -> Bool {
        if question.options.isEmpty {
            
            return true
        }
        else if currentIndex == questions.count - 1 {
            // For the last question, check if both name and age are filled
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                   !age.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return !(selections[question.id]?.isEmpty ?? true)
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(hex: "#525252").opacity(0.5))
            .cornerRadius(16)
            .foregroundColor(.white)
            .font(.system(size: 17, weight: .semibold))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    .cornerRadius(16)
            )
    }
}

#Preview {
    OnboardingView()
} 
