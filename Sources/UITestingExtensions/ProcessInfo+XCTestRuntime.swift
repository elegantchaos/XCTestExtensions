// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/08/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation

public extension ProcessInfo {
    /// Are we running as part of a UITesting session?
    /// Can be used to modify/automate behaviour.
    var isUITesting: Bool {
        return environment["UITesting"] == "YES"
    }

    /// Are we running special UITests for screenshotting?
    var isUIScreenshotting: Bool {
        return environment["UIScreenshotting"] == "YES"
    }
    
    /// Returns any parameters passed through from the ui test session
    var uiTestParameters: [String:Any] {
        guard
            let json = environment["UITestParameters"],
                let data = json.data(using: .utf8),
                let decoded = try? JSONSerialization.jsonObject(with: data),
                let parameters = decoded as? [String:Any]
        else {
            return [:]
        }

        return parameters
    }
}
