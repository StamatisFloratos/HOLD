//
//  ProfileTabView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI

struct ProfileTabView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject private var notificationsManager: NotificationsManager
    @EnvironmentObject var trainingPlansViewModel: TrainingPlansViewModel
    
    @State private var userProfile: UserProfile = UserProfile.load()
    @State private var isEditing: Bool = false
    @State private var showSubscriptionManagement: Bool = false
    
    @State private var showValidationAlert: Bool = false
    @State private var showSettingsAlert: Bool = false
    @State private var validationMessage: String = ""
    
    var body: some View {
        ZStack {
            AppBackground()
            
            // Main content
            if showSubscriptionManagement {
                SubscriptionManagementView(onBack: {
                    withAnimation {
                        showSubscriptionManagement = false
                    }
                })
                .transition(.move(edge: .trailing))
                .zIndex(1)
            } else {
                VStack {
                    HStack {
                        Spacer()
                        Image("holdIcon")
                        Spacer()
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 14)
                    
                    ScrollView {
                        VStack(spacing: 10) {
                            // Add top padding to push content below the safe area protective layer
                            Spacer().frame(height: 20)
                            
                            // User Profile Section
                            SectionView(title: "Profile") {
                                profileInfoView
                            }
                            
                            if let currentPlanId = trainingPlansViewModel.currentPlanId,
                               let currentPlan = trainingPlansViewModel.plans.first(where: { $0.id == currentPlanId }) {
                                
                                
                                TrainingPlanCard(
                                    planName: currentPlan.name,
                                    daysLeft: max(0, trainingPlansViewModel.daysLeft(planStartDate: trainingPlansViewModel.planStartDate ?? Date(), currentDate: Date(), planDurationDays: currentPlan.duration)),
                                    percentComplete: currentPlan.days.count > 0 ? Int((Double(trainingPlansViewModel.planProgress[currentPlan.id]?.count ?? 0) / Double(currentPlan.days.count)) * 100) : 0,
                                    progress: currentPlan.days.count > 0 ? Double(trainingPlansViewModel.planProgress[currentPlan.id]?.count ?? 0) / Double(currentPlan.days.count) : 0.0,
                                    image: currentPlan.image,
                                    height: 180,
                                    onTap: {}
                                )
                                .padding(.vertical, 25)
                                .padding(.horizontal, 20)
                            }
                            
                            // Subscription Section
                            SectionView(title: "Subscription") {
                                Button(action: {
                                    withAnimation {
                                        showSubscriptionManagement = true
                                    }
                                }) {
                                    HStack {
                                        Text("Manage Subscription")
                                            .foregroundColor(.white)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(hex: "#242E3A"))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .inset(by: 0.5)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                            
                            // Preferences Section
                            SectionView(title: "Preferences") {
                                VStack {
                                    Toggle(isOn: $notificationsManager.notificationsEnabled) {
                                        Text("Notifications")
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color(hex: "#242E3A"))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .inset(by: 0.5)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .toggleStyle(SwitchToggleStyle(tint: Color.green))
                                    .onChange(of: notificationsManager.notificationsEnabled) { oldValue, newValue in
                                        if newValue {
                                            if notificationsManager.isAuthorized {
                                                notificationsManager.enableNotifications()
                                            } else {
                                                notificationsManager.notificationsEnabled = false
                                                showSettingsAlert = true
                                            }
                                        } else {
                                            notificationsManager.disableNotifications()
                                        }
                                    }
                                }
                            }
                            
                            // Support Section
                            SectionView(title: "Support") {
                                VStack(spacing: 0) {
                                    Link(destination: URL(string: "mailto:contact@holdapp.pro")!) {
                                        HStack {
                                            Text("Contact Us")
                                                .foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "envelope")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                    }
                                    
                                    Divider()
                                        .background(Color.white.opacity(0.2))
                                    
                                    Link(destination: URL(string: "https://www.holdapp.pro/privacy")!) {
                                        HStack {
                                            Text("Privacy Policy")
                                                .foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "arrow.up.right.square")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                    }
                                    
                                    Divider()
                                        .background(Color.white.opacity(0.2))
                                    
                                    Link(destination: URL(string: "https://www.holdapp.pro/terms")!) {
                                        HStack {
                                            Text("Terms of Service")
                                                .foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "arrow.up.right.square")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                    }
                                }
                                .background(Color(hex: "#242E3A"))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .inset(by: 0.5)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.vertical)
                    }
                    .scrollIndicators(.hidden)
                }
            }
        }
        .alert(isPresented: $showValidationAlert) {
            Alert(
                title: Text("Invalid Input"),
                message: Text(validationMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .alert("Enable Notifications", isPresented: $showSettingsAlert) {
            Button("Open Settings") {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("To receive workout reminders and motivation, please enable notifications for Hold in your device settings, then turn this toggle on again.")
        }
        .onAppear() {
            notificationsManager.checkAuthorizationStatus()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                notificationsManager.checkAuthorizationStatus()
            }
        }
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    private var profileInfoView: some View {
        VStack(spacing: 15) {
            if !isEditing {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(userProfile.name)
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                        
                        Text("Age: \(userProfile.age)")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        triggerHaptic()
                        isEditing = true }) {
                            Text("Edit")
                                .foregroundColor(.black)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                }
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Name")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.leading, 5)
                        
                        TextField("Name", text: $userProfile.name)
                            .padding(10)
                            .background(Color.clear)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .inset(by: 0.5)
                                    .stroke(.white.opacity(0.5), lineWidth: 1)
                                
                            )
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Age")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.leading, 5)
                        
                        TextField("Age", text: Binding<String>(
                            get: { String(userProfile.age) },
                            set: { newValue in
                                if let intVal = Int(newValue) {
                                    userProfile.age = intVal
                                }
                            }
                        ))
                        .padding(10)
                        .background(Color.clear)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .inset(by: 0.5)
                                .stroke(.white.opacity(0.5), lineWidth: 1)
                            
                        )
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        triggerHaptic()
                        saveUserInfo()
                    }) {
                        Text("Save")
                            .foregroundColor(.black)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.6, green: 0, blue: 0), location: 0.00),
                    Gradient.Stop(color: Color(red: 1, green: 0, blue: 0), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1)
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.25)
                .stroke(.white, lineWidth: 0.5)
            
        )
    }
    
    private func saveUserInfo() {
        guard !userProfile.name.isEmpty else {
            validationMessage = "Name cannot be empty."
            showValidationAlert = true
            return
        }
        
        guard userProfile.name.count <= 30 else {
            validationMessage = "Name cannot be more than 30 characters."
            showValidationAlert = true
            return
        }
        
        guard (13...99).contains(userProfile.age) else {
            validationMessage = "Age must be between 13 and 99."
            showValidationAlert = true
            return
        }
        
        userProfile.save()
        isEditing = false
    }
}

