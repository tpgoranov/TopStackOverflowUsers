//
//  TopStackOverflowUsersUITests.swift
//  TopStackOverflowUsersUITests
//
//  Created by Todor Goranov on 25/04/2026.
//

import XCTest

final class TopStackOverflowUsersUITests: XCTestCase {
    private func makeApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments.append("--ui-testing-mock-users")
        app.launchArguments.append("--ui-testing-reset-store")
        return app
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testTappingFollowButtonChangesTitleToUnfollow() throws {
        let app = makeApp()
        app.launch()

        let followButton = app.buttons["Follow"].firstMatch
        XCTAssertTrue(followButton.waitForExistence(timeout: 5))

        followButton.tap()

        let unfollowButton = app.buttons["Unfollow"].firstMatch
        XCTAssertTrue(unfollowButton.waitForExistence(timeout: 2))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            makeApp().launch()
        }
    }
}
