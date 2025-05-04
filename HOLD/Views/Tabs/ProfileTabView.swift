//
//  ProfileTabView.swift
//  HOLD
//
//  Created by Stamatis Floratos on 21/3/25.
//

import SwiftUI

struct ProfileTabView: View {
    @EnvironmentObject private var notificationsManager: NotificationsManager
    
    @State private var userProfile: UserProfile = UserProfile.load()
    @State private var isEditing: Bool = false
    @State private var showSubscriptionManagement: Bool = false
    
    @State private var showValidationAlert: Bool = false
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
                                    .background(Color.clear)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
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
                                    .background(Color.clear)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .toggleStyle(SwitchToggleStyle(tint: Color.green))
                                    .onChange(of: notificationsManager.notificationsEnabled) { oldValue, newValue in
                                        if newValue {
                                            notificationsManager.enableNotifications()
                                        } else {
                                            notificationsManager.disableNotifications()
                                        }
                                    }
                                }
                            }
                            
                            // Support Section
                            SectionView(title: "Support") {
                                VStack(spacing: 0) {
                                    Link(destination: URL(string: "mailto:contact@gospelapp.io")!) {
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
                                    
                                    Link(destination: URL(string: "http://gospelapp.io/privacy")!) {
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
                                    
                                    Link(destination: URL(string: "http://gospelapp.io/terms")!) {
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
                                .background(Color.clear)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.vertical)
                    }
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
    }
    
    private var profileInfoView: some View {
        VStack(spacing: 15) {
            if !isEditing {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(userProfile.name)
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("Age: \(userProfile.age)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: { isEditing = true }) {
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
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.leading, 5)
                        
                        TextField("Name", text: $userProfile.name)
                            .padding(10)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Age")
                            .font(.caption)
                            .foregroundColor(.gray)
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
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                    }
                    
                    Spacer()
                    
                    Button(action: saveUserInfo) {
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
        .background(Color.clear)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
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
                .padding(.horizontal)
            
            content
                .padding(.horizontal)
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
                .padding(.bottom, 14)
                
                // Add top padding to push content below the safe area protective layer
                Spacer().frame(height: 120)
                
                Image(systemName: "creditcard")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.white)
                
                Text("Manage Your Subscriptions")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text("To manage you subscriptions, go to Settings > Name > Subscriptions")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                // White back button - moved directly below the text
                Button(action: {
                    // Trigger the onBack action
                    triggerHaptic()
                    onBack()
                }) {
                    HStack{
                        Spacer()
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
                .padding(.top, 30) // Add padding between text and button
                
                Spacer() // This spacer will push content up rather than pushing the button down
            }
        }
        .navigationBarHidden(true) // Hide navigation bar since we're using a custom back button
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
}
