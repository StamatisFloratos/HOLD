//
//  UserAttribution.swift
//  HOLD
//
//  Created by Muhammad Ali on 07/06/2025.
//

import Foundation

enum AttributionSource: String {
    case link = "link"
    case code = "code"
    case both = "both"
}

struct UserAttribution {
    let userId: String
    let creatorCode: String
    let attributionSource: String
    let linkIdentifier: String
    let platform: String
}
