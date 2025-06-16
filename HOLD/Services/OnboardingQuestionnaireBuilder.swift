//
//  OnboardingQuestionnaireBuilder.swift
//  HOLD
//
//  Created by Muhammad Ali on 17/06/2025.
//

import Foundation

class OnboardingQuestionnaireBuilder {
    static let shared = OnboardingQuestionnaireBuilder()
    
    private var whatDoYouWantToAchieve: [String] = []
    private var avgDurationOfSexualIntercourse: String = ""
    private var howLongYouWishYouCouldLast: String = ""
    private var howOftenYouFinishEarlierThanYouWish: String = ""
    private var relationshipStatus: String = ""
    private var takenPillsEarlierToImproveIntimateLife: String = ""
    private var sleepPerDay: String = ""
    private var alcoholConsumption: String = ""
    private var doYouSmoke: String = ""
    private var name: String = ""
    private var age: String = ""
    
    private init() {}
    
    func setGoalOfWhatDoYouWantToAchieve(_ goal: String) {
        self.whatDoYouWantToAchieve.append(goal)
        print("Goal set: \(goal)")
    }
    
    func removeGoalOfWhatDoYouWantToAchieve(_ goal: String) {
        self.whatDoYouWantToAchieve.removeAll(where: { $0 == goal})
        print("Goal removed: \(goal)")
    }
    
    func setAvgDurationOfSexualIntercourse(_ duration: String) {
        self.avgDurationOfSexualIntercourse = duration
        print("Avg duration set: \(duration)")
    }
    
    func setHowLongYouWishYouCouldLast(_ duration: String) {
        self.howLongYouWishYouCouldLast = duration
        print("Desired duration set: \(duration)")
    }
    
    func setHowOftenYouFinishEarlierThanYouWish(_ frequency: String) {
        self.howOftenYouFinishEarlierThanYouWish = frequency
        print("Frequency set: \(frequency)")
    }
    
    func setRelationshipStatus(_ status: String) {
        self.relationshipStatus = status
        print("Relationship status set: \(status)")
    }
    
    func setTakenPillsEarlierToImproveIntimateLife(_ taken: String) {
        self.takenPillsEarlierToImproveIntimateLife = taken
        print("Pills history set: \(taken)")
    }
    
    func setSleepPerDay(_ sleep: String) {
        self.sleepPerDay = sleep
        print("Sleep duration set: \(sleep)")
    }
    
    func setAlcoholConsumption(_ consumption: String) {
        self.alcoholConsumption = consumption
        print("Alcohol consumption set: \(consumption)")
    }
    
    func setDoYouSmoke(_ smoke: String) {
        self.doYouSmoke = smoke
        print("Smoking status set: \(smoke)")
    }
    
    func setName(_ name: String) {
        self.name = name
        print("Name set: \(name)")
    }
    
    func setAge(_ age: String) {
        self.age = age
        print("Age set: \(age)")
    }
    
    func getCurrentGoals() -> [String] {
        return whatDoYouWantToAchieve
    }
    
    func getCurrentAvgDuration() -> String {
        return avgDurationOfSexualIntercourse
    }
    
    func getCurrentDesiredDuration() -> String {
        return howLongYouWishYouCouldLast
    }
    
    func getCurrentFrequency() -> String {
        return howOftenYouFinishEarlierThanYouWish
    }
    
    func getCurrentRelationshipStatus() -> String {
        return relationshipStatus
    }
    
    func getCurrentPillsHistory() -> String {
        return takenPillsEarlierToImproveIntimateLife
    }
    
    func getCurrentSleepDuration() -> String {
        return sleepPerDay
    }
    
    func getCurrentAlcoholConsumption() -> String {
        return alcoholConsumption
    }
    
    func getCurrentSmokingStatus() -> String {
        return doYouSmoke
    }
    
    func getCurrentName() -> String {
        return name
    }
    
    func getCurrentAge() -> String {
        return age
    }
    
    func completeOnboarding(completion: @escaping (Result<Void, Error>) -> Void) {
        let userId = DeviceIdManager.getUniqueDeviceId()
        
        let questionnaire = UserQuestionnaire(
            userId: userId,
            whatDoYouWantToAchieve: whatDoYouWantToAchieve,
            avgDurationOfSexualIntercourse: avgDurationOfSexualIntercourse,
            howLongYouWishYouCouldLast: howLongYouWishYouCouldLast,
            howOftenYouFinishEarlierThanYouWish: howOftenYouFinishEarlierThanYouWish,
            relationshipStatus: relationshipStatus,
            takenPillsEarlierToImproveIntimateLife: takenPillsEarlierToImproveIntimateLife,
            sleepPerDay: sleepPerDay,
            alcoholConsumption: alcoholConsumption,
            doYouSmoke: doYouSmoke,
            name: name,
            age: age
        )
        
        UserQuestionnaireManager.shared.saveQuestionnaire(questionnaire, completion: completion)
    }
    
    func resetAll() {
        whatDoYouWantToAchieve = []
        avgDurationOfSexualIntercourse = ""
        howLongYouWishYouCouldLast = ""
        howOftenYouFinishEarlierThanYouWish = ""
        relationshipStatus = ""
        takenPillsEarlierToImproveIntimateLife = ""
        sleepPerDay = ""
        alcoholConsumption = ""
        doYouSmoke = ""
        name = ""
        age = ""
    }
    
    func isReadyToComplete() -> Bool {
        return !name.isEmpty &&
               !age.isEmpty &&
               !whatDoYouWantToAchieve.isEmpty &&
               !avgDurationOfSexualIntercourse.isEmpty &&
               !howLongYouWishYouCouldLast.isEmpty &&
               !howOftenYouFinishEarlierThanYouWish.isEmpty &&
               !relationshipStatus.isEmpty &&
               !takenPillsEarlierToImproveIntimateLife.isEmpty &&
               !sleepPerDay.isEmpty &&
               !alcoholConsumption.isEmpty &&
               !doYouSmoke.isEmpty
    }
    
    func getCompletionProgress() -> Float {
        let totalFields: Float = 11.0
        var completedFields: Float = 0.0
        
        if !name.isEmpty { completedFields += 1 }
        if !age.isEmpty { completedFields += 1 }
        if !whatDoYouWantToAchieve.isEmpty { completedFields += 1 }
        if !avgDurationOfSexualIntercourse.isEmpty { completedFields += 1 }
        if !howLongYouWishYouCouldLast.isEmpty { completedFields += 1 }
        if !howOftenYouFinishEarlierThanYouWish.isEmpty { completedFields += 1 }
        if !relationshipStatus.isEmpty { completedFields += 1 }
        if !takenPillsEarlierToImproveIntimateLife.isEmpty { completedFields += 1 }
        if !sleepPerDay.isEmpty { completedFields += 1 }
        if !alcoholConsumption.isEmpty { completedFields += 1 }
        if !doYouSmoke.isEmpty { completedFields += 1 }
        
        return completedFields / totalFields
    }
}
