import SwiftUI

struct OnboardingView: View {
    @State private var currentIndex: Int = 0
    @State private var selections: [UUID: Set<String>] = [:]
    @State private var textInputs: [UUID: String] = [:]
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var code: String = ""
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var showMainView = false
    
    // Add this state to track the direction of transitions
    @State private var slideFromRight = true
    
    private let questions = OnboardingQuestion.sampleScreens
    
    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""
    @State private var userProfile = UserProfile.load()
    
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
                    
                    // Content container with transition
                    ZStack {
                        // Title & Subtitle with ID for transition
                        VStack {
                            if questions[currentIndex].title != "" {
                                Text(questions[currentIndex].title)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            } else {
                                HStack(spacing: 0) {
                                    Text("The ")
                                        .foregroundColor(.white)
                                    + Text("H")
                                        .foregroundColor(.white)
                                    + Text("O")
                                        .foregroundColor(Color(hex: "#BD0005"))
                                    + Text("LD")
                                        .foregroundColor(.white)
                                    + Text(" program is better than pills.")
                                        .foregroundColor(.white)
                                }
                                .font(.system(size: 20, weight: .bold))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .background(Color.clear)
                                .padding(.horizontal, 40)
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
                                    .padding(.horizontal, 42)
                                    .padding(.top, 32)
                            }
                            
                            // Options, Text Fields, or Info
                            if currentIndex == questions.count - 1 {
                                // Last question with text fields
                                VStack(spacing: 20) {
                                    CustomTextField(placeholder: "Name", placeholderColor: .white, text: $name)
                                        .padding(.horizontal, 33)
                                        .foregroundColor(Color.white)
                                    
                                    CustomTextField(placeholder: "Age", placeholderColor: .white, text: $age)
                                        .keyboardType(.numberPad)
                                        .padding(.horizontal, 33)
                                }
                                .padding(.top, 30)
                            } else if currentIndex == questions.count - 2 {
                                CustomTextField(placeholder: "CODE", placeholderColor: Color.white.opacity(0.5), text: $code)
                                    .padding(.horizontal, 33)
                                    .padding(.top, 40)
                                    .foregroundColor(Color.white)
                            } else if !questions[currentIndex].options.isEmpty {
                                optionsView(for: questions[currentIndex])
                            }
                        }
                        .id("question_\(currentIndex)") // Unique ID for transition
                        .transition(.asymmetric(
                            insertion: .move(edge: slideFromRight ? .trailing : .leading),
                            removal: .move(edge: slideFromRight ? .leading : .trailing)
                        ))
                    }
                    
                    Spacer()
                    
