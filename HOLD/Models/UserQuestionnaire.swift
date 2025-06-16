//
//  UserQuestionnaire.swift
//  HOLD
//
//  Created by Muhammad Ali on 17/06/2025.
//

import Foundation
import FirebaseFirestore

struct UserQuestionnaire {
    let userId: String
    let whatDoYouWantToAchieve: [String]
    let avgDurationOfSexualIntercourse: String
    let howLongYouWishYouCouldLast: String
    let howOftenYouFinishEarlierThanYouWish: String
    let relationshipStatus: String
    let takenPillsEarlierToImproveIntimateLife: String
    let sleepPerDay: String
    let alcoholConsumption: String
    let doYouSmoke: String
    let name: String
    let age: String
    let lastUpdated: Timestamp
    var didBoughtSubscription: Bool
    
    init(userId: String,
         whatDoYouWantToAchieve: [String] = [],
         avgDurationOfSexualIntercourse: String = "",
         howLongYouWishYouCouldLast: String = "",
         howOftenYouFinishEarlierThanYouWish: String = "",
         relationshipStatus: String = "",
         takenPillsEarlierToImproveIntimateLife: String = "",
         sleepPerDay: String = "",
         alcoholConsumption: String = "",
         doYouSmoke: String = "",
         name: String = "",
         age: String = "",
         didBoughtSubscription: Bool = false,
         lastUpdated: Timestamp = Timestamp(date: Date())) {
        
        self.userId = userId
        self.whatDoYouWantToAchieve = whatDoYouWantToAchieve
        self.avgDurationOfSexualIntercourse = avgDurationOfSexualIntercourse
        self.howLongYouWishYouCouldLast = howLongYouWishYouCouldLast
        self.howOftenYouFinishEarlierThanYouWish = howOftenYouFinishEarlierThanYouWish
        self.relationshipStatus = relationshipStatus
        self.takenPillsEarlierToImproveIntimateLife = takenPillsEarlierToImproveIntimateLife
        self.sleepPerDay = sleepPerDay
        self.alcoholConsumption = alcoholConsumption
        self.doYouSmoke = doYouSmoke
        self.name = name
        self.age = age
        self.didBoughtSubscription = didBoughtSubscription
        self.lastUpdated = lastUpdated
    }
    
    init?(from data: [String: Any]) {
        guard let userId = data["user_id"] as? String else { return nil }
        
        self.userId = userId
        self.whatDoYouWantToAchieve = data["what_do_you_want_to_achieve"] as? [String] ?? []
        self.avgDurationOfSexualIntercourse = data["avg_duration_of_sexual_intercourse"] as? String ?? ""
        self.howLongYouWishYouCouldLast = data["how_long_you_wish_you_could_last"] as? String ?? ""
        self.howOftenYouFinishEarlierThanYouWish = data["how_often_you_finish_earlier_than_you_wish"] as? String ?? ""
        self.relationshipStatus = data["relationship_status"] as? String ?? ""
        self.takenPillsEarlierToImproveIntimateLife = data["taken_pills_earlier_to_improve_intimate_life"] as? String ?? ""
        self.sleepPerDay = data["sleep_per_day"] as? String ?? ""
        self.alcoholConsumption = data["alcohol_consumption"] as? String ?? ""
        self.doYouSmoke = data["do_you_smoke"] as? String ?? ""
        self.name = data["name"] as? String ?? ""
        self.age = data["age"] as? String ?? ""
        self.didBoughtSubscription = data["didBoughtSubscription"] as? Bool ?? false
        self.lastUpdated = data["last_updated"] as? Timestamp ?? Timestamp(date: Date())
    }
    
    func toFirestoreData() -> [String: Any] {
        return [
            "user_id": userId,
            "what_do_you_want_to_achieve": whatDoYouWantToAchieve,
            "avg_duration_of_sexual_intercourse": avgDurationOfSexualIntercourse,
            "how_long_you_wish_you_could_last": howLongYouWishYouCouldLast,
            "how_often_you_finish_earlier_than_you_wish": howOftenYouFinishEarlierThanYouWish,
            "relationship_status": relationshipStatus,
            "taken_pills_earlier_to_improve_intimate_life": takenPillsEarlierToImproveIntimateLife,
            "sleep_per_day": sleepPerDay,
            "alcohol_consumption": alcoholConsumption,
            "do_you_smoke": doYouSmoke,
            "name": name,
            "age": age,
            "didBoughtSubscription": didBoughtSubscription,
            "last_updated": lastUpdated,
            "platform": "ios",
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "unknown"
        ]
    }
}
