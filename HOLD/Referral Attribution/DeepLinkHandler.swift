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
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let deepLinkValue = queryItems.first(where: { $0.name == "deep_link_value" })?.value {
            return deepLinkValue
        }
        
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        return pathComponents.last
    }
}