                    // Next Button - Only show on first question, questions with images, or last question
                    if currentIndex == 0 || questions[currentIndex].imageName != nil || currentIndex == questions.count - 1 || currentIndex == questions.count - 2 {
                        Button(action: {
                            triggerHaptic()
                            if currentIndex == questions.count - 1 {
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

                                userProfile.name = name
                                userProfile.age = ageInt
                                userProfile.save()
                                
                                OnboardingQuestionnaireBuilder.shared.setName(name)
                                OnboardingQuestionnaireBuilder.shared.setAge(age)
                            
                                FirebaseManager.shared.logAgeEvent()
                                
                                withAnimation {
                                    showMainView = true
                                }
                            } else if currentIndex == questions.count - 2 {
                                slideFromRight = true
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentIndex +=  1
                                }
                            } else {
                                slideFromRight = true
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentIndex +=  1
                                }
                            }
                        }) {
                            if currentIndex == questions.count - 1 {
                                Text("Make Personalized Plan")
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(maxWidth: .infinity, maxHeight: 47)
                                    .background(currentIndex == questions.count - 1 && (name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                                                                                        age.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? Color(hex: "#FF1919").opacity(0.7) :Color(hex: "#FF1919"))
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                                    .padding(.horizontal, 56)
                            } else if currentIndex == questions.count - 2 {
                                Text(code.isEmpty ? "Skip" : "Next")
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(maxWidth: .infinity, maxHeight: 47)
                                    .background(code.isEmpty ? Color.white : Color(hex: "#FF1919"))
                                    .foregroundColor(code.isEmpty ? .black : .white)
                                    .cornerRadius(30)
                                    .padding(.horizontal, 56)
                            } else {
                                Text("Next")
                                    .font(.system(size: 16, weight: .semibold))
                                    .frame(maxWidth: .infinity, maxHeight: 47)
                                    .background(Color(hex: "#FF1919"))
                                    .foregroundColor(.white)
                                    .cornerRadius(30)
                                    .padding(.horizontal, 56)
                            }
                        }
                        .padding(.top, 15)
                        .padding(.bottom, 32)
                        .disabled(!canProceed(for: questions[currentIndex]))
                    }
                }
            }
        }
        .animation(.easeInOut, value: showMainView)
        .onAppear {
            // Track first question display
            trackOnboarding("ob_q01_shown", variant: UserStorage.onboarding)
        }
        .onChange(of: currentIndex) { oldValue, newValue in
            // Log event for each subsequent question (1-based index)
            let number = String(format: "%02d", newValue + 1)
            trackOnboarding("ob_q\(number)_shown", variant: UserStorage.onboarding)
        }
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
                    .foregroundColor(Color(hex: "#393939"))
                
                Capsule()
                    .frame(width: geo.size.width * progress, height: 13)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#990F0F"),
                                Color(hex: "#FF1919")
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .animation(.easeInOut(duration: 0.3), value: currentIndex)
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
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 58)
                                .padding(.horizontal, 16)
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
                                            Color(hex: "#1A1A1A")
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .inset(by: 0.25)
                                        .stroke(
                                            LinearGradient(
                                                colors: [Color(hex: "#FFFFFF"), Color(hex: "#999999")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                            , lineWidth: 0.5)
                                )
                            
                        }
                    }
                }
            }
            .padding(.horizontal, 33)
            .padding(.top, 30)
        }
        .scrollIndicators(.hidden)
    }
    
    private func handleSelection(for question: OnboardingQuestion, option: String) {
        let qid = question.id
        if question.allowsMultipleSelection {
            var set = selections[qid] ?? []
            if set.contains(option) {
                set.remove(option)
                OnboardingQuestionnaireBuilder.shared.removeGoalOfWhatDoYouWantToAchieve(option)
            } else {
                set.insert(option)
                OnboardingQuestionnaireBuilder.shared.setGoalOfWhatDoYouWantToAchieve(option)
            }
            selections[qid] = set
        } else {
            if question.id == questions[1].id {
                OnboardingQuestionnaireBuilder.shared.setAvgDurationOfSexualIntercourse(option)
            } else if question.id == questions[2].id {
                UserStorage.wantToLastTime = option
                OnboardingQuestionnaireBuilder.shared.setHowLongYouWishYouCouldLast(option)
            } else if question.id == questions[3].id {
                OnboardingQuestionnaireBuilder.shared.setHowOftenYouFinishEarlierThanYouWish(option)
            } else if question.id == questions[6].id {
                OnboardingQuestionnaireBuilder.shared.setRelationshipStatus(option)
            } else if question.id == questions[7].id {
                OnboardingQuestionnaireBuilder.shared.setTakenPillsEarlierToImproveIntimateLife(option)
            } else if question.id == questions[9].id {
                OnboardingQuestionnaireBuilder.shared.setSleepPerDay(option)
            } else if question.id == questions[10].id {
                OnboardingQuestionnaireBuilder.shared.setAlcoholConsumption(option)
            } else if question.id == questions[11].id {
                OnboardingQuestionnaireBuilder.shared.setDoYouSmoke(option)
            }
            
            selections[qid] = [option]
            // Auto-proceed to next question if not first question and no image
            if currentIndex != 0 && question.imageName == nil && currentIndex < questions.count - 1 {
                // Add a small delay to show the selection before proceeding
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // Set direction for auto-proceed
                    slideFromRight = true
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentIndex += 1
                    }
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
        } else if currentIndex == questions.count - 1 {
            // For the last question, check if both name and age are filled
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                   !age.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } else if currentIndex == questions.count - 2 {
            return true
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
            .padding(.horizontal, 16)
            .frame(height: 58, alignment: .leading)
            .background(Color(hex: "#1A1A1A"))
            .cornerRadius(16)
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .semibold))
            .multilineTextAlignment(.leading)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .inset(by: 0.25)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#FFFFFF"), Color(hex: "#999999")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        , lineWidth: 0.5)
            )
    }
}

struct CustomTextField: View {
    let placeholder: String
    let placeholderColor: Color
    @Binding var text: String

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            // Custom placeholder only shown when not focused and text is empty

            TextField("", text: $text)
                .textFieldStyle(CustomTextFieldStyle())
                .focused($isFocused)
            
            if text.isEmpty && !isFocused {
                Text(placeholder)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(placeholderColor)
                    .padding(.horizontal, 16)
            }
        }
    }
}

#Preview {
    OnboardingView()
} 
