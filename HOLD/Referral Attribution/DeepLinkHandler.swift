//
//  DeepLinkHandler.swift
//  HOLD
//
//  Created by Muhammad Ali on 07/06/2025.
//

import Foundation

class DeepLinkHandler {
    static let shared = DeepLinkHandler()
    
    private init() {}
    
    func processDeepLink(url: URL) {
        print("Processing deep link: \(url)")
        
        if let linkAttribution = extractLinkAttribution(from: url) {
            print("Link attribution extracted: \(linkAttribution)")
            
            CreatorAttributionSystem.shared.attributeUser(
                creatorIdentifier: linkAttribution,
                source: .link
            )
        }
    }
    
    private func extractLinkAttribution(from url: URL) -> String? {
        let pathComponents = url.pathComponents
        
        let filteredComponents = pathComponents.filter { $0 != "/" }
        
        if filteredComponents.count >= 2 {
            return filteredComponents.last
        }
        
        return nil
    }
}
