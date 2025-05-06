//
//  OnboardingQuestion.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 04/05/2025.
//
import Foundation


struct OnboardingQuestion: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let allowsMultipleSelection: Bool
    let options: [String]
    let imageName: String?
}

extension OnboardingQuestion {
    static let sampleScreens: [OnboardingQuestion] = [
        OnboardingQuestion(
            title: "What do you want to achieve?",
            subtitle: "You can select multiple.",
            allowsMultipleSelection: true,
            options: [
                "Beat Premature Ejaculation",
                "Beat Erectile Dysfunction",
                "Improve Bedroom Skills",
                "Boost Overall Health",
                "Fix Loss of Desire",
                "Other"
            ],
            imageName: nil
        ),
        OnboardingQuestion(
            title: "What is the average duration of your sexual intercourse?",
            subtitle: "This will help us create a personalized plan for your needs.",
            allowsMultipleSelection: false,
            options: [
                "Less than 2 minutes",
                "2-10 minutes",
                "10-20 minutes",
                "20 minutes or more"
            ],
            imageName: nil
        ),
        OnboardingQuestion(
            title: "How long do you wish you could last during sex?",
            subtitle: "Keep in mind that on average a woman needs 13 mins 42s to finish once and 29 mins 15s to finish twice.",
            allowsMultipleSelection: false,
            options: [
                "5 - 10  minutes",
                "10 - 20 minutes",
                "20 - 30 minutes",
                "40 minutes or more"
            ],
            imageName: nil
        ),
        OnboardingQuestion(
            title: "How often do you finish earlier than you wish you would?",
            subtitle: "Give us a rough estimate.",
            allowsMultipleSelection: false,
            options: [
                "Never",
                "Sometimes",
                "Most of the time",
                "Always"
            ],
            imageName: nil
        ),
         OnboardingQuestion(
            title: "Your ability to last longer depends depends on the strength and control over your pelvic floor muscle.",
            subtitle: "Strong pelvic floor muscles are the key to delaying ejaculation and to lasting in bed as long as you wish. You can have complete control.",
            allowsMultipleSelection: false,
            options: [],
            imageName: "question1"
        ),
        OnboardingQuestion(
            title: "Strong pelvic floor muscles are the key to hard and sustained erections.",
            subtitle: "Strong pelvic floor muscles will allow you to get hard-ons more easily but also maintain them for much longer for when it matters most.",
            allowsMultipleSelection: false,
            options: [],
            imageName: "question2"
        ),
        OnboardingQuestion(
            title: "What is your relationship status?",
            subtitle: "We won't tell—promise.",
            allowsMultipleSelection: false,
            options: [
                "Married",
                "Dating",
                "Single",
                "Complicated",
                "I don't want to answer"
            ],
            imageName: nil
        ),
        OnboardingQuestion(
            title: "Have you taken any pills to improve your intimate life?",
            subtitle: "Tried the little blue magic yet? Totally fine if you have, we're just getting the full picture.",
            allowsMultipleSelection: false,
            options: [
                "Yes, I take quite a lot of pills",
                "Yes, I use pills from time to time",
                "No, I have not",
                "I don't want to answer"
            ],
            imageName: nil
        ),
        OnboardingQuestion(
            title: "",
            subtitle: "Pills are a quick temporary fix. HOLD builds real control—from the inside out. No side effects. Just results that last.",
            allowsMultipleSelection: false,
            options: [],
            imageName: "question3"
        ),
        OnboardingQuestion(
            title: "How much sleep do you get?",
            subtitle: "Sleep fuels your stamina, recovery, and drive. Knowing your routine helps us fine-tune your path to peak performance.",
            allowsMultipleSelection: false,
            options: [
                "Fewer than 5 hours",
                "Between 5 and 6 hours",
                "Between 7 and 8 hours",
                "Over 8 hours"
            ],
            imageName: nil
        ),
        OnboardingQuestion(
            title: "How often do you drink alcohol?",
            subtitle: "This helps us factor it into your performance plan.",
            allowsMultipleSelection: false,
            options: [
                "Multiple times a week",
                "Once a week",
                "1-2 times per month",
                "Never"
            ],
            imageName: nil
        ),
        OnboardingQuestion(
            title: "Do you smoke?",
            subtitle: "This helps us factor it into your performance plan.",
            allowsMultipleSelection: false,
            options: [
                "Yes",
                "No",
                "Sometimes"
            ],
            imageName: nil
        ),
        OnboardingQuestion(
            title: "Finally...",
            subtitle: "A little more about you.",
            allowsMultipleSelection: false,
            options: [
                "Name",
                "Age"
            ],
            imageName: nil
        )
    ]
}
