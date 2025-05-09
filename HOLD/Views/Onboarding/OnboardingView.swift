import SwiftUI

struct OnboardingView: View {
    @State private var currentIndex: Int = 0
    @State private var selections: [UUID: Set<String>] = [:]
    @State private var textInputs: [UUID: String] = [:]
    @State private var name: String = ""
    @State private var age: String = ""
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var showMainView = false
    
    private let questions = OnboardingQuestion.sampleScreens
    
    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""
    
    var body: some View {
        ZStack {
            AppBackground()
            if showMainView {
                PersonalPlanView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .zIndex(1)
            } else {
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
                    if questions[currentIndex].title != "" {
                        Text(questions[currentIndex].title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    } else {
                        Image("questionText")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal, 54)
                    }
                    
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
//                            TextField("Name", text: $name)
                                
                                
                            CustomTextField(placeholder: "Name", text: $name)
                                .padding(.horizontal, 33)
                                .foregroundColor(Color.white)
                            
                            CustomTextField(placeholder: "Age", text: $age)
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
                            triggerHaptic()
                            if currentIndex < questions.count - 1 {
                                currentIndex += 1
                            } else {
                                // Handle completion (e.g., save answers, navigate away)
                                guard !name.isEmpty else {
                                    validationMessage = "Name cannot be empty."
                                    showValidationAlert = true
                                    return
                                }
                                
                                guard name.count <= 30 else {
                                    validationMessage = "Name cannot be more than 30 characters."
                                    showValidationAlert = true
                                    return
                                }
                                
                                guard let ageInt = Int(age), (13...99).contains(ageInt) else {
                                    validationMessage = "Age must be between 13 and 99."
                                    showValidationAlert = true
                                    return
                                }

                                var userProfile = UserProfile.load()
                                userProfile.name = name
                                userProfile.age = ageInt
                                userProfile.save()
                                
                                withAnimation {
                                    showMainView = true
                                }
                                
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
        }
        .animation(.easeInOut, value: showMainView)
        .navigationBarHidden(true)
        .alert(isPresented: $showValidationAlert) {
            Alert(
                title: Text("Invalid Input"),
                message: Text(validationMessage),
                dismissButton: .default(Text("OK"))
            )
        }
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
                        triggerHaptic()
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
            if question.id == questions[2].id {
                UserStorage.wantToLastTime = option
            }
            selections[qid] = [option]
            // Auto-proceed to next question if not first question and no image
            if currentIndex != 0 && question.imageName == nil && currentIndex < questions.count - 1 {
                // Add a small delay to show the selection before proceeding
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    currentIndex += 1
                }
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
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(hex: "#525252").opacity(0.5))
            .cornerRadius(16)
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .semibold))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex:"#FFF6F6").opacity(0.5), lineWidth: 1)
                    .cornerRadius(16)
            )
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            // Custom placeholder only shown when not focused and text is empty
            if text.isEmpty && !isFocused {
                Text(placeholder)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
            }

            TextField("", text: $text)
                .textFieldStyle(CustomTextFieldStyle())
                .focused($isFocused)
        }
    }
}

#Preview {
    OnboardingView()
} 
