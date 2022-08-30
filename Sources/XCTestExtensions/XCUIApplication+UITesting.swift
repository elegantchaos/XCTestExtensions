// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 30/08/22.
//  All code (c) 2022 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import XCTest
import CoreServices

public extension XCUIApplication {
    /// A flag to indicate to the launched application that we are UI testing.
    /// (passed through via the environment when the applicaation is launched)
    var isTestingUI: Bool {
        get { launchEnvironment["UITesting"] == "YES" }
        set { launchEnvironment["UITesting"] = newValue ? "YES" : "NO" }
    }

    /// A flag to indicate to the launched application that we are UI testing,
    /// specifically for the purpose of making screenshots.
    /// (passed through via the environment when the applicaation is launched)
    var isScreenshottingUI: Bool {
        get { launchEnvironment["UIScreenshotting"] == "YES" }
        set { launchEnvironment["UIScreenshotting"] = newValue ? "YES" : "NO" }
    }

    /// Helper which allows you to pass through a dictionary of JSON-encodable
    /// values to the launched application. These can be read and used to configure
    /// the application - eg to prevent modal alerts or other things that might interfere with testing.

    var uiTestParameters: [String:Any] {
        get { // not really needed, but provided for completeness.
            guard
                let json = launchEnvironment["UITestParameters"],
                let data = json.data(using: .utf8),
                let decoded = try? JSONSerialization.jsonObject(with: data),
                let parameters = decoded as? [String:Any]
            else {
                return [:]
            }
            return parameters
        }
        set {
            if let encoded = try? JSONSerialization.data(withJSONObject: newValue),
               let json = String(data: encoded, encoding: .utf8)
            {
                launchEnvironment["UITestParameters"] = json
            }
        }
    }
    
    /// The location that we're going to save screenshots to.
    /// As well as attaching them to the test results, we write them
    /// to a directory. This defaults to a temporary folder, but can
    /// be set using the `ScreenshotDirectory` when running the tests.
    /// This allows you to generate screenshots to a known location
    /// (eg inside your project folder, so that you can commit them).
    var screenshotsURL: URL {
        let env = ProcessInfo.processInfo.environment
        let path = env["ScreenshotDirectory"] ?? "\(NSTemporaryDirectory())/Screenshots"
        let url = URL(fileURLWithPath: path)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
    
    /// Make a screenshot. The screen to use can be set using the `ScreenshotScreen`
    /// environment variable. This lets you pick the best screen for your shots, eg
    /// one which is clear of other clutter.
    func cleanScreenshot() -> XCUIScreenshot {
        let screens = XCUIScreen.screens
        let screen: XCUIScreen
        if let string = ProcessInfo.processInfo.environment["ScreenshotScreen"], let index = Int(string), index < screens.count {
            screen = screens[index]
        } else {
            screen = screens.last!
        }
        
        return screen.screenshot()
    }
    
    /// Save a screenshot as a PNG to the output folder, with a given name.
    /// The screenshot is also returned as an attachment.
    func saveScreenshot(_ name: String) -> XCTAttachment {
        let screenshot = cleanScreenshot()
        let data = screenshot.pngRepresentation
        let url = screenshotsURL.appendingPathComponent(name).appendingPathExtension("png")
        do {
            try data.write(to: url)
            print("Screenshot \(name) written to \(url).")
        } catch {
            print("Screenshot \(name) failed.")
        }
        
        let attachment = XCTAttachment(uniformTypeIdentifier: kUTTypePNG as String, name: name, payload: screenshot.pngRepresentation, userInfo: [:])
        attachment.lifetime = .keepAlways
        return attachment
    }
    
    
    func showContextMenu(for row: XCUIElement, highlighting: String? = nil) {
#if !os(tvOS)
#if targetEnvironment(macCatalyst)
        row.rightClick()
        if let name = highlighting {
            let item = menuItems[name].firstMatch
            XCTAssertTrue(item.waitForExistence(timeout: 5))
            item.hover()
        }
#else
        row.press(forDuration: 1.0)
#endif
#endif
    }
    
    func selectContextMenuItem(_ name: String) {
#if !os(tvOS)
#if targetEnvironment(macCatalyst)
        let item = menuItems[name].firstMatch
#else
        let item = buttons[name].firstMatch
#endif
        XCTAssertTrue(item.waitForExistence(timeout: 5))
        item.tap()
#endif
    }
    
    func hideOtherApplications() {
#if os(macOS) || targetEnvironment(macCatalyst)
        let item = menuItems["hideOtherApplications:"]
        if item.waitForExistence(timeout: 1.0) {
            item.tap()
        }
#endif
    }
    
    func unhideApplications() {
#if os(macOS) || targetEnvironment(macCatalyst)
        let item = menuItems["unhideAllApplications:"]
        if item.waitForExistence(timeout: 1.0) {
            item.tap()
        }
#endif
    }
    
    func quit() {
#if os(macOS) || targetEnvironment(macCatalyst)
        let item = menuItems["handleQuit:"]
        if item.waitForExistence(timeout: 1.0) {
            item.tap()
        }
#endif
    }
    
}
