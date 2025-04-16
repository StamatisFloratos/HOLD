//
//  NavigationManager.swift
//  HOLD
//
//  Created by Rabbia Ijaz on 08/04/25.
//

import Foundation
import SwiftUI

class NavigationManager: ObservableObject {
    @Published var routes = [Route]()
    
    func push(to screen: Route) {
        routes.append(screen)
    }
    
    func pop(to screen: Route) {
        guard routes.contains(screen) else { return }
        
        for i in stride(from: routes.count - 1, through: 0, by: -1) {
            let route = routes[i]
            if route == screen {
                return
            }
            _ = routes.popLast()
        }
    }
    
    func goBack() {
        _ = routes.popLast()
    }
    
    func reset() {
        routes = []
    }
    
    func replace(stack: [Route]) {
        routes = stack
    }
}

extension NavigationManager {
    enum Route: Codable, Hashable {
        case measurementView
        case measurementActivityView
        case progressView
        case workoutView
        case knowledgeTabView
        case knowledgeView(categoryTitle:String, items:[KnowledgeItem])
        case knowledgeDetailView(item:KnowledgeItem)
    }
}
