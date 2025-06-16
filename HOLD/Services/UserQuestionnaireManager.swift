//
//  UserQuestionnaireManager.swift
//  HOLD
//
//  Created by Muhammad Ali on 17/06/2025.
//

import Foundation
import FirebaseFirestore

class UserQuestionnaireManager {
    static let shared = UserQuestionnaireManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    internal func saveQuestionnaire(_ questionnaire: UserQuestionnaire, completion: @escaping (Result<Void, Error>) -> Void) {
        let userId = DeviceIdManager.getUniqueDeviceId()
        
        checkExistingQuestionnaire(userId: userId) { [weak self] existingQuestionnaire in
            if existingQuestionnaire != nil {
                self?.updateQuestionnaire(questionnaire, completion: completion)
            } else {
                self?.createNewQuestionnaire(questionnaire, completion: completion)
            }
        }
    }
    
    func getQuestionnaire(completion: @escaping (Result<UserQuestionnaire?, Error>) -> Void) {
        let userId = DeviceIdManager.getUniqueDeviceId()
        
        checkExistingQuestionnaire(userId: userId) { questionnaire in
            completion(.success(questionnaire))
        }
    }
    
    func deleteQuestionnaire(completion: @escaping (Result<Void, Error>) -> Void) {
        let userId = DeviceIdManager.getUniqueDeviceId()
        
        db.collection("user_questionnaire").document(userId).delete() { error in
            if let error = error {
                completion(.failure(error))
            } else {
                print("Questionnaire deleted successfully")
                completion(.success(()))
            }
        }
    }
    
    private func checkExistingQuestionnaire(userId: String, completion: @escaping (UserQuestionnaire?) -> Void) {
        db.collection("user_questionnaire").document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching questionnaire: \(error)")
                completion(nil)
                return
            }
            
            if let document = document, document.exists,
               let data = document.data(),
               let questionnaire = UserQuestionnaire(from: data) {
                completion(questionnaire)
            } else {
                completion(nil)
            }
        }
    }
    
    private func createNewQuestionnaire(_ questionnaire: UserQuestionnaire, completion: @escaping (Result<Void, Error>) -> Void) {
        let questionnaireData = questionnaire.toFirestoreData()
        
        db.collection("user_questionnaire").document(questionnaire.userId).setData(questionnaireData) { error in
            if let error = error {
                print("Error storing questionnaire: \(error)")
                completion(.failure(error))
            } else {
                print("Questionnaire stored successfully")
                completion(.success(()))
            }
        }
    }
    
    private func updateQuestionnaire(_ questionnaire: UserQuestionnaire, completion: @escaping (Result<Void, Error>) -> Void) {
        let questionnaireData = questionnaire.toFirestoreData()
        
        db.collection("user_questionnaire").document(questionnaire.userId).updateData(questionnaireData) { error in
            if let error = error {
                print("Error updating questionnaire: \(error)")
                completion(.failure(error))
            } else {
                print("Questionnaire updated successfully")
                completion(.success(()))
            }
        }
    }
    
    func logSubscriptionEvent() {
        getQuestionnaire { [weak self] result in
            switch result {
            case .success(let questionnaire):
                guard var existingQuestionnaire = questionnaire else {
                    print("User document doesn't exist, cannot log subscription event")
                    return
                }
                
                existingQuestionnaire.didBoughtSubscription = true
                self?.updateQuestionnaire(existingQuestionnaire) { _ in }
            case .failure(_):
                return
            }
        }
    }
}
