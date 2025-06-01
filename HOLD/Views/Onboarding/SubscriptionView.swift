//
//  SubscriptionView.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 08/05/2025.
//

import SwiftUI
import SuperwallKit

struct SubscriptionView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    @State private var showNextView = false
    @State private var userProfile: UserProfile = UserProfile.load()
    
    @AppStorage("isPremium") private var isPremium: Bool = false
    
    var body: some View {
        ZStack {
            AppBackground()
            
            // Track when the paywall is displayed
            Color.clear.onAppear {
                trackOnboarding("ob_paywall", variant: UserStorage.onboarding)
            }
            
            VStack(alignment:.center) {
                ScrollView {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.white)
                        .font(.system(size: 32, weight: .regular))
                        .padding(.top,60)
                    
                    Text("\(userProfile.name), we've made a custom plan for you.")
                        .foregroundColor(Color.white)
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top,20)
                        .padding(.horizontal, 33)
                        .multilineTextAlignment(.center)
                    
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
                    
                    Text(getFormattedDate())
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
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 171,height: 2)
                        .padding(.top,49)
                    
                    Image("subscriptionStarsIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                        .padding(.top, -40)
                    
                    HStack(spacing: 0) {
                        Text("Become the best of \nyourself with ")
                            .foregroundColor(.white)
                        + Text("H")
                            .foregroundColor(.white)
                        + Text("O")
                            .foregroundColor(Color(hex: "#BD0005"))
                        + Text("LD")
                            .foregroundColor(.white)
                    }
                    .font(.system(size: 20, weight: .bold))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.clear)
                    .padding(.top, -30)
                    
                    Text("Stronger. Harder. Happier.")
                        .font(.system(size: 12, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.top, 2)
                    
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
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .center, spacing: 10) {
                            Image("fireIcon")
                            Text("Last longer, go harder, finish strong")
                                .foregroundColor(.white)
                        }
                        
                        HStack(alignment: .center, spacing: 10) {
                            Image("targetIcon")
                            Text("Feel in control, in and out of bed")
                                .foregroundColor(.white)
                        }
                        
                        HStack(alignment: .center, spacing: 10) {
                            Image("interchangeIcon")
                            Text("Go for more rounds and recover faster")
                                .foregroundColor(.white)
                        }
                        
                        HStack(alignment: .center, spacing: 10) {
                            Image("crownIcon")
                            Text("Become more attractive and confident")
                                .foregroundColor(.white)
                        }
                    }
                    .font(.system(size: 12, weight: .medium))
                    .padding()
                    .background(Color.clear)
                    
                    ZStack {
                        Capsule()
                            .fill(Color.black.opacity(0.4))
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            .frame(width: 145, height: 36)
                            .background(Color.clear)
                        
                        HStack(spacing: 0) {
                            ForEach(0..<5, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color(hex: "#FF9500"))
                                    .font(.system(size: 16))
                            }
                        }
                    }
                    .frame(width: 145, height: 36)
                    .padding(.top, 10)
                    
                    Text("*“Honestly didn't think an app could make a difference,\nbut here I am, lasting longer and feeling way more in\ncontrol. My girl noticed too...let's just say she's not\ncomplaining.”*")
                        .foregroundColor(Color.white)
                        .font(.system(size: 12, weight: .regular))
                        .padding(.top,40)
                        .multilineTextAlignment(.center)
                    
                    Text("-Anonymous HOLD Subscriber")
                        .foregroundColor(Color.white.opacity(0.5))
                        .font(.system(size: 14, weight: .regular))
                        .padding(.top,14)
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 171,height: 2)
                        .padding(.top,26)
                    
                    Image("womanIcon")
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal,133)
                        .padding(.top,0)
                    
                    Text("She'll Thank You Later")
                        .foregroundColor(Color.white)
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top,-10)
                    
                    Text("This isn't just about ***you***.\nIt's about showing up, lasting longer, and\ngiving her an experience she won't forget.")
                        .foregroundColor(Color.white)
                        .font(.system(size: 12, weight: .bold))
                        .padding(.top,17)
                        .padding(.horizontal,37)
                        .multilineTextAlignment(.center)

                    ZStack {
                        Capsule()
                            .fill(Color.black.opacity(0.4))
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            .frame(width: 145, height: 36)
                            .background(Color.clear)
                        
                        HStack(spacing: 0) {
                            ForEach(0..<5, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color(hex: "#FF9500"))
                                    .font(.system(size: 16))
                            }
                        }
                    }
                    .frame(width: 145, height: 36)
                    .padding(.top, 30)
                    
                    
                    Text("*“I asked him how did he do this and after some time\nhe admitted that he was using this app, idk why the\ngatekeeping. Anyway I came on here as the REAL end-\nuser of the results to say that this is MORE than worth\nit, ladies trust me on this one, get it for him.”*")
                        .foregroundColor(Color.white)
                        .font(.system(size: 12, weight: .regular))
                        .padding(.top,40)
                        .multilineTextAlignment(.center)
                    
                    Text("-Jamie's Girlfriend (apparently)")
                        .foregroundColor(Color.white.opacity(0.5))
                        .font(.system(size: 14, weight: .regular))
                        .padding(.top,10)
                    
                    VStack(spacing:0) {
                        Text("✊")
                            .foregroundColor(Color.white)
                            .font(.system(size: 40, weight: .regular))
                            .padding(.top,0)
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
                            .font(.system(size: 12, weight: .semibold))
                            .padding(.top,20)
                            .multilineTextAlignment(.center)
                        
                        Text(getFormattedDate())
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
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.top,16)
                        .padding(.horizontal,29)
                        
                        VStack(alignment: .leading, spacing: 22) {
                            HStack(alignment: .center, spacing: 10) {
                                Image("exerciseIcon")
                                Text("Complete your daily HOLD workout and track your progress.")
                                    .foregroundColor(.white)
                            }
                            
                            HStack(alignment: .center, spacing: 10) {
                                Image("emojiIcon")
                                Text("Learn about the secret methods nobody's telling you that will change your sex-life.")
                                    .foregroundColor(.white)
                            }
                            
                            HStack(alignment: .center, spacing: 10) {
                                Image("mountainIcon")
                                Text("Do 'The Challenge' and see how you perform.")
                                    .foregroundColor(.white)
                            }
                            
                            HStack(alignment: .center, spacing: 10) {
                                Image("bedIcon")
                                Text("Apply what you learn and let us know how it goes.")
                                    .foregroundColor(.white)
                            }
                        }
                        .font(.system(size: 12, weight: .medium))
                        .padding(.top, 20)
                        .padding(.horizontal, 25)
                        .padding(.bottom, 80)
                        .background(Color.clear)
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
                        .padding(.top,20)
                    
                    Text("Maximize Pleasure. Alone\nor Together.")
                        .foregroundColor(Color.white)
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top,10)
                        .multilineTextAlignment(.center)
                    
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .center, spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#FF0000"))
                                
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 10))
                            }
                            .frame(width: 18, height: 18)
                            
                            Text("Feel more sensation and control")
                                .foregroundColor(.white)
                                .font(.system(size: 12, weight: .medium))
                        }
                        
                        HStack(alignment: .center, spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#FF9500"))
                                
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 10))
                            }
                            .frame(width: 18, height: 18)
                            
                            Text("Boost arousal and orgasm intensity, naturally")
                                .foregroundColor(.white)
                                .font(.system(size: 12, weight: .medium))
                        }
                        
                        HStack(alignment: .center, spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#AE00FF"))
                                
                                Image(systemName: "sparkles")
                                    .foregroundColor(.white)
                                    .font(.system(size: 10))
                            }
                            .frame(width: 18, height: 18)
                            
                            Text("Enjoy healthy and satisfying intimacy")
                                .foregroundColor(.white)
                                .font(.system(size: 12, weight: .medium))
                        }
                        
                        HStack(alignment: .center, spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#009DFF"))
                                
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 10))
                            }
                            .frame(width: 18, height: 18)
                            
                            Text("Discover solo play methods for better orgasms")
                                .foregroundColor(.white)
                                .font(.system(size: 12, weight: .medium))
                        }
                    }
                    .padding(.top, 30)
                    .background(Color.clear)
                    
                    ZStack {
                        Capsule()
                            .fill(Color.black.opacity(0.4))
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            .frame(width: 145, height: 36)
                            .background(Color.clear)
                        
                        HStack(spacing: 0) {
                            ForEach(0..<5, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color(hex: "#FF9500"))
                                    .font(.system(size: 16))
                            }
                        }
                    }
                    .frame(width: 145, height: 36)
                    .padding(.top, 30)
                    
                    Text("*“I downloaded the app just to read through the\nmethods, out of curiosity. Then I tried the Blue\nMethod…. I never thought I could feel that stuff in the\nplaces that I did....that's all imma say.”*")
                        .foregroundColor(Color.white)
                        .font(.system(size: 12, weight: .regular))
                        .padding(.top,30)
                        .multilineTextAlignment(.center)
                    
                    
                    Text("-Anonymous HOLD Subscriber")
                        .foregroundColor(Color.white.opacity(0.5))
                        .font(.system(size: 14, weight: .regular))
                        .padding(.top,14)
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 171,height: 2)
                        .padding(.top,26)
                    
                    Image("manIcon2")
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal,128)
                        .padding(.top,16)
                    
                    Text("Take Back Control")
                        .foregroundColor(Color.white)
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top,13)
                    
                    
                    Text("Take back control of your body, your\npleasure, and your performance. It starts\nwith one simple habit.")
                        .foregroundColor(Color.white)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.top,30)
                        .multilineTextAlignment(.center)
                    
                    ZStack {
                        Capsule()
                            .fill(Color.black.opacity(0.4))
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            .frame(width: 145, height: 36)
                            .background(Color.clear)
                        
                        HStack(spacing: 0) {
                            ForEach(0..<5, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color(hex: "#FF9500"))
                                    .font(.system(size: 16))
                            }
                        }
                    }
                    .frame(width: 145, height: 36)
                    .padding(.top, 20)
                    
                    Text("But to succeed, you need the right\ntools and the right methods.\nWe've done the science, so you can\nfocus on the results.")
                        .foregroundColor(Color.white)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.top,17)
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
                                .padding(.top,22)
                            Text("Get 60% off on HOLD Premium!")
                                .foregroundColor(Color.white)
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.top,11)
                            Button(action: {
                                if UserStorage.onboarding == OnboardingType.onboardingOne
                                    .rawValue {
                                    Superwall.shared.register(placement: "hold_gift_offer", feature: {
                                        subscriptionManager.checkSubscriptionStatus()
                                    })
                                } else if UserStorage.onboarding == OnboardingType.onboardingTwo
                                    .rawValue {
                                    Superwall.shared.register(placement: "hold_gift_offer_2", feature: {
                                        subscriptionManager.checkSubscriptionStatus()
                                    })
                                } else if UserStorage.onboarding == OnboardingType.onboardingThree
                                    .rawValue {
                                    Superwall.shared.register(placement: "hold_gift_offer_3", feature: {
                                        subscriptionManager.checkSubscriptionStatus()
                                    })
                                } else if UserStorage.onboarding == OnboardingType.onboardingFour
                                    .rawValue {
                                    Superwall.shared.register(placement: "hold_gift_offer_4", feature: {
                                        subscriptionManager.checkSubscriptionStatus()
                                    })
                                } else {
                                    Superwall.shared.register(placement: "hold_gift_offer", feature: {
                                        subscriptionManager.checkSubscriptionStatus()
                                    })
                                }
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
                            
                            Spacer()
                        }
                    }
                    .padding(.top,51)
                    .padding(.bottom,42)
                }
                .scrollIndicators(.hidden)
                
                VStack(spacing:11) {
                    Button(action: {
                        triggerHapticOnButton()
                        if UserStorage.onboarding == OnboardingType.onboardingOne
                            .rawValue {
                            Superwall.shared.register(placement: "hold_main", feature: {     subscriptionManager.checkSubscriptionStatus()
                            })
                        } else if UserStorage.onboarding == OnboardingType.onboardingTwo
                            .rawValue {
                            Superwall.shared.register(placement: "hold_main_2", feature: {     subscriptionManager.checkSubscriptionStatus()
                            })
                        } else if UserStorage.onboarding == OnboardingType.onboardingThree
                            .rawValue {
                            Superwall.shared.register(placement: "hold_main_3", feature: {     subscriptionManager.checkSubscriptionStatus()
                            })
                        } else if UserStorage.onboarding == OnboardingType.onboardingFour
                            .rawValue {
                            Superwall.shared.register(placement: "hold_main_4", feature: {     subscriptionManager.checkSubscriptionStatus()
                            })
                        } else {
                            Superwall.shared.register(placement: "hold_main", feature: {     subscriptionManager.checkSubscriptionStatus()
                            })
                        }
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
    
    func triggerHapticOnButton() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func getFormattedDate() -> String {
        let futureDate = Calendar.current.date(byAdding: .day, value: 60, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        let formattedDate = formatter.string(from: futureDate)
        
        return formattedDate
    }
}

#Preview {
    SubscriptionView()
}
