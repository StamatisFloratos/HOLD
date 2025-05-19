//
//  Tracking.swift
//  HOLD
//
//  Created by Amalia Kyriakopoulou on 19/05/2025.
//

import Foundation
import FirebaseAnalytics

//Simple one-liner helper so that any screen can just call `track("event_name")`.
// Keeps Firebase import in one place and makes future migration easier.
public func track(_ name: String) {
    Analytics.logEvent(name, parameters: nil)
}
