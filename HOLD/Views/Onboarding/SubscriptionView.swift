//
//  SubscriptionView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 08/05/2025.
//

import SwiftUI

struct SubscriptionView: View {
    @State private var showNextView = false

    var body: some View {
        ZStack {
            AppBackground()
            if showNextView {
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                    .zIndex(1)
            }
            else {
                
                VStack(alignment:.center) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.white)
                        .font(.system(size: 32, weight: .regular))
                        .padding(.top,60)
                    
                    Text("\(UserStorage.username), we’ve made a custom plan\nfor you.")
                        .foregroundColor(Color.white)
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top,20)
                        .multilineTextAlignment(.center)
                    ScrollView {
                        Text("You will have reached your goal of lasting\n \(UserStorage.wantToLastTime) by:")
                            .foregroundStyle(LinearGradient(
                                colors: [
                                    Color(hex:"#A7A7A7"),
                                    Color(hex:"#FFFFFF"),
                                    Color(hex:"#4B4B4B")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .font(.system(size: 12, weight: .semibold))
                            .padding(.top,66)
                            .multilineTextAlignment(.center)
                        
                        Text("Jun 10, 2025")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 124,height: 37)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.white)
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .padding(.top,27)
                        
                        HStack {
                            Color.white.opacity(0.4)
                        }
                        .frame(width: 171,height: 2)
                        .padding(.top,49)
                        
                        Image("thankyouIcon")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,74)
                            .padding(.top,-30)
                        
                        Image("premiumTextIcon")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,33)
                            .padding(.top,-20)
                        
                        Image("tagIcons")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,45)
                            .padding(.top,25)
                        