// Helper view for section headers
struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            content
                .padding(.horizontal, 20)
        }
    }
}

// Subscription Management View
struct SubscriptionManagementView: View {
    var onBack: () -> Void
    
    var body: some View {
        ZStack {
            AppBackground()
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Image("holdIcon")
                    Spacer()
                }
                .padding(.top, 24)
                
                Button(action: {
                    // Trigger the onBack action
                    triggerHaptic()
                    onBack()
                }) {
                    HStack{
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.white)
                        Text("Back")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 5)
                            .cornerRadius(8)
                        Spacer()
                    }
                    
                }
                .padding(.leading)
                
                Text("Manage Your Subscription")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                VStack(spacing: 35) {
                    HStack(spacing: 15) {
                        Image(systemName: "gear")
                            .font(.system(size: 40))
                            .foregroundStyle(.white)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Purchased via iOS App?")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                            Text("To manage it go to:")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Text("Settings → Apple ID → Subscriptions")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.leading, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: "#242E3A"))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                    
                    Button(action: {
                        if let url = URL(string: "https://www.holdapp.pro/account") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "globe")
                                .font(.system(size: 40))
                                .foregroundStyle(.white)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(alignment: .center) {
                                    Text("Purchased via Web?")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "arrow.up.forward.app")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.gray)
                                        .padding(.trailing, 10)
                                    
                                }
                                .padding(.bottom, 10)
                                Text("Go to:")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Text(AttributedString("www.holdapp.pro/account"))
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.leading, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "#242E3A"))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
    
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    ProfileTabView()
        .environmentObject(NotificationsManager.shared)
        .environmentObject(TrainingPlansViewModel.preview)
}