                        Image("coupleIcon")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,82)
                            .padding(.top,46)
                        
                        Text("Unlock Your Full Potential")
                            .foregroundColor(Color.white)
                            .font(.system(size: 20, weight: .bold))
                            .padding(.top,26)
                        
                        Image("pointers")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,79)
                            .padding(.top,33)
                        
                        Image("rating")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,129)
                            .padding(.top,23)
                        
                        Text("*“Honestly didn’t think an app could make a difference,\nbut here I am, lasting longer and feeling way more in\ncontrol. My girl noticed too...let’s just say she’s not\ncomplaining.”*")
                            .foregroundColor(Color.white)
                            .font(.system(size: 12, weight: .regular))
                            .padding(.top,41)
                            .multilineTextAlignment(.center)
                        
                        
                        Text("-Anonymous HOLD Subscriber")
                            .foregroundColor(Color.white.opacity(0.5))
                            .font(.system(size: 14, weight: .regular))
                            .padding(.top,14)
                        
                        HStack {
                            Color.white.opacity(0.4)
                        }
                        .frame(width: 171,height: 2)
                        .padding(.top,26)
                        
                        Image("womanIcon")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,133)
                            .padding(.top,0)
                        Text("She’ll Thank You Later")
                            .foregroundColor(Color.white)
                            .font(.system(size: 20, weight: .bold))
                            .padding(.top,-5)
                        
                        Text("This isn’t just about ***you***.\nIt’s about showing up, lasting longer, and\ngiving her an experience she won’t forget.")
                            .foregroundColor(Color.white)
                            .font(.system(size: 12, weight: .bold))
                            .padding(.top,17)
                            .padding(.horizontal,37)
                            .multilineTextAlignment(.center)
                        
                        Image("rating")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,129)
                            .padding(.top,23)
                        
                        
                        Text("*“I asked him how did he do this and after some time\nhe admitted that he was using this app, idk why the\ngatekeeping. Anyway I came on here as the REAL end-\nuser of the results to say that this is MORE than worth\nit, ladies trust me on this one, get it for him.””*")
                            .foregroundColor(Color.white)
                            .font(.system(size: 12, weight: .regular))
                            .padding(.top,41)
                            .multilineTextAlignment(.center)
                        
                        Text("-Jamie’s Girlfriend (apparently)")
                            .foregroundColor(Color.white.opacity(0.5))
                            .font(.system(size: 14, weight: .regular))
                            .padding(.top,14)
                        
                        VStack(spacing:0) {
                            Text("✊")
                                .foregroundColor(Color.white)
                                .font(.system(size: 40, weight: .regular))
                                .padding(.top,36)
                            Text("Simple, daily workouts")
                                .foregroundColor(Color.white)
                                .font(.system(size: 16, weight: .bold))
                                .padding(.top,27)
                            Text("HOLD uses 100% science-\nbacked workouts to create real,\n lasting improvements in sexual\nperformance.")
                                .foregroundColor(Color.white)
                                .font(.system(size: 16, weight: .medium))
                                .padding(.top,14)
                                .multilineTextAlignment(.center)
                            
                            Text("You will have reached your goal of lasting\n\(UserStorage.wantToLastTime) by:")
                                .foregroundColor(Color(hex: "A7A7A7"))
                                .font(.system(size: 12, weight: .regular))
                                .padding(.top,20)
                                .multilineTextAlignment(.center)
                            
                            Text("Jun 10, 2025")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 124,height: 37)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color(hex: "#424242"))
                                .cornerRadius(30)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30)
                                        .stroke(Color(hex: "#424242"), lineWidth: 1)
                                )
                                .padding(.top,20)
                            
                            HStack {
                                Text("How to reach your goal:")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.top,16)
                            .padding(.horizontal,29)
                            
                            
                            Image("pointers2")
                                .resizable()
                                .scaledToFit()
                                .padding(.horizontal,25)
                                .padding(.bottom,82)
                                .padding(.top,16)
                            
                        }
                        .padding(.top,41)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                        .padding(.horizontal,50)
                        
                        Image("manIcon1")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,135)
                            .padding(.top,46)
                        
                        Text("Maximize Pleasure. Alone\nor Together.")
                            .foregroundColor(Color.white)
                            .font(.system(size: 20, weight: .bold))
                            .padding(.top,26)
                            .multilineTextAlignment(.center)
                        
                        
                        Image("pointers3")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,53)
                            .padding(.top,33)
                        
                        Image("rating")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,129)
                            .padding(.top,23)
                        
                        Text("*“I downloaded the app just to read through the\nmethods, out of curiosity. Then I tried the Blue\nMethod…. I never thought I could feel that stuff in the\nplaces that I did....that's all imma say.”*")
                            .foregroundColor(Color.white)
                            .font(.system(size: 12, weight: .regular))
                            .padding(.top,41)
                            .multilineTextAlignment(.center)
                        
                        
                        Text("-Anonymous HOLD Subscriber")
                            .foregroundColor(Color.white.opacity(0.5))
                            .font(.system(size: 14, weight: .regular))
                            .padding(.top,14)
                        
                        
                        Image("manIcon2")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,128)
                            .padding(.top,46)
                        
                        Text("Take Back Control")
                            .foregroundColor(Color.white)
                            .font(.system(size: 20, weight: .bold))
                            .padding(.top,26)
                        
                        
                        Text("Take back control of your body, your\npleasure, and your performance. It starts\nwith one simple habit.")
                            .foregroundColor(Color.white)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.top,26)
                            .multilineTextAlignment(.center)
                        
                        
                        Image("rating")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,129)
                            .padding(.top,23)
                        
                        Text("But to succeed, you need the right tools and the right\n methods.\nWe’ve done the science, so you can\nfocus on the results.")
                            .foregroundColor(Color.white)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.top,26)
                            .multilineTextAlignment(.center)
                        
                        ZStack {
                            Image("blueGradient")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 254,height:190)
                            VStack(spacing: 0) {
                                Text("Special Discount!")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 24, weight: .semibold))
                                    .padding(.top,12)
                                Text("Get 60% off on HOLD Premium!")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 14, weight: .semibold))
                                    .padding(.top,11)
                                Button(action: {
                                    
                                }, label: {
                                    HStack {
                                        Text("Claim Now")
                                            .background(Color.white)
                                            .foregroundColor(.black)
                                        
                                    }
                                    .frame(width: 105, height: 46)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                })
                                .padding(.top,16)
                            }
                        }
                        .padding(.top,51)
                        .padding(.bottom,42)
                    }
                    .scrollIndicators(.hidden)
                    
                    VStack(spacing:11) {
                        Button(action: {
                            triggerHapticOnButton()
                            showNextView = true
                        }) {
                            Text("Become a HOLDER")
                                .font(.system(size: 16, weight: .semibold))
                                .frame(maxWidth: .infinity, maxHeight: 47)
                                .background(Color(hex: "#FF1919"))
                                .foregroundColor(.white)
                                .cornerRadius(30)
                                .padding(.horizontal, 56)
                        }
                        
                        
                        Text("Purchase appears as iTunes")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Cancel Anytime ✅ Money back guarantee 🛡️")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                        
                        
                    }
                    .padding(.bottom, 13)
                }
//                .padding(.horizontal,33)
                
            }
        }
    }
    
    func triggerHapticOnButton() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}

#Preview {
    SubscriptionView()
}
